`timescale 1ns / 1ps

module destroyable_block (
        input sim_clk,
        input reset,
        input col,
        input [20:0] initBlockState,
        output [20:0] blockState
    );
    reg [9:0] blockX, blockY;
    reg blockVisible;

    // Block state update
    always @(posedge sim_clk) begin
        if (reset) begin
            blockX <= initBlockState[20:11];
            blockY <= initBlockState[10:1];
            blockVisible <= initBlockState[0];
        end

        if (col) begin
            blockVisible <= 1'b0;
            blockX <= 10'b0;
            blockY <= 10'b0;
        end
    end

    assign blockState = {blockX, blockY, blockVisible};

endmodule
