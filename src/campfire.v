`timescale 1ns / 1ps

module campfire(
        input sim_clk,
        input reset,
        input [31:0] initCampfireState,
        output [31:0] campfireState    // Campfire state output
    );
    reg [9:0] xPos, yPos;              // Position registers

    initial
    begin
        // Initial position of the campfire
        xPos = 10'd250;                // Set initial x position
        yPos = 10'd180;                // Set initial y position
    end

    always @(posedge sim_clk) begin
        if (reset) begin
            // Reset the campfire's position to its initial state
            xPos <= initCampfireState[31:22];
            yPos <= initCampfireState[21:12];
        end
    end

    // Combine campfire state into a single output
    assign campfireState = {xPos, yPos, 12'b0}; // Padding unused bits with 0
endmodule
