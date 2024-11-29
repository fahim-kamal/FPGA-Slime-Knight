`timescale 1ns / 1ps

module display_controller(
        input clk,
        input frameStart,
        input bright,
        input [9:0] hCount, vCount,

        // player state
        input [19:0] playerPos,
        input [3:0] playerCol,

        // level state
        input [2:0] blockType,

        output reg [11:0] rgb
    );
    // default colors
    parameter BLACK = 12'b0000_0000_0000;
    parameter RAND = 12'b1101_1010_1101;
    parameter GREEN = 12'b0000_1111_0000;
    parameter RED = 12'b0011_0000_0000;

    reg [9:0] playerX;
    reg [9:0] playerY;

    always @(posedge clk)
    begin
        if (frameStart)
        begin
            playerX <= playerPos[19:10];
            playerY <= playerPos[9:0];
        end
    end


    wire PLAYER_ZONE;
    assign PLAYER_ZONE = (hCount >= playerX && hCount <= playerX + 31) &&
           (vCount >= playerY - 31 && vCount <= playerY);

    // get the appropriate block

    // painting
    always @(*)
    begin
        if (~bright)
            rgb = BLACK;
        else if (PLAYER_ZONE) begin
            rgb = RAND;
            if (playerCol[2] == 1 || playerCol[0] == 1)
                rgb = GREEN;
        end
        else if (blockType == 0)
            rgb = 12'b1111_0000_0000;
        else if (blockType == 1)
            rgb = 12'b0000_0000_1111;
        else
            rgb = GREEN;
    end

endmodule
