`timescale 1ns / 1ps

module sk_top(
        input ClkPort,

        // Player IO
        input BtnL, BtnR, BtnD,

        // Debug
        input Sw0, Sw1, Sw2, Sw3, Sw4, Sw5, Sw6, Sw7,

        // VGA Signal
        output hSync, vSync,
        output [3:0] vgaR, vgaB, vgaG,

        output QuadSpiFlashCS
    );
    // debug
    wire [7:0] adjustableValue;
    assign adjustableValue = {Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0};


    // vga state
    wire fs;
    wire bright;
    wire [9:0] hc, vc;
    wire [11:0] rgb;

    // clk
    wire sim_clk;
    clk sc(.ClkPort(ClkPort), .sim_clk(sim_clk));

    // user input
    wire jump_r;
    assign jump_r = BtnL;

    // game state
    wire [2:0] level_num;

    wire [31:0] initPlayerState;
    wire [31:0] pState;
    wire [3:0] pCol;
    wire playerKill;
    wire playerDead;
    wire playerWin;

    wire [26:0] bState;
    wire bCol;

    wire [31:0] initLizardState;
    wire [31:0] lizardState;
    wire [1:0] lizardCol;
    wire lizardKillCol;

    wire blockCol;
    wire [20:0] initBlockState;
    wire [20:0] blockState;

    wire [31:0] initCampfireState;
    wire [31:0] campfireState;

    // reset
    wire nextLevel;
    wire reset;
    assign reset = playerDead || BtnD || nextLevel;

    // core game logic
    game_controller gc(.sim_clk(sim_clk),
                       .reset(reset),
                       .initPlayerState(initPlayerState),
                       .initLizardState(initLizardState),
                       .initBlockState(initBlockState),
                       .initCampfireState(initCampfireState),
                       .level_num(level_num),
                       .playerWin(playerWin),
                       .nextLevel(nextLevel)
                      );

    // collision detector
    wire [2:0] playerBlockType;
    wire [2:0] bladeBlockType;
    wire [2:0] lizardBlockType;
    wire [9:0] colX1, colY1, colX2, colY2, colX3, colY3;
    collision_resolver cr(.clk(ClkPort),
                          .sim_clk(sim_clk),
                          .playerState(pState),
                          .playerCol(pCol),
                          .playerKill(playerKill),
                          .playerWin(playerWin),
                          .bladeState(bState),
                          .bladeCol(bCol),
                          .lizardState(lizardState),
                          .lizardCol(lizardCol),
                          .lizardKillCol(lizardKillCol),
                          .blockPos(blockState[20:1]),
                          .blockCol(blockCol),
                          .blockType1(playerBlockType),
                          .x1(colX1),
                          .y1(colY1),
                          .blockType2(bladeBlockType),
                          .x2(colX2),
                          .y2(colY2),
                          .blockType3(lizardBlockType),
                          .x3(colX3),
                          .y3(colY3)
                         );

    // level
    wire [2:0] displayBlockType;
    level lvl(.level_num(level_num),
              .x1(hc),
              .y1(vc),
              .data1(displayBlockType),
              .x2(colX1),
              .y2(colY1),
              .data2(playerBlockType),
              .x3(colX2),
              .y3(colY2),
              .data3(bladeBlockType),
              .x4(colX3),
              .y4(colY3),
              .data4(lizardBlockType));

    // player
    player p(.sim_clk(sim_clk),
             .reset(reset),
             .jump_r(jump_r),
             .playerCol(pCol),
             .initPlayerState(initPlayerState),
             .playerState(pState),
             .playerKill(playerKill),
             .playerDead(playerDead));


    // blade
    blade b(.sim_clk(sim_clk),
            .shoot(BtnR),
            .player_xPos(pState[31:22]),
            .player_yPos(pState[21:12]),
            .player_xSpeed(pState[11:7]),
            .player_xDir(pState[1]),
            .bladeState(bState),
            .bladeCol(bCol));

    // Lizard
    lizard liz(
               .sim_clk(sim_clk),
               .reset(reset),
               .lizardCol(lizardCol),
               .lizardKillCol(lizardKillCol),
               .initLizardState(initLizardState),
               .lizardState(lizardState)
           );

    // Campfire
    campfire cf(
                 .sim_clk(sim_clk),
                 .reset(reset),
                 .initCampfireState(initCampfireState),
                 .campfireState(campfireState)
             );

    // Destroyable Block
    destroyable_block db(.sim_clk(sim_clk),
                         .reset(reset),
                         .col(blockCol),
                         .initBlockState(initBlockState),
                         .blockState(blockState)
                        );

    // display
    vga_controller vctrl(.clk(ClkPort),
                         .frameStart(fs),
                         .hSync(hSync), .vSync(vSync),
                         .bright(bright), .hCount(hc), .vCount(vc));

    // Display Controller
    display_controller dctrl(
                           .clk(ClkPort),
                           .frameStart(fs),
                           .hCount(hc),
                           .vCount(vc),
                           .bright(bright),
                           .rgb(rgb),

                           // Player
                           .playerPos(pState[31:12]),
                           .playerCol(pCol),

                           // Blade
                           .bladePos(bState[26:7]),

                           // Level
                           .blockType(displayBlockType),

                           // Lizard
                           .lizardPos(lizardState[31:12]),

                           // Campfire
                           .campfirePos(campfireState[31:12]),

                           // Destroyable Block
                           .blockPos(blockState[20:1]),
                           .isBlockVisible(blockState[0])
                       );

    assign vgaR = rgb[11 : 8];
    assign vgaG = rgb[7  : 4];
    assign vgaB = rgb[3  : 0];

    // disable memory port
    assign {QuadSpiFlashCS} = 1'b1;
endmodule
