`timescale 1ns / 1ps

module lizard(
        input sim_clk,
        input reset,
        input [3:0] lizardCol,       // Collision input for lizard
        output [31:0] lizardState    // Lizard state output
    );
    reg [9:0] xPos, yPos;            // Position registers
    reg [4:0] xSpeed;                // Speed register
    reg xDir;                        // Direction register

    localparam left = 1'b0,          // Direction: left
               right = 1'b1;         // Direction: right

    initial
    begin
        xPos = 10'd200;              // Initial x position
        yPos = 10'd150;              // Initial y position
        xSpeed = 5'd3;               // Initial horizontal speed
        xDir = right;                // Initial direction
    end

    wire HOR_COL;                    // Horizontal collision flag

    assign HOR_COL = lizardCol[0] || lizardCol[2];  // Left or right collision

    always @(posedge sim_clk) begin
        if (reset) begin
            // Reset lizard state
            xPos <= 10'd200;
            yPos <= 10'd150;
            xSpeed <= 5'd3;
            xDir <= right;
        end
        else begin
            // Update horizontal position
            xPos <= xDir == left
                 ? xPos - xSpeed
                 : xPos + xSpeed;

            // Horizontal collision handling
            if (HOR_COL) begin
                // Move to grid boundary and reverse direction
                xPos <= xDir == left
                     ? xPos - xSpeed + (32 - ((xPos - xSpeed) & 31))
                     : xPos + xSpeed - ((xPos + xSpeed) & 31) - 1;

                xDir <= ~xDir;  // Reverse direction
            end
        end
    end

    // Combine lizard state into a single output
    assign lizardState = {xPos, yPos, xSpeed, 5'b0, xDir, 1'b0};

endmodule
