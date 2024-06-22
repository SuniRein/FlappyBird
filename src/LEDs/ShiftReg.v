module ShiftReg
#(
    parameter BIT_WIDTH = 8
)(
    input                  clk,
    input                  shiftn_loadp, // 控制信号，在低电平时进行移位操作，在高电平时进行并行数据读入
    input                  shift_in,
    input  [BIT_WIDTH-1:0] par_in, // 八位并行输入数据
    output [BIT_WIDTH-1:0] Q // 并行输出数据
);

reg [BIT_WIDTH-1:0] Q_reg;

always @(posedge clk) begin
    if (shiftn_loadp) begin
        Q_reg <= par_in;
    end
    else begin
        // Q_reg <= {Q[BIT_WIDTH-2:0], shift_in};
        Q_reg <= {shift_in, Q_reg[BIT_WIDTH-1:1]};
    end
end

assign Q = Q_reg;

endmodule
