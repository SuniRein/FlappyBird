`timescale 1ns / 1ps

module ROM_tb();

reg clk;
parameter CLOCK_PERIOD = 10;
initial clk = 0;
always #(CLOCK_PERIOD/2) clk = ~clk;

reg [18:0] addr;
wire [11:0] color;

Background rom(
    .clka  (clk),
    .ena   (1'b1),
    .addra (addr),
    .douta (color)
);

initial begin
                   addr <= 0;
    @(posedge clk) addr <= 1;
    @(posedge clk) addr <= 2;
    @(posedge clk) addr <= 3;
end

endmodule
