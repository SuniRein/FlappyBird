module LEDP2S(
    input clk,
    input start,
    input[15:0] par_in,
    output sclk,
    output sclrn,
    output sout,
    output EN
);

P2S #(.BIT_WIDTH(16)) p2s
(
    .clk    (clk),
    .start  (start),
    .par_in (par_in),
    .sclk   (sclk),
    .sclrn  (sclrn),
    .sout   (sout),
    .en     (EN)
);

endmodule
