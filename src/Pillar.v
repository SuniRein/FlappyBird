`include "Def.v"

module Pillar
#(
    parameter PILLAR_COUNT       = 5,
    parameter BIRD_X             = 100,
    parameter PILLAR_X_INIT      = 320,
    parameter PILLAR_Y_MIN       = 100,
    parameter PILLAR_X_WIDTH     = 50,
    parameter PILLAR_Y_WIDTH     = 100,
    parameter PILLAR_HEAD_HEIGHT = 30,
    parameter PILLAR_GAP         = 100,
    parameter PILLAR_SPEED       = 1
)(
    input             clk,
    input             rstn,
    input             frame_clk,
    input `GameState  state,
    input `PosX       x,
    input `PosY       y,
    input             no_move,
    output reg        valid,
    output reg [11:0] color,
    output `ScoreR    score
);

`PosXR pillar_x [PILLAR_COUNT-1:0]; // 上半部分的右上角
`PosYR pillar_y [PILLAR_COUNT-1:0]; // 上半部分的右上角
reg    passed   [PILLAR_COUNT-1:0]; // 记录是否经过了鸟

integer i;

`ScoreR running_score;

/**
 * Raodom Engine
 */

wire [31:0] number;
`PosY random_pos = number[6:0];

Random32 random32(
    .clk    (clk),
    .rstn   (rstn),
    .seed   (32'h9801_FA91),
    .number (number)
);

task PillarInit;
begin
    for (i = 0; i != PILLAR_COUNT; i = i + 1) begin
        pillar_x[i] <= PILLAR_X_INIT + PILLAR_GAP * i;
        pillar_y[i] <= PILLAR_Y_MIN + random_pos;
        passed[i]   <= 0;
    end
    running_score <= 0;
end
endtask

always @(posedge frame_clk, negedge rstn) begin
    if (!rstn) begin
        PillarInit();
        score <= 0;
    end
    else begin
        case (state)
            `GAME_INIT: begin
                PillarInit();
                score <= 0;
            end

            `GAME_RUNNING: begin
                for (i = 0; i != PILLAR_COUNT; i = i + 1) begin
                    if (pillar_x[i] <= BIRD_X && !passed[i]) begin
                        running_score <= running_score + 1;
                        pillar_x[i]   <= (no_move) ? pillar_x[i] : pillar_x[i] - PILLAR_SPEED;
                        pillar_y[i]   <= pillar_y[i];
                        passed[i]     <= 1'b1;
                    end
                    else begin
                        if (pillar_x[i] <= PILLAR_SPEED) begin // 柱子越界，销毁，重新生成
                            pillar_x[i] <= pillar_x[(i==0)?(PILLAR_COUNT-1):(i-1)] + PILLAR_GAP;
                            pillar_y[i] <= PILLAR_Y_MIN + random_pos;
                            passed[i]   <= 1'b0;
                        end
                        else begin
                            pillar_x[i] <= (no_move) ? pillar_x[i] : pillar_x[i] - PILLAR_SPEED;
                            pillar_y[i] <= pillar_y[i];
                            passed[i]   <= passed[i];
                        end
                    end
                end
                score <= running_score;
            end

            `GAME_FAILED: begin
                PillarInit();
                score <= score;
            end

            default: /* unreachable */;
        endcase
    end
end

/**
 * 判断是柱子的哪一部分
 */

wire [PILLAR_COUNT-1:0] is_pillar_mains;
generate
    for (genvar i = 0; i != PILLAR_COUNT; i = i + 1) begin
        assign is_pillar_mains[i] = 
            (y < pillar_y[i] - PILLAR_HEAD_HEIGHT || y >= pillar_y[i] + PILLAR_Y_WIDTH + PILLAR_HEAD_HEIGHT) &&
             x < pillar_x[i] && x + PILLAR_X_WIDTH >= pillar_x[i];
    end
endgenerate

wire [PILLAR_COUNT-1:0] is_pillar_ups;
generate
    for (genvar i = 0; i != PILLAR_COUNT; i = i + 1) begin
        assign is_pillar_ups[i] = 
            y < pillar_y[i] &&
            x < pillar_x[i] && x + PILLAR_X_WIDTH >= pillar_x[i];
    end
endgenerate

wire [PILLAR_COUNT-1:0] is_pillar_downs;
generate
    for (genvar i = 0; i != PILLAR_COUNT; i = i + 1) begin
        assign is_pillar_downs[i] = 
            y >= pillar_y[i] + PILLAR_Y_WIDTH &&
            x < pillar_x[i] && x + PILLAR_X_WIDTH >= pillar_x[i];
    end
endgenerate

wire is_pillar_main = |is_pillar_mains;
wire is_pillar_up   = |is_pillar_ups;
wire is_pillar_down = |is_pillar_downs;
wire is_pillar      = is_pillar_up || is_pillar_down;

/**
 * 输出对应颜色
 */

localparam INVALID_COLOR = 12'h00F;

reg  [10:0] head_addr;
reg  [ 5:0] main_addr;
wire [11:0] head_color, main_color;

PillarHeadROM pillar_head_rom(
    .clka  (clk),
    .ena   (1'b1),
    .addra (head_addr),
    .douta (head_color)
);
PillarMainROM pillar_main_rom(
    .clka  (clk),
    .ena   (1'b1),
    .addra (main_addr),
    .douta (main_color)
);

always @(posedge clk) begin
    valid <= (is_pillar_main) ? (main_color != INVALID_COLOR) : is_pillar;
    color <= is_pillar_main ? main_color : head_color;
end

reg [31:0] curr_pillar;
always @(*) begin : PillarSwitcher
for (i = 0; i != PILLAR_COUNT; i = i + 1) begin
        if (is_pillar_ups[i] || is_pillar_downs[i]) begin
            curr_pillar = i;
            disable PillarSwitcher;
        end
    end
end

always @(posedge clk) begin
    if (is_pillar_main) begin
        main_addr <= x + PILLAR_X_WIDTH - pillar_x[curr_pillar];
        head_addr <= head_addr;
    end
    else if (is_pillar_up) begin
        main_addr <= main_addr;
        head_addr <= (x + PILLAR_X_WIDTH - pillar_x[curr_pillar])
                     + (y + PILLAR_HEAD_HEIGHT - pillar_y[curr_pillar]) * PILLAR_X_WIDTH;
    end
    else if (is_pillar_down) begin
        main_addr <= main_addr;
        head_addr <= (x + PILLAR_X_WIDTH - pillar_x[curr_pillar]) 
                     + (y - pillar_y[curr_pillar] - PILLAR_Y_WIDTH) * PILLAR_X_WIDTH;
    end
    else begin
        main_addr <= main_addr;
        head_addr <= head_addr;
    end
end

endmodule
