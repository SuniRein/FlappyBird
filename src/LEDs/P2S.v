module P2S
#(
    parameter BIT_WIDTH = 8
)(
    input                 clk,
    input                 start,
    input [BIT_WIDTH-1:0] par_in,
    output                sclk,
    output                sclrn,
    output                sout,
    output                en
);

wire [BIT_WIDTH:0] Q;

wire finish;
wire shiftn_loadp;

SR_Latch latch(
    .S  (start & finish),
    .R  (~finish),
    .Q  (shiftn_loadp),
    .Qn ()
);

ShiftReg #(.BIT_WIDTH(BIT_WIDTH+1)) shift
(
    .clk          (clk),
    .shiftn_loadp (shiftn_loadp),
    .shift_in     (1'b1),
    .par_in       ({1'b0, par_in}),
    .Q            (Q)
);

// assign finish = &Q[BIT_WIDTH-1:0];
assign finish = &Q[BIT_WIDTH:1];

assign en    = !start && finish;
assign sclk  = finish | ~clk;
assign sclrn = 1'b1;
// assign sout  = Q[BIT_WIDTH];
assign sout  = Q[0];

endmodule
