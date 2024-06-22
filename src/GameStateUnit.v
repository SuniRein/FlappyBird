`include "Def.v"

module GameStateUnit(
    input clk,
    input rstn,
    input start,
    input failed,
    output `GameStateR state
);

always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        state <= `GAME_INIT;
    end
    else begin
        case (state)
            `GAME_INIT:    state <= start  ? `GAME_RUNNING : `GAME_INIT;
            `GAME_RUNNING: state <= failed ? `GAME_FAILED  : `GAME_RUNNING;
            `GAME_FAILED:  state <= start  ? `GAME_INIT    : `GAME_FAILED;
            default:       state <= `GAME_INIT;
        endcase
    end
end

endmodule
