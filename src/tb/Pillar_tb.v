`include "Def.v"
`timescale 1ns / 1ps

module Pillar_tb();

reg clk;
parameter CLOCK_PERIOD = 2;
initial clk = 0;
always #(CLOCK_PERIOD/2) clk = ~clk;

reg frame_clk;
parameter FRAME_PERIOD = 20;
initial frame_clk = 0;
always #(FRAME_PERIOD/2) frame_clk = ~frame_clk;

reg rstn;
initial begin
        rstn = 1'b0;
    #10 rstn = 1'b1;
end

`PosXR x;
`PosYR y;

wire        is_pillar;
wire [11:0] color;
`Score      score;

localparam PILLAR_COUNT = 5;

Pillar #(
    .PILLAR_COUNT   (PILLAR_COUNT),
    .BIRD_X         (100),
    .PILLAR_X_INIT  (120),
    .PILLAR_Y_INIT  (150),
    .PILLAR_X_WIDTH (30),
    .PILLAR_Y_WIDTH (100),
    .PILLAR_GAP     (30),
    .PILLAR_SPEED   (3)
) pillars (
    .clk       (clk),
    .rstn      (rstn),
    .frame_clk (frame_clk),
    .state     (`GAME_RUNNING),
    .x         (x),
    .y         (y),
    .is_pillar (is_pillar),
    .color     (color),
    .score     (score)
);

`PosX pillar_x [PILLAR_COUNT-1:0]; 
`PosY pillar_y [PILLAR_COUNT-1:0];

generate
    for (genvar i = 0; i != PILLAR_COUNT; i = i + 1) begin
        assign pillar_x[i] = pillars.pillar_x[i];
        assign pillar_y[i] = pillars.pillar_y[i];
    end
endgenerate

initial begin
end

endmodule
