`timescale 1ns / 1ps

task align_to_grid;
    input [5:0] row, col; // one indexed from top left
    output [9:0] xPos, yPos;
    localparam LEFT = 144;
    localparam TOP = 35;
    begin
        xPos = ((col - 1) << 5) + LEFT;
        yPos = ((row - 1) << 5) + TOP + 31;
    end
endtask

module game_controller(
        input sim_clk,
        input reset,
        output [31:0] initPlayerState,
        output [31:0] initLizardState,
        output [20:0] initBlockState,
        output reg [2:0] level_num
    );

    localparam level1 = 3'd0,
               level2 = 3'd1,
               level3 = 3'd2,
               level4 = 3'd3,
               level5 = 3'd4;

    reg [2:0] state;

    initial begin
        state = level1;
    end

    reg [9:0] player_xPos, player_yPos;
    reg [4:0] player_xSpeed, player_ySpeed;
    reg player_xDir, player_yDir;

    reg [9:0] lizard_xPos, lizard_yPos;
    reg [4:0] lizard_xSpeed;
    reg lizard_xDir, lizard_yDir;

    reg [9:0] blockX, blockY;
    reg blockVisible;

    always @(posedge sim_clk) begin
        if (reset) begin
            case (state)
                level1: begin
                    align_to_grid(2, 2, player_xPos, player_yPos);
                    player_xSpeed = 5'd4;
                    player_ySpeed = 5'd0;
                    player_xDir = 1'b1;
                    player_yDir = 1'b0;

                    align_to_grid(5, 7, lizard_xPos, lizard_yPos);
                    lizard_xSpeed = 5'd3;
                    lizard_xDir = 1'b1;

                    align_to_grid(3, 6, blockX, blockY);
                    blockVisible <= 1'b1;
                end
            endcase

        end
    end

    assign initPlayerState = {player_xPos, player_yPos, player_xSpeed, player_ySpeed, player_xDir, player_yDir};
    assign initLizardState = {lizard_xPos, lizard_yPos, lizard_xSpeed, 5'b0, lizard_xDir, 1'b0};
    assign initBlockState = {blockX, blockY, blockVisible};
endmodule
