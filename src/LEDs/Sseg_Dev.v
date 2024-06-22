module Sseg_Dev(
    input clk,
    input start,
    input [31:0] hexs,
    input [7:0] points,
    input [7:0] LEs,
    output sclk,
    output sclrn,
    output sout,
    output EN
);

wire [63:0] data;

HexsTo8Seg hexs_to_seg(
    .hexs     (hexs),
    .points   (points),
    .LEs      (LEs),
    .seg_data (data)
);

P2S #(.BIT_WIDTH(64)) p2s(
    .clk    (clk),
    .start  (start),
    .par_in (data),
    .sclk   (sclk),
    .sclrn  (sclrn),
    .sout   (sout),
    .en     (EN)
);

endmodule
