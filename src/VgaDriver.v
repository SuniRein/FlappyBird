`include "Def.v"

module VgaDriver(
    input        clk, // 25.175 MHz
    input        rstn,
    input [11:0] color, // bbbb_gggg_rrrr

    output `PosXR    curr_x,
    output `PosYR    curr_y,
    output reg [3:0] r, g, b,
    output reg       rdyn,
    output           hs, vs // 行同步信号和场同步信号
);

// 行时序由行消隐、行同步、行视频有效、行前肩构成
localparam HOR_BACK_PORCH   = 96;
localparam HOR_SYNC         = 48;
localparam HOR_ACTIVE_VIDEO = 640;
localparam HOR_FRONT_PROCH  = 16;
localparam HOR_SCAN         = 800;

// 场时序由场消隐、场同步、场视频有效、场前肩构成
localparam VER_BACK_PORCH   = 2;
localparam VER_SYNC         = 33;
localparam VER_ACTIVE_VIDEO = 480;
localparam VER_FRONT_PROCH  = 10;
localparam VER_SCAN         = 525;

reg [9:0] cnt_hs, cnt_vs;

// 行计数器 记录列数
always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        cnt_hs <= 'b0;
    end
    else if (cnt_hs == HOR_SCAN - 1'b1) begin
        cnt_hs <= 'b0;
    end
    else begin
        cnt_hs <= cnt_hs + 1'b1;
    end
end

// 场计数器 记录行数
always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        cnt_vs <= 'b0;
    end
    else if (cnt_hs == HOR_SCAN - 1'b1) begin
        if (cnt_vs == VER_SCAN - 1'b1) begin
            cnt_vs <= 'b0;
        end
        else begin
            cnt_vs <= cnt_vs + 1'b1;
        end
    end
    else begin
        cnt_vs <= cnt_vs;
    end
end

assign hs = cnt_hs <= HOR_BACK_PORCH;
assign vs = cnt_vs <= VER_BACK_PORCH;

wire hs_en = (cnt_hs >= HOR_BACK_PORCH + HOR_SYNC) && (cnt_hs < HOR_BACK_PORCH + HOR_SYNC + HOR_ACTIVE_VIDEO);
wire vs_en = (cnt_vs >= VER_BACK_PORCH + VER_SYNC) && (cnt_vs < VER_BACK_PORCH + VER_SYNC + VER_ACTIVE_VIDEO);
wire rdy   = hs_en && vs_en;

always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        rdyn     <= 1'b1;
        r        <= 'b0;
        g        <= 'b0;
        b        <= 'b0;
    end
    else begin
        rdyn     <= ~rdy;
        r        <= rdy ? color[ 3:0] : 'b0;
        g        <= rdy ? color[ 7:4] : 'b0;
        b        <= rdy ? color[11:8] : 'b0;
    end
end

// curr_x
always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        curr_x <= 'b0;
    end
    else if (rdy) begin
        curr_x <= curr_x + 1;
    end
    else begin
        curr_x <= 'b0;
    end
end

// curr_y
always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        curr_y <= 'b0;
    end
    else if (curr_x == HOR_ACTIVE_VIDEO) begin
        curr_y <= curr_y + 1;
    end
    else if (vs_en) begin
        curr_y <= curr_y;
    end
    else begin
        curr_y <= 'b0;
    end
end

endmodule
