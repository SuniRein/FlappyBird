`include "Def.v"

module Bird
#(
    parameter BIRD_X      = 0,
    parameter BIRD_Y_INIT = 240,
    parameter BIRD_WIDTH  = 40,
    parameter BIRD_HEIGHT = 45,
    parameter BIRD_UP     = 3,
    parameter BIRD_DOWN   = 3,
    parameter BIRD_FALL   = 2
)(
    input            clk,
    input            rstn,
    input            frame_clk,
    input `GameState state,
    input            up,
    input            down,
    input `PosX      x,
    input `PosY      y,
    input            no_fall, // 使鸟不要掉落，方便调试

    output            out_of_bound,
    output reg        valid,
    output reg [11:0] color
);

`PosYR bird_y;

assign out_of_bound = bird_y >= `HEIGHT - BIRD_HEIGHT;

always @(posedge frame_clk, negedge rstn) begin
    if (!rstn) begin
        bird_y <= BIRD_Y_INIT;
    end
    else if (state == `GAME_RUNNING) begin
             if (up)      bird_y <= bird_y - BIRD_UP;
        else if (down)    bird_y <= bird_y + BIRD_DOWN;
        else if (no_fall) bird_y <= bird_y;
        else              bird_y <= bird_y + BIRD_FALL;
    end
    else begin
        bird_y <= BIRD_Y_INIT;
    end
end

assign pos_valid = (x >= BIRD_X) && (x < BIRD_X + BIRD_WIDTH) && (y >= bird_y) && (y < bird_y + BIRD_HEIGHT);

reg  [10:0] rom_addr;
wire [11:0] rom_color;
localparam INVALID_COLOR = 12'h0F0;

BirdROM bird_rom(
    .clka  (clk),
    .ena   (1'b1),
    .addra (rom_addr),
    .douta (rom_color)
);

always @(posedge clk) begin
    valid <= pos_valid && (rom_color != INVALID_COLOR);

    if (pos_valid) begin
        rom_addr <= (x - BIRD_X) + (y - bird_y) * BIRD_WIDTH;
        color    <= rom_color;
    end
    else begin
        rom_addr <= rom_addr;
        color    <= color;
    end
end

endmodule
