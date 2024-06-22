module clkdiv(
    input               clk,
    input               rstn,
    output reg [31:0]   div_res
);

always @(posedge clk, negedge rstn) begin     // When postive edge of `clk` comes
    if(!rstn) begin
        div_res <= 32'b0;
    end
    else begin
        div_res <= div_res + 32'b1;  // Increase `div_res` by 1
    end
end

endmodule

