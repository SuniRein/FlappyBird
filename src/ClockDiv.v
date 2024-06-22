module ClockDiv
#(
    parameter INPUT_CLOCK_FLUENCY  = 100_000_000, // 100 MHz
    parameter OUTPUT_CLOCK_FLUENCY =  50_000_000  //  50 MHz
)(
    input clk,
    input rstn,

    output reg clk_div
);

localparam CLOCK_DIV_RATE = INPUT_CLOCK_FLUENCY / OUTPUT_CLOCK_FLUENCY;

reg [31:0] cnt;

always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        cnt     <= 'b0;
        clk_div <= 'b0;
    end
    else begin
        if (cnt == CLOCK_DIV_RATE / 2 - 1) begin
            cnt     <= 'b0;
            clk_div <= ~clk_div;
        end
        else begin
            cnt     <= cnt + 1'b1;
            clk_div <= clk_div;
        end
    end
end

endmodule
