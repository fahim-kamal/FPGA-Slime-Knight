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

// Display module for the blade
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

// Display module for the foreground block
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

// Display module for the half slab
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

// Display module for the door
module display_door(
        input [2:0] blockType,
        output doorZone,
        output [11:0] rgb
    );
    localparam DOOR_ID = 3;
    assign doorZone = blockType == 3;

    localparam BROWN = 12'h630;
    assign rgb = BROWN;
endmodule

// Display module for the lizard enemy
module display_lizard(
        input [9:0] x, y, lizardX, lizardY,
        output lizardZone,
        output [11:0] rgb
    );
    localparam LIZARD_WIDTH = 30,
               LIZARD_HEIGHT = 15;

    assign lizardZone = (x >= lizardX && x <= (lizardX + LIZARD_WIDTH - 1))
           && (y >= lizardY && y <= (lizardY + LIZARD_HEIGHT - 1));

    localparam ORANGE = 12'hFA5;
    assign rgb = ORANGE;
endmodule

// Display module for the destroyable block
module display_destroyable_block(
        input [9:0] x, y, blockX, blockY,
        input blockVisible,
        output blockZone,
        output [11:0] rgb
    );
    localparam BLOCK_SIZE = 32;

    assign blockZone = blockVisible &&
           (x >= blockX && x <= (blockX + BLOCK_SIZE - 1))
           && (y >= blockY && y <= (blockY + BLOCK_SIZE - 1));

    localparam PURPLE = 12'h905;
    assign rgb = PURPLE;
endmodule

// Display module for the campfire enemy
module display_campfire(
        input [9:0] x, y, campfireX, campfireY,
        output campfireZone,
        output [11:0] rgb
    );
    localparam CAMPFIRE_WIDTH = 20,
               CAMPFIRE_HEIGHT = 20;

    assign campfireZone = (x >= campfireX && x <= (campfireX + CAMPFIRE_WIDTH - 1))
           && (y >= campfireY && y <= (campfireY + CAMPFIRE_HEIGHT - 1));

    localparam FLAME = 12'hF30;
    assign rgb = FLAME;
endmodule

// Display controller module
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

        // lizard state
        input [19:0] lizardPos,

        // destroyable block state
        input [19:0] blockPos,
        input blockVisible,

        // campfire state
        input [19:0] campfirePos,

        output reg [11:0] rgb
    );
    // Default colors
    parameter BLACK = 12'b0000_0000_0000;
    parameter RAND = 12'b1101_1010_1101;
    parameter GREEN = 12'b0000_1111_0000;
    parameter RED = 12'b0011_0000_0000;
    parameter GRAY = 12'b1111_1111_1111;
    parameter ORANGE = 12'b1111_1010_0000;


    reg [9:0] playerX, playerY;
    reg [9:0] bladeX, bladeY;
    reg [9:0] lizardX, lizardY;
    reg [9:0] blockX, blockY;
    reg [9:0] campfireX, campfireY;

    always @(posedge clk)
    begin
        if (frameStart)
        begin
            playerX <= playerPos[19:10];
            playerY <= playerPos[9:0];
            bladeX <= bladePos[19:10];
            bladeY <= bladePos[9:0];
            lizardX <= lizardPos[19:10];
            lizardY <= lizardPos[9:0];
            blockX <= blockPos[19:10];
            blockY <= blockPos[9:0];
            campfireX <= campfirePos[19:10];
            campfireY <= campfirePos[9:0];
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

    wire DOOR_ZONE;
    wire [11:0] DOOR_RGB;
    display_door d_d(.blockType(blockType),
                     .doorZone(DOOR_ZONE),
                     .rgb(DOOR_RGB));

    // Added display modules
    wire LIZARD_ZONE, BLOCK_ZONE, CAMPFIRE_ZONE;
    wire [11:0] LIZARD_RGB, BLOCK_RGB, CAMPFIRE_RGB;

    display_lizard d_l(.x(hCount), .y(vCount), .lizardX(lizardX), .lizardY(lizardY),
                       .lizardZone(LIZARD_ZONE), .rgb(LIZARD_RGB));

    display_destroyable_block d_db(.x(hCount), .y(vCount), .blockX(blockX), .blockY(blockY),
                                   .blockVisible(blockVisible), .blockZone(BLOCK_ZONE),
                                   .rgb(BLOCK_RGB));

    display_campfire d_cf(.x(hCount), .y(vCount), .campfireX(campfireX), .campfireY(campfireY),
                          .campfireZone(CAMPFIRE_ZONE), .rgb(CAMPFIRE_RGB));

    // Painting
    always @(*)
    begin
        if (~bright)
            rgb = BLACK;
        else if (BLADE_ZONE)
            rgb = BLADE_RGB;
        else if (PLAYER_ZONE)
            rgb = PLAYER_RGB;
        else if (LIZARD_ZONE)
            rgb = LIZARD_RGB;
        else if (BLOCK_ZONE)
            rgb = BLOCK_RGB;
        else if (CAMPFIRE_ZONE)
            rgb = CAMPFIRE_RGB;
        else if (FOREGROUND_BLOCK_ZONE)
            rgb = FOREGROUND_BLOCK_RGB;
        else if (HALF_SLAB_ZONE)
            rgb = HALF_SLAB_RGB;
        else if (DOOR_ZONE)
            rgb = DOOR_RGB;
        else
            rgb = GRAY;
    end

endmodule
