module MyMC14495(
    input D0, D1, D2, D3, // 4位输入信号，高电平有效
    input LE, // 使能信号，低电平有效
    input point, // 小数点信号，高电平有效
    output reg p,
    output reg a, b, c, d, e, f, g // 输出信号，低电平有效
);

always @(*) begin
    if (LE) begin // 使能高电平，无效，全部输出高电平
        a = 1'b1;
        b = 1'b1;
        c = 1'b1;
        d = 1'b1;
        e = 1'b1;
        f = 1'b1;
        g = 1'b1;
        p = 1'b1;
    end
    else begin
        p = ~point;

        case ({D3, D2, D1, D0})
            4'h0: begin
                a = 1'b0;
                b = 1'b0;
                c = 1'b0;
                d = 1'b0;
                e = 1'b0;
                f = 1'b0;
                g = 1'b1;
            end

            4'h1: begin
                a = 1'b1;
                b = 1'b0;
                c = 1'b0;
                d = 1'b1;
                e = 1'b1;
                f = 1'b1;
                g = 1'b1;
            end

            4'h2: begin
                a = 1'b0;
                b = 1'b0;
                c = 1'b1;
                d = 1'b0;
                e = 1'b0;
                f = 1'b1;
                g = 1'b0;
            end

            4'h3: begin
                a = 1'b0;
                b = 1'b0;
                c = 1'b0;
                d = 1'b0;
                e = 1'b1;
                f = 1'b1;
                g = 1'b0;
            end

            4'h4: begin
                a = 1'b1;
                b = 1'b0;
                c = 1'b0;
                d = 1'b1;
                e = 1'b1;
                f = 1'b0;
                g = 1'b0;
            end

            4'h5: begin
                a = 1'b0;
                b = 1'b1;
                c = 1'b0;
                d = 1'b0;
                e = 1'b1;
                f = 1'b0;
                g = 1'b0;
            end

            4'h6: begin
                a = 1'b0;
                b = 1'b1;
                c = 1'b0;
                d = 1'b0;
                e = 1'b0;
                f = 1'b0;
                g = 1'b0;
            end

            4'h7: begin
                a = 1'b0;
                b = 1'b0;
                c = 1'b0;
                d = 1'b1;
                e = 1'b1;
                f = 1'b1;
                g = 1'b1;
            end

            4'h8: begin
                a = 1'b0;
                b = 1'b0;
                c = 1'b0;
                d = 1'b0;
                e = 1'b0;
                f = 1'b0;
                g = 1'b0;
            end

            4'h9: begin
                a = 1'b0;
                b = 1'b0;
                c = 1'b0;
                d = 1'b0;
                e = 1'b1;
                f = 1'b0;
                g = 1'b0;
            end

            4'ha: begin
                a = 1'b0;
                b = 1'b0;
                c = 1'b0;
                d = 1'b1;
                e = 1'b0;
                f = 1'b0;
                g = 1'b0;
            end

            4'hb: begin
                a = 1'b1;
                b = 1'b1;
                c = 1'b0;
                d = 1'b0;
                e = 1'b0;
                f = 1'b0;
                g = 1'b0;
            end

            4'hc: begin
                a = 1'b0;
                b = 1'b1;
                c = 1'b1;
                d = 1'b0;
                e = 1'b0;
                f = 1'b0;
                g = 1'b1;
            end

            4'hd: begin
                a = 1'b1;
                b = 1'b0;
                c = 1'b0;
                d = 1'b0;
                e = 1'b0;
                f = 1'b1;
                g = 1'b0;
            end

            4'he: begin
                a = 1'b0;
                b = 1'b1;
                c = 1'b1;
                d = 1'b0;
                e = 1'b0;
                f = 1'b0;
                g = 1'b0;
            end

            4'hf: begin
                a = 1'b0;
                b = 1'b1;
                c = 1'b1;
                d = 1'b1;
                e = 1'b0;
                f = 1'b0;
                g = 1'b0;
            end
        endcase
    end
end

endmodule
