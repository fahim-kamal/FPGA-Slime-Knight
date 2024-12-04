`timescale 1ns / 1ps

module destroyable_block (
    input wire sim_clk,
    input wire reset,
    input wire [19:0] playerPos,    // Player's position {x, y}
    input wire [9:0] block_x,      // Block X position
    input wire [9:0] block_y,      // Block Y position
    input wire [9:0] block_width,  // Block width
    input wire [9:0] block_height, // Block height
    output reg block_visible       // Visibility of the block
);

    wire [9:0] player_x = playerPos[19:10];
    wire [9:0] player_y = playerPos[9:0];

    // Collision detection
    wire block_collision_x = (player_x >= block_x) && (player_x <= block_x + block_width);
    wire block_collision_y = (player_y >= block_y) && (player_y <= block_y + block_height);
    wire block_collision = block_collision_x && block_collision_y;

    // Block state update
    always @(posedge sim_clk or posedge reset) begin
        if (reset) begin
            block_visible <= 1'b1; // Reset: Block is visible
        end else if (block_collision) begin
            block_visible <= 1'b0; // Block is destroyed on collision with player
        end
    end

endmodule
