`timescale 1ns / 1ps

module weapon_arrow (
    input wire sim_clk,
    input wire reset,
    input wire fire_button,           // Button to fire the arrow
    input wire [19:0] playerPos,      // Player's position {x, y}
    input wire [9:0] block_x,         // Destroyable block X position
    input wire [9:0] block_y,         // Destroyable block Y position
    input wire [9:0] block_width,     // Block width
    input wire [9:0] block_height,    // Block height
    input wire [9:0] lizard_x,        // Lizard X position
    input wire [9:0] lizard_y,        // Lizard Y position
    input wire [9:0] lizard_width,    // Lizard width
    input wire [9:0] lizard_height,   // Lizard height
    output reg arrow_active,          // Arrow is active
    output reg [19:0] arrowPos,       // Arrow's position {x, y}
    output reg block_defeated,        // Block defeated
    output reg lizard_defeated        // Lizard defeated
);
    parameter ARROW_SPEED = 5;         // Arrow speed

    reg [9:0] arrow_x;
    reg [9:0] arrow_y;

    wire [9:0] player_x = playerPos[19:10];
    wire [9:0] player_y = playerPos[9:0];

    // Collision detection with destroyable block
    wire block_collision_x = (arrow_x >= block_x) && (arrow_x <= block_x + block_width);
    wire block_collision_y = (arrow_y >= block_y) && (arrow_y <= block_y + block_height);
    wire block_collision = block_collision_x && block_collision_y;

    // Collision detection with lizard
    wire lizard_collision_x = (arrow_x >= lizard_x) && (arrow_x <= lizard_x + lizard_width);
    wire lizard_collision_y = (arrow_y >= lizard_y) && (arrow_y <= lizard_y + lizard_height);
    wire lizard_collision = lizard_collision_x && lizard_collision_y;

    // Arrow firing and movement logic
    always @(posedge sim_clk or posedge reset) begin
        if (reset) begin
            arrow_active <= 0;
            block_defeated <= 0;
            lizard_defeated <= 0;
            arrow_x <= 0;
            arrow_y <= 0;
        end else begin
            if (fire_button && !arrow_active) begin
                // Fire the arrow from the player's position
                arrow_active <= 1;
                arrow_x <= player_x;
                arrow_y <= player_y;
            end

            if (arrow_active) begin
                // Move the arrow upward
                arrow_y <= arrow_y - ARROW_SPEED;

                // Deactivate arrow if it goes off-screen
                if (arrow_y < 10'd0) begin
                    arrow_active <= 0;
                end

                // Check for collision with the destroyable block
                if (block_collision) begin
                    block_defeated <= 1;
                    arrow_active <= 0; // Arrow is no longer active after collision
                end

                // Check for collision with the lizard
                if (lizard_collision) begin
                    lizard_defeated <= 1;
                    arrow_active <= 0; // Arrow is no longer active after collision
                end
            end
        end
    end

    // Output the current arrow position
    assign arrowPos = {arrow_x, arrow_y};

endmodule
