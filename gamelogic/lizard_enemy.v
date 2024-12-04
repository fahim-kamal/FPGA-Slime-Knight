`timescale 1ns / 1ps

module lizard_enemy (
    input wire sim_clk,
    input wire reset,
    input wire [19:0] playerPos,      // Player's position {x, y}
    input wire [9:0] lizard_init_x,  // Initial X position of the lizard
    input wire [9:0] lizard_y,       // Y position of the lizard
    input wire [9:0] lizard_width,   // Lizard width
    input wire [9:0] lizard_height,  // Lizard height
    input wire boundary_left,        // Left boundary
    input wire boundary_right,       // Right boundary
    output reg [9:0] lizard_x_out,   // Updated X position of the lizard
    output reg lizard_direction      // Lizard movement direction (0 = left, 1 = right)
);

    parameter LIZARD_SPEED = 1;

    wire [9:0] player_x = playerPos[19:10];
    wire [9:0] player_y = playerPos[9:0];

    // Collision detection with player
    wire lizard_collision_x = (player_x >= lizard_x_out) && (player_x <= lizard_x_out + lizard_width);
    wire lizard_collision_y = (player_y >= lizard_y) && (player_y <= lizard_y + lizard_height);
    wire lizard_collision = lizard_collision_x && lizard_collision_y;

    // Lizard movement logic
    always @(posedge sim_clk or posedge reset) begin
        if (reset) begin
            lizard_x_out <= lizard_init_x;
            lizard_direction <= 1'b1; // Start moving right
        end else if (!lizard_collision) begin
            if (lizard_direction && boundary_right) begin
                lizard_direction <= 1'b0; // Change direction to left
            end else if (!lizard_direction && boundary_left) begin
                lizard_direction <= 1'b1; // Change direction to right
            end

            if (lizard_direction) begin
                lizard_x_out <= lizard_x_out + LIZARD_SPEED; // Move right
            end else begin
                lizard_x_out <= lizard_x_out - LIZARD_SPEED; // Move left
            end
        end
    end

endmodule
