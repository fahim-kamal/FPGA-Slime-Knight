`timescale 1ns / 1ps

module campfire (
    input wire sim_clk,
    input wire reset,
    input wire [19:0] playerPos,     // Player's position {x, y}
    input wire [9:0] campfire_x,     // Campfire X position
    input wire [9:0] campfire_y,     // Campfire Y position
    input wire [9:0] campfire_width, // Campfire width
    input wire [9:0] campfire_height // Campfire height
);
    wire [9:0] player_x = playerPos[19:10];
    wire [9:0] player_y = playerPos[9:0];

    // Collision detection with player
    wire campfire_collision_x = (player_x >= campfire_x) && (player_x <= campfire_x + campfire_width);
    wire campfire_collision_y = (player_y >= campfire_y) && (player_y <= campfire_y + campfire_height);
    wire campfire_collision = campfire_collision_x && campfire_collision_y;

    // Placeholder: Add effects or behaviors for collision with the player here
    always @(posedge sim_clk or posedge reset) begin
        if (reset) begin
            // Reset any state here if needed
        end else if (campfire_collision) begin
            // Define behavior on collision
        end
    end

endmodule
