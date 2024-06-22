`include "Def.v"

module Keyboard(
    input        clk,
    input        rstn,
    input        PS2_clk,
    input        PS2_data,
    output `KeyR key,
    output reg   key_state
);

reg [2:0] PS2_clk_flag;
wire negedge_PS2_clk = !PS2_clk_flag[1] && PS2_clk_flag[2];
reg negedge_PS2_clk_shift;

always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        PS2_clk_flag[0] <= 'b0;
        PS2_clk_flag[1] <= 'b0;
        PS2_clk_flag[2] <= 'b0;
    end
    else begin
        PS2_clk_flag[0] <= PS2_clk;
        PS2_clk_flag[1] <= PS2_clk_flag[0];
        PS2_clk_flag[2] <= PS2_clk_flag[1];
    end
end

always @(posedge clk) begin
    negedge_PS2_clk_shift <= negedge_PS2_clk;
end

reg [3:0] num;

always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        num <= 'd0;
    end
    else if (num == 4'd11) begin
        num <= 'd0;
    end
    else if (negedge_PS2_clk) begin
        num <= num + 1'd1;
    end
    else begin
        num <= num;
    end
end

reg [7:0] temp_data;

always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        temp_data <= 'b0;
    end
    else if (negedge_PS2_clk_shift) begin
        case (num)
            4'd2: temp_data[0] <= PS2_data;
            4'd3: temp_data[1] <= PS2_data;
            4'd4: temp_data[2] <= PS2_data;
            4'd5: temp_data[3] <= PS2_data;
            4'd6: temp_data[4] <= PS2_data;
            4'd7: temp_data[5] <= PS2_data;
            4'd8: temp_data[6] <= PS2_data;
            4'd9: temp_data[7] <= PS2_data;
            default: temp_data <= temp_data;
        endcase
    end
    else begin
        temp_data <= temp_data;
    end
end

localparam DATA_BREAK  = 8'hF0;
localparam DATA_EXPAND = 8'hE0;

reg data_break, data_done, data_expand;
reg [9:0] data;

always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        data        <= 'b0;
        data_done   <= 'b0;
        data_expand <= 'b0;
        data_break  <= 'b0;
    end
    else if (num == 4'd11) begin
        if (temp_data == DATA_EXPAND) begin
            data        <= data;
            data_done   <= 1'b0;
            data_expand <= 1'b1;
            data_break  <= data_break;
        end
        else if (temp_data == DATA_BREAK) begin
            data        <= data;
            data_done   <= 1'b0;
            data_expand <= data_expand;
            data_break  <= 1'b1;
        end
        else begin
            data        <= {data_break, data_expand, temp_data};
            data_expand <= 1'b0;
            data_break  <= 1'b0;
            data_done   <= 1'b1;
        end
    end
    else begin
        data        <= data;
        data_done   <= 1'b0;
        data_break  <= data_break;
        data_expand <= data_expand;
    end
end

localparam DATA_UP    = {1'b1, 8'h75};
localparam DATA_DOWN  = {1'b1, 8'h72};
localparam DATA_LEFT  = {1'b1, 8'h6B};
localparam DATA_RIGHT = {1'b1, 8'h74};
localparam DATA_SPACE = {1'b0, 8'h29};

always @(posedge clk) begin
    if (data_done) begin
        key_state <= ~data[9];

        case (data[8:0])
            DATA_UP   : key <= `KEY_UP   ;
            DATA_DOWN : key <= `KEY_DOWN ;
            DATA_LEFT : key <= `KEY_LEFT ;
            DATA_RIGHT: key <= `KEY_RIGHT;
            DATA_SPACE: key <= `KEY_SPACE;
            default   : key <= `NO_KEY   ;
        endcase
    end
end

endmodule
