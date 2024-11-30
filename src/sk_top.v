`timescale 1ns / 1ps

module sk_top(
        input ClkPort,

        // Player IO
        input BtnL, BtnD,

        // VGA Signal
        output hSync, vSync,
        output [3:0] vgaR, vgaB, vgaG,

        output QuadSpiFlashCS
    );
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
    wire [31:0] pState;
    wire [3:0] pCol;

    // collision detector
    wire playerBlockType;
    wire [9:0] colX, colY;
    collision_resolver cr(.clk(ClkPort),
                          .sim_clk(sim_clk),
                          .playerState(pState),
                          .playerCol(pCol),
                          .blockType(playerBlockType),
                          .x(colX),
                          .y(colY));

    // level
    wire displayBlockType;
    level lvl(.x1(hc),
              .y1(vc),
              .data1(displayBlockType),
              .x2(colX),
              .y2(colY),
              .data2(playerBlockType));

    // player
    player p(.sim_clk(sim_clk),
             .reset(BtnD),
             .jump_r(jump_r),
             .playerCol(pCol),
             .playerState(pState));

    // display
    vga_controller vctrl(.clk(ClkPort),
                         .frameStart(fs),
                         .hSync(hSync), .vSync(vSync),
                         .bright(bright), .hCount(hc), .vCount(vc));

    display_controller dctrl(.clk(ClkPort),
                             .frameStart(fs),
                             .hCount(hc), .vCount(vc),
                             .bright(bright), .rgb(rgb),
                             .playerPos(pState[31:12]),
                             .playerCol(pCol),
                             .blockType(displayBlockType));

    assign vgaR = rgb[11 : 8];
    assign vgaG = rgb[7  : 4];
    assign vgaB = rgb[3  : 0];

    // disable memory port
    assign {QuadSpiFlashCS} = 1'b1;
endmodule
