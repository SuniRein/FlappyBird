`timescale 1ns / 1ps

module ClockDiv_tb();

reg clk, rstn;

parameter CLOCK_PERIOD = 10;
initial clk = 0;
always #(CLOCK_PERIOD/2) clk = ~clk;

initial begin
       rstn = 1'b0;
    #8 rstn = 1'b1;
end

wire clk1;

ClockDiv #(.OUTPUT_CLOCK_FLUENCY(50_000_000)) clk_div1(
    .clk     (clk),
    .rstn    (rstn),
    .clk_div (clk1)
);

wire clk2;

ClockDiv #(.OUTPUT_CLOCK_FLUENCY(10_000_000)) clk_div2(
    .clk     (clk),
    .rstn    (rstn),
    .clk_div (clk2)
);

endmodule
