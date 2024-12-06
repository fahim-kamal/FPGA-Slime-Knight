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
        input playerWin,
        output [31:0] initPlayerState,
        output [31:0] initLizardState,
        output [20:0] initBlockState,
        output [31:0] initCampfireState,
        output reg [2:0] level_num,
        output reg nextLevel
    );

    localparam level1 = 3'd0,
               level2 = 3'd1,
               level3 = 3'd2,
               level4 = 3'd3;

    localparam LVL_MAX = 3'd3;

    reg [2:0] state;

    initial begin
        state = level1;
        level_num = 2'd0;
        nextLevel = 0;
    end

    reg [9:0] player_xPos, player_yPos;
    reg [4:0] player_xSpeed, player_ySpeed;
    reg player_xDir, player_yDir;

    reg [9:0] lizard_xPos, lizard_yPos;
    reg [4:0] lizard_xSpeed;
    reg lizard_xDir, lizard_yDir;

    reg [9:0] blockX, blockY;
    reg blockVisible;

    reg [9:0] campfireX, campfireY;

    always @(posedge sim_clk) begin
        if (playerWin) begin
            nextLevel <= 1; // force a reset
            level_num <= level_num == LVL_MAX
                      ? 0
                      : level_num + 1;
        end
        else
            nextLevel <= 0;

    end

    always @(posedge sim_clk) begin
        if (reset) begin
            case (state)
                level1: begin
                    align_to_grid(11, 13, player_xPos, player_yPos);
                    player_xSpeed = 5'd4;
                    player_ySpeed = 5'd0;
                    player_xDir = 1'b0;
                    player_yDir = 1'b0;

                    lizard_xPos = 0;
                    lizard_yPos = 0;
                    lizard_xSpeed = 5'd0;
                    lizard_xDir = 1'b1;

                    blockX = 0;
                    blockY = 0;
                    blockVisible <= 1'b0;

                    campfireX = 0;
                    campfireY = 0;
                end
                level2: begin
                    align_to_grid(13, 6, player_xPos, player_yPos);
                    player_xSpeed = 5'd4;
                    player_ySpeed = 5'd0;
                    player_xDir = 1'b0;
                    player_yDir = 1'b0;

                    lizard_xPos = 0;
                    lizard_yPos = 0;
                    lizard_xSpeed = 5'd0;
                    lizard_xDir = 1'b1;

                    blockX = 0;
                    blockY = 0;
                    blockVisible <= 1'b0;

                    campfireX = 0;
                    campfireY = 0;
                end
                level3:  begin
                    align_to_grid(14, 2, player_xPos, player_yPos);
                    player_xSpeed = 5'd4;
                    player_ySpeed = 5'd0;
                    player_xDir = 1'b1;
                    player_yDir = 1'b0;

                    align_to_grid(11, 6, lizard_xPos, lizard_yPos);
                    lizard_xSpeed = 5'd3;
                    lizard_xDir = 1'b1;

                    align_to_grid(5, 14, blockX, blockY);
                    blockVisible <= 1'b0;

                    campfireX = 0;
                    campfireY = 0;
                end
                level4: begin
                    align_to_grid(5, 4, player_xPos, player_yPos);
                    player_xSpeed = 5'd4;
                    player_ySpeed = 5'd0;
                    player_xDir = 1'b0;
                    player_yDir = 1'b0;

                    align_to_grid(14, 3, lizard_xPos, lizard_yPos);
                    lizard_xSpeed = 5'd3;
                    lizard_xDir = 1'b1;

                    align_to_grid(4, 16, blockX, blockY);
                    blockVisible <= 1'b0;

                    campfireX = 0;
                    campfireY = 0;

                end
            endcase

        end
    end

    assign initPlayerState = {player_xPos, player_yPos, player_xSpeed, player_ySpeed, player_xDir, player_yDir};
    assign initLizardState = {lizard_xPos, lizard_yPos, lizard_xSpeed, 5'b0, lizard_xDir, 1'b0};
    assign initBlockState = {blockX, blockY, blockVisible};
    assign initCampfireState = {campfireX, campfireY, 12'b0};
endmodule
