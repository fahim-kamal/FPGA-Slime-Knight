`timescale 1ns / 1ps

module display_player(
        input [9:0] x, y, playerX, playerY,
        // input [3:0] playerCol,
        output playerZone,
        output [11:0] rgb
    );
    localparam PLAYER_SIZE = 32;

    assign playerZone = (x >= playerX && x <= (playerX + PLAYER_SIZE - 1))
           && (y >= (playerY - (PLAYER_SIZE - 1)) && y <= playerY);

    // wire VERT_COL;
    // assign VERT_COL = playerCol[3] || playerCol[1];

    localparam RED = 12'b1111_0000_0000;
    // localparam BLUE = 12'b0000_0000_1111;
    // assign rgb = VERT_COL ? BLUE : RED;
    assign rgb = RED;
endmodule

module display_blade(
        input [9:0] x, y, bladeX, bladeY,
        output bladeZone,
        output [11:0] rgb
    );

    localparam BLADE_WIDTH = 28,
               BLADE_HEIGHT = 16;

    assign bladeZone = (x >= bladeX && x <= (bladeX + BLADE_WIDTH - 1))
           && (y >= (bladeY - (BLADE_HEIGHT - 1)) && y <= bladeY);

    localparam CYAN = 12'h6DF;
    assign rgb = CYAN;
endmodule

module display_foreground_block(
        input [2:0] blockType,
        output foregroundBlockZone,
        output [11:0] rgb
    );
    localparam FOREGROUND_BLOCK_ID = 1;
    localparam BLUE = 12'b0000_0000_1111;

    assign foregroundBlockZone = blockType == FOREGROUND_BLOCK_ID;
    assign rgb = BLUE;
endmodule

module display_half_slab(
        input [9:0] x, y,
        input [2:0] blockType,
        output halfSlabZone,
        output [11:0] rgb
    );
    // only show on the upper half of block
    localparam HALF_SLAB_ID = 2;

    wire isHalfSlab;
    assign isHalfSlab = blockType == HALF_SLAB_ID;

    wire isUpperHalf;
    assign isUpperHalf = ((y - 35) & 31) <= 15;

    assign halfSlabZone = isHalfSlab && isUpperHalf;

    localparam GREEN = 12'b0000_1111_0000;
    assign rgb = GREEN;
endmodule

module display_controller(
        input clk,
        input frameStart,
        input bright,
        input [9:0] hCount, vCount,

        // player state
        input [19:0] playerPos,
        input [3:0] playerCol,

        // blade state
        input [19:0] bladePos,

        // level state
        input [2:0] blockType,

        output reg [11:0] rgb
    );
    // default colors
    parameter BLACK = 12'b0000_0000_0000;
    parameter RAND = 12'b1101_1010_1101;
    parameter GREEN = 12'b0000_1111_0000;
    parameter RED = 12'b0011_0000_0000;
    parameter GRAY = 12'b1111_1111_1111;

    reg [9:0] playerX, playerY;
    reg [9:0] bladeX, bladeY;

    always @(posedge clk)
    begin
        if (frameStart)
        begin
            playerX <= playerPos[19:10];
            playerY <= playerPos[9:0];
            bladeX <= bladePos[19:10];
            bladeY <= bladePos[9:0];
        end
    end


    wire BLADE_ZONE;
    wire [11:0] BLADE_RGB;
    display_blade d_b(.x(hCount),
                      .y(vCount),
                      .bladeX(bladeX),
                      .bladeY(bladeY),
                      .bladeZone(BLADE_ZONE),
                      .rgb(BLADE_RGB)
                     );

    wire PLAYER_ZONE;
    wire [11:0] PLAYER_RGB;
    display_player d_p(
                       .x(hCount),
                       .y(vCount),
                       .playerX(playerX),
                       .playerY(playerY),
                       // .playerCol(playerCol),
                       .playerZone(PLAYER_ZONE),
                       .rgb(PLAYER_RGB)
                   );

    wire FOREGROUND_BLOCK_ZONE;
    wire [11:0] FOREGROUND_BLOCK_RGB;
    display_foreground_block d_fb(.blockType(blockType),
                                  .foregroundBlockZone(FOREGROUND_BLOCK_ZONE),
                                  .rgb(FOREGROUND_BLOCK_RGB));

    wire HALF_SLAB_ZONE;
    wire [11:0] HALF_SLAB_RGB;
    display_half_slab d_hs(
                          .x(hCount),
                          .y(vCount),
                          .blockType(blockType),
                          .halfSlabZone(HALF_SLAB_ZONE),
                          .rgb(HALF_SLAB_RGB)
                      );

    // painting
    always @(*)
    begin
        if (~bright)
            rgb = BLACK;
        else if (BLADE_ZONE)
            rgb = BLADE_RGB;
        else if (PLAYER_ZONE)
            rgb = PLAYER_RGB;
        else if (FOREGROUND_BLOCK_ZONE)
            rgb = FOREGROUND_BLOCK_RGB;
        else if (HALF_SLAB_ZONE)
            rgb = HALF_SLAB_RGB;
        else
            rgb = GRAY;
    end

endmodule
