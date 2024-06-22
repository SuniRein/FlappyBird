`include "Def.v"
`timescale 1ns / 1ps

module VgaDriver_tb();

reg clk;

parameter CLOCK_PERIOD = 10;
initial clk = 0;
always #(CLOCK_PERIOD/2) clk = ~clk;

`PosX curr_x;
`PosY curr_y;

wire [3:0] r, g, b;

wire hs, vs;
wire rdyn;

reg rstn;
initial begin
       rstn = 'b0;
    #8 rstn = 'b1;

    wait(!rdyn);
       rstn = 'b0;
    #8 rstn = 'b1;
end

VgaDriver vga_driver (
    .clk      (clk),
    .rstn     (rstn),
    .color    (12'b1010_0101_1111),
    .r        (r),
    .g        (g),
    .b        (b),
    .curr_x   (curr_x),
    .curr_y   (curr_y),
    .hs       (hs),
    .vs       (vs),
    .rdyn     (rdyn)
);

wire [9:0] cnt_hs = vga_driver.cnt_hs;
wire [9:0] cnt_vs = vga_driver.cnt_vs;

initial begin
    @(posedge rdyn) $stop;
    @(posedge rdyn) $stop;
    @(posedge rdyn) $stop;
    @(posedge rdyn) $stop;
    $finish;
end

endmodule
