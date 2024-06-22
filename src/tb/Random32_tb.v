`include "Def.v"

module Random32_tb ();

reg clk;
parameter CLOCK_PERIOD = 2;
initial clk = 0;
always #(CLOCK_PERIOD/2) clk = ~clk;

reg rstn;
initial begin
        rstn = 0;
    #8  rstn = 1;
    #50 rstn = 0;
    #2  rstn = 1;
end

reg [31:0] seed;
initial begin
        seed = 32'h4789_FA12;
    #20 seed = 32'h0000_0000;
end

wire [31:0] number;

Random32 random32(
    .clk    (clk),
    .rstn   (rstn),
    .seed   (seed),
    .number (number)
);

endmodule
