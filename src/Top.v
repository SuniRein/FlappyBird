`include "Def.v"

module Top(
    input clk, // 100 MHz
    input rstn,

    input PS2_clk,
    input PS2_data,

    input LED_debug,       // LED 调试输出
    input bird_no_fall,    // 鸟不掉落
    input bird_no_die,     // 鸟不死亡
    input pillars_no_move, // 柱子不移动
    input music_off,       // 关闭背景音乐

    output beep,

    output [3:0] vga_red,
    output [3:0] vga_green,
    output [3:0] vga_blue,
    output       vga_hs,
    output       vga_vs,

    output LED_clk,
    output LED_rstn,
    output LED_out,
    output LED_en,

    output seg_clk,
    output seg_rstn,
    output seg_out,
    output seg_en
);

/**
 * LEDs
 */ 

reg [15:0] LED_in;
reg [31:0] seg_hex;

wire [31:0] clk_div;
clkdiv div(
    .clk     (clk),
    .rstn    (rstn),
    .div_res (clk_div)
);

LEDP2S ledp2s(
    .clk    (clk),
    .start  (clk_div[20]),
    .par_in (LED_in),
    .sclk   (LED_clk),
    .sclrn  (LED_rstn),
    .sout   (LED_out),
    .EN     (LED_en)
);

Sseg_Dev segp2s(
    .clk    (clk),
    .start  (clk_div[20]),
    .hexs   (seg_hex),
    .points (8'b0),
    .LEs    (8'b0),
    .sclk   (seg_clk),
    .sclrn  (seg_rstn),
    .sout   (seg_out),
    .EN     (seg_en)
);

localparam LED_KEY_UP       = 0;
localparam LED_KEY_DOWN     = 1;
localparam LED_KEY_LEFT     = 2;
localparam LED_KEY_RIGHT    = 3;
localparam LED_KEY_SPACE    = 4;
localparam LED_IS_COLLISION = 15;

localparam SEG_SCORE_SHOW_BEGIN = 31;
localparam SEG_SCORE_SHOW_END   = 16;

always @(posedge clk) begin
    seg_hex[15:0] <= 16'hFFFF;
end

/**
 * Background ROM
 */

wire [11:0] background_color, background_init_color, background_failed_color;
wire [18:0] background_addr = curr_y * `WIDTH + curr_x;

BackgroundROM background_rom(
    .clka  (clk),
    .ena   (1'b1),
    .addra (background_addr),
    .douta (background_color)
);
BackgroundInitROM background_init_rom(
    .clka  (clk),
    .ena   (1'b1),
    .addra (background_addr),
    .douta (background_init_color)
);
BackgroundFailedROM background_failed_rom(
    .clka  (clk),
    .ena   (1'b1),
    .addra (background_addr),
    .douta (background_failed_color)
);

/**
 * Background Music
 */

wire beep_out;

Beep beep_driver(
    .clk  (clk),
    .beep (beep_out)
);

assign beep = (music_off) ? 0 : beep_out;

/**
 * Frame Clock
 */

// 游戏帧时钟
wire frame_clk;
ClockDiv #(.OUTPUT_CLOCK_FLUENCY(50)) frame_clk_div(
    .clk     (clk),
    .rstn    (rstn),
    .clk_div (frame_clk)
);

/**
 * Keyborad Input
 */

`Key key;
wire key_state;

Keyboard keyborad(
    .clk       (clk),
    .rstn      (rstn),
    .PS2_clk   (PS2_clk),
    .PS2_data  (PS2_data),
    .key       (key),
    .key_state (key_state)
);

// 记录按键状态
reg key_up, key_down, key_left, key_right, key_space;

always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        key_up    <= 'b0;
        key_down  <= 'b0;
        key_left  <= 'b0;
        key_right <= 'b0;
        key_space <= 'b0;
    end
    else begin
        case (key)
            `KEY_UP   : key_up    <= key_state;
            `KEY_DOWN : key_down  <= key_state;
            `KEY_LEFT : key_left  <= key_state;
            `KEY_RIGHT: key_right <= key_state;
            `KEY_SPACE: key_space <= key_state;
            default   : /* do nothing */;
        endcase
    end
end

// 一直按住按键只响应一次
reg key_space_shift;
always @(posedge frame_clk, negedge rstn) begin
    if (!rstn) begin
        key_space_shift      <= 'b0;
    end
    else begin
        key_space_shift      <= key_space;
    end
end

wire key_space_press_once = !key_space_shift && key_space;

/// Keyborad Debug Mode
always @(posedge clk) begin
    if (LED_debug) begin
        LED_in[LED_KEY_UP]    <= key_up   ;
        LED_in[LED_KEY_DOWN]  <= key_down ;
        LED_in[LED_KEY_LEFT]  <= key_left ;
        LED_in[LED_KEY_RIGHT] <= key_right;
        LED_in[LED_KEY_SPACE] <= key_space;
    end
    else begin
        LED_in[LED_KEY_UP]    <= 0;
        LED_in[LED_KEY_DOWN]  <= 0;
        LED_in[LED_KEY_LEFT]  <= 0;
        LED_in[LED_KEY_RIGHT] <= 0;
        LED_in[LED_KEY_SPACE] <= 0;
    end
end

/**
 * VGA Display
 */

`PosX curr_x;
`PosY curr_y;
wire vga_rdyn;

// 产生 vga 需要的 25MHz 时钟
wire vga_clk;
ClockDiv #(.OUTPUT_CLOCK_FLUENCY(25_000_000)) vga_clk_div(
    .clk     (clk),
    .rstn    (rstn),
    .clk_div (vga_clk)
);

reg [11:0] color;
always @(*) begin
    case (state)
        `GAME_INIT:    color = background_init_color;
        `GAME_RUNNING: color = is_bird ? bird_color : (is_pillar ? pillar_color : background_color);
        `GAME_FAILED:  color = background_failed_color;
        default: /* do nothing */;
    endcase
end

VgaDriver vga_driver(
    .clk      (vga_clk),
    .rstn     (rstn),
    .color    (color),
    .curr_x   (curr_x),
    .curr_y   (curr_y),
    .r        (vga_red),
    .g        (vga_green),
    .b        (vga_blue),
    .rdyn     (vga_rdyn),
    .hs       (vga_hs),
    .vs       (vga_vs)
);

/**
 * Game State
 */

`GameState state;
wire failed = !bird_no_die && (is_collision || out_of_bound);

GameStateUnit game_state_unit(
    .clk    (clk),
    .rstn   (rstn),
    .start  (key_space_press_once),
    .failed (failed),
    .state  (state)
);

/**
 * Bird
 */

wire [11:0] bird_color;
wire is_bird;
wire out_of_bound;

Bird #(
    .BIRD_X      (100),
    .BIRD_Y_INIT (240),
    .BIRD_WIDTH  (40),
    .BIRD_HEIGHT (30),
    .BIRD_UP     (8),
    .BIRD_DOWN   (10),
    .BIRD_FALL   (3)
) bird (
    .clk          (clk),
    .rstn         (rstn),
    .frame_clk    (frame_clk),
    .state        (state),
    .up           (key_up || key_space),
    .down         (key_down),
    .x            (curr_x),
    .y            (curr_y),
    .no_fall      (bird_no_fall),
    .out_of_bound (out_of_bound),
    .valid        (is_bird),
    .color        (bird_color)
);

/**
 * Pillars
 */

wire        is_pillar;
wire [11:0] pillar_color;
`Score      score;

wire [15:0] score_decimal;
assign score_decimal[ 3: 0] = (score)        % 10;
assign score_decimal[ 7: 4] = (score / 10)   % 10;
assign score_decimal[11: 8] = (score / 100)  % 10;
assign score_decimal[15:12] = (score / 1000) % 10;

always @(posedge frame_clk) begin
    seg_hex[SEG_SCORE_SHOW_BEGIN:SEG_SCORE_SHOW_END] <= score_decimal;
end

Pillar #(
    .PILLAR_COUNT       (4),
    .BIRD_X             (100),
    .PILLAR_X_INIT      (250),
    .PILLAR_X_WIDTH     (60),
    .PILLAR_Y_WIDTH     (150),
    .PILLAR_Y_MIN       (101), // 101*2 + 128 + 150 = 480
    .PILLAR_HEAD_HEIGHT (30),
    .PILLAR_GAP         (180),
    .PILLAR_SPEED       (1)
) pillars (
    .clk       (clk),
    .rstn      (rstn),
    .frame_clk (frame_clk),
    .state     (state),
    .x         (curr_x),
    .y         (curr_y),
    .no_move   (pillars_no_move),
    .valid     (is_pillar),
    .color     (pillar_color),
    .score     (score)
);

/**
 * 碰撞检测
 */

wire is_collision = is_bird && is_pillar;

reg [31:0] collision_cnt;
always @(posedge clk) begin
    if (collision_cnt == 1 << 19) begin
        collision_cnt <= 0;
    end
    else begin
        collision_cnt <= collision_cnt + 1;
    end
end

always @(posedge clk) begin
    if (LED_debug) begin
        LED_in[LED_IS_COLLISION] <= (collision_cnt == 0) ? is_collision : is_collision | LED_in[LED_IS_COLLISION];
    end
    else begin
        LED_in[LED_IS_COLLISION] <= 0;
    end
end

endmodule
