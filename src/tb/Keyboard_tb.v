`include "Def.v"
`timescale 1ns / 1ps

module Keyboard_tb();

reg clk;
parameter CLOCK_PERIOD = 2;
initial clk = 0;
always #(CLOCK_PERIOD/2) clk = ~clk;

reg PS2_clk;

reg rstn;
initial begin
        rstn = 1'b0;
    #20 rstn = 1'b1;
end

reg PS2_data;

`Key key;
wire key_state;

Keyboard keyboard(
    .clk       (clk),
    .rstn      (rstn),
    .PS2_clk   (PS2_clk),
    .PS2_data  (PS2_data),
    .key       (key),
    .key_state (key_state)
);

localparam DATA_BREAK  = 8'hF0;
localparam DATA_EXPAND = 8'hE0;
localparam DATA_UP     = 8'h75;
localparam DATA_DOWN   = 8'h72;
localparam DATA_LEFT   = 8'h6B;
localparam DATA_RIGHT  = 8'h74;
localparam DATA_SPACE  = 8'h29;

wire [3:0] num = keyboard.num;
wire negedge_PS2_clk = keyboard.negedge_PS2_clk;
wire [2:0] PS2_clk_flag = keyboard.PS2_clk_flag;
wire [7:0] temp_data = keyboard.temp_data;

initial begin
    #20;

    SendData(DATA_SPACE);

    SendData(DATA_EXPAND);
    SendData(DATA_UP);

    SendData(DATA_BREAK);
    SendData(DATA_EXPAND);
    SendData(DATA_UP);

    SendData(DATA_BREAK);
    SendData(DATA_SPACE);

    #100 $finish;
end

localparam PS2_CLOCK_PERIOD = 20;

task SendData;
    input [7:0] data;
begin
    #(PS2_CLOCK_PERIOD/2); PS2_clk = 1; #(PS2_CLOCK_PERIOD/2) PS2_clk = 0; PS2_data = 0;
    #(PS2_CLOCK_PERIOD/2); PS2_clk = 1; #(PS2_CLOCK_PERIOD/2) PS2_clk = 0; PS2_data = data[0];
    #(PS2_CLOCK_PERIOD/2); PS2_clk = 1; #(PS2_CLOCK_PERIOD/2) PS2_clk = 0; PS2_data = data[1];
    #(PS2_CLOCK_PERIOD/2); PS2_clk = 1; #(PS2_CLOCK_PERIOD/2) PS2_clk = 0; PS2_data = data[2];
    #(PS2_CLOCK_PERIOD/2); PS2_clk = 1; #(PS2_CLOCK_PERIOD/2) PS2_clk = 0; PS2_data = data[3];
    #(PS2_CLOCK_PERIOD/2); PS2_clk = 1; #(PS2_CLOCK_PERIOD/2) PS2_clk = 0; PS2_data = data[4];
    #(PS2_CLOCK_PERIOD/2); PS2_clk = 1; #(PS2_CLOCK_PERIOD/2) PS2_clk = 0; PS2_data = data[5];
    #(PS2_CLOCK_PERIOD/2); PS2_clk = 1; #(PS2_CLOCK_PERIOD/2) PS2_clk = 0; PS2_data = data[6];
    #(PS2_CLOCK_PERIOD/2); PS2_clk = 1; #(PS2_CLOCK_PERIOD/2) PS2_clk = 0; PS2_data = data[7];
    #(PS2_CLOCK_PERIOD/2); PS2_clk = 1; #(PS2_CLOCK_PERIOD/2) PS2_clk = 0; PS2_data = 1;
    #(PS2_CLOCK_PERIOD/2); PS2_clk = 1; #(PS2_CLOCK_PERIOD/2) PS2_clk = 0; PS2_data = 0;
end
endtask

endmodule
