module Random32(
    input        clk,
    input        rstn,
    input [31:0] seed,

    output [31:0] number
);

reg [31:0] rand32;

always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        rand32 <= seed;
    end
    else begin
        rand32 <= rand32 ^ (rand32 << 13) ^ (rand32 >> 17) ^ (rand32 << 5);
    end
end

assign number = rand32;

endmodule
