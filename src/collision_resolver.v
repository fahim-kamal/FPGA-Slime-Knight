`timescale 1ns / 1ps

/*
    RESOLVERS MUST BE A STATE MACHINE WHICH HAS FOLLOWING STATES: 
      start -> 3'd0
      init -> 3'd1
*/ 

task automatic detect_AABB_collision;
    input [9:0] x1, y1, x2, y2;
    input [9:0] width1, height1, width2, height2;
    output reg col;
    reg AToRightOfB;
    reg AToLeftOfB;
    reg AAboveB;
    reg ABelowB;
    begin
        AToRightOfB = x1 > (x2 + width2 - 1);
        AToLeftOfB = (x1 + width1 - 1) < x2;
        AAboveB = y1 < (y2 - height2 + 1);
        ABelowB = (y1 - height1 + 1) > y2;

        col = !(AToRightOfB || AToLeftOfB || AAboveB || ABelowB);
    end
endtask

module lizard_resolver(
        input clk,
        input en,

        input [9:0] lizard_xPos, lizard_yPos,
        input [4:0] lizard_xSpeed,
        input lizard_xDir,

        input [2:0] blockType,
        output reg [9:0] x, y,

        output reg valid,
        output reg [1:0] col
    );
    localparam LIZARD_WIDTH = 32,
               LIZARD_HEIGHT = 32;

    localparam idle = 2'd0,
               check_left = 2'd1,
               check_right = 2'd2,
               done = 2'd3;

    reg [2:0] state;

    initial begin
        state <= idle;
    end

    reg [9:0] nextX;
    reg collided;

    always @(posedge clk) begin
        case (state)
            idle: begin
                if (en) begin
                    col <= 0;
                    valid <= 0;

                    nextX = lizard_xDir == 1'b0
                    ? lizard_xPos - lizard_xSpeed
                    : lizard_xPos + lizard_xSpeed;

                    x <= nextX;
                    y <= lizard_yPos;

                    state <= check_left;
                end
            end
            check_left: begin
                state <= check_right;
                x <= nextX + (LIZARD_WIDTH - 1);
                y <= lizard_yPos;
            end
            check_right: begin
                state <= done;
                valid <= 1;
            end
            done: begin
                if (!en)
                    state <= idle;
            end
        endcase


        if (state >= check_left && state <= check_right) begin
            case (blockType)
                3'd1: collided = 1;
                3'd4: collided = 1;
                default: collided = 0;
            endcase

            if (collided)
                if (lizard_xDir == 1'b0)
                    col[1] <= 1;
                else
                    col[0] <= 1;
        end
    end
endmodule

module blade_resolver(
        input clk,
        input en,

        input [9:0] blade_xPos, blade_yPos,
        input [4:0] blade_xSpeed,
        input blade_xDir,

        input [9:0] block_xPos, block_yPos,
        output reg blockCol,

        input [9:0] lizard_xPos, lizard_yPos,
        output reg lizardKillCol,

        // enviornment
        input [2:0] blockType,
        output reg [9:0] x, y,

        output reg valid,
        output reg col
    );
    // blade dim
    localparam BLADE_WIDTH = 28,
               BLADE_HEIGHT = 16;

    // states
    localparam idle = 3'd0,
               check_bl = 3'd1,
               check_ul = 3'd2,
               check_ur = 3'd3,
               check_br = 3'd4,
               done = 3'd5;

    reg [2:0] state;

    initial begin
        state = idle;
    end

    reg [9:0] bNextX;

    reg collided;
    reg collidedWithBlock;
    reg collidedWithLizard;

    always @(posedge clk) begin
        case (state)
            idle: begin
                if (en) begin
                    col <= 0;
                    blockCol <= 0;
                    lizardKillCol <= 0;
                    valid <= 0;

                    bNextX = blade_xDir == 1'b0
                    ? blade_xPos - blade_xSpeed
                    : blade_xPos + blade_xSpeed;

                    x <= bNextX;
                    y <= blade_yPos;  // remains same

                    state <= check_bl;
                end
            end
            check_bl: begin
                state <= check_ul;
                x <= bNextX;
                y <= blade_yPos - (BLADE_HEIGHT - 1);
            end
            check_ul: begin
                state <= check_ur;
                x <= bNextX + (BLADE_WIDTH - 1);
                y <= blade_yPos - (BLADE_HEIGHT - 1);
            end
            check_ur: begin
                state <= check_br;
                x <= bNextX + (BLADE_WIDTH - 1);
                y <= blade_yPos;
            end
            check_br: begin
                state <= done;
                valid <= 1;
            end
            done: begin
                if (!en)
                    state <= idle;
            end
        endcase

        if (state >= check_bl && state <= check_br) begin
            case (blockType)
                3'd0: collided = 0;
                3'd3: collided = 0;
                3'd4: collided = 0;
                default: collided = 1;
            endcase

            if (state == check_bl) begin
                detect_AABB_collision(
                        x, y, block_xPos, block_yPos,
                        BLADE_WIDTH, BLADE_HEIGHT, 32, 32, collidedWithBlock
                    );

                detect_AABB_collision(
                        x, y, lizard_xPos, lizard_yPos,
                        BLADE_WIDTH, BLADE_HEIGHT, 32, 32, collidedWithLizard
                    );
            end

            if (collided || collidedWithBlock || collidedWithLizard)
                col <= 1;

            if (collidedWithBlock) begin
                blockCol <= 1;
            end

            if (collidedWithLizard) begin
                lizardKillCol <= 1;
            end

        end
    end
endmodule

module player_resolver(
        input clk,
        input en,

        // player state
        input [9:0] player_xPos, player_yPos,
        input [4:0] player_xSpeed, player_ySpeed,
        input player_xDir, player_yDir,

        // destroyable block
        input [9:0] block_xPos, block_yPos,

        // lizard
        input [9:0] lizard_xPos, lizard_yPos,

        // enviornment
        input [2:0] blockType,
        output reg [9:0] x, y,

        // output
        output reg valid,
        output reg [3:0] col,
        output reg playerKill,
        output reg playerWin
    );

    localparam TOP_COL = 4'd3,
               RIGHT_COL = 4'd2,
               BOT_COL = 4'd1,
               LEFT_COL = 4'd0;

    reg [3:0] state;

    reg [9:0] nextX, nextY;
    reg [9:0] xCheck, yCheck;
    reg checkingHor;
    reg collided;
    reg collidedWithBlock;
    reg collidedWithLizard;

    localparam
        idle = 4'd0,
        horizontal = 4'd1,
        vertical = 4'd2,
        check_bl = 4'd3,    // check bottom left corner
        check_ul = 4'd4,   // check top left corner
        check_ur = 4'd5,   // check top right corner
        check_br = 4'd6,   // check bottom right corner
        checked = 4'd7,
        done = 4'd8;

    localparam left = 1'b0,
               right = 1'b1,
               down = 1'b0,
               up = 1'b1;

    initial begin
        state = idle;
    end

    always @ (posedge clk) begin
        case (state)
            idle: begin
                // start computation on enable signal
                if (en) begin
                    state <= horizontal;
                    valid <= 0;
                    col <= 4'b0000;
                    playerKill <= 0;
                    playerWin <= 0;
                end
            end
            horizontal: begin
                // perform x shift
                nextX = player_xDir == left
                ? player_xPos - player_xSpeed
                : player_xPos + player_xSpeed;

                // y remains same
                nextY = player_yPos;

                // move the x, y for the check bl state
                x <= nextX;
                y <= nextY;

                state <= check_bl;
                checkingHor <= 1;
            end
            vertical: begin
                // x remains the same
                nextX = player_xPos;

                // perform y shift
                nextY = player_yDir == down
                ? player_yPos + player_ySpeed
                : player_yPos - player_ySpeed;

                x <= nextX;           // checks bottom left next
                y <= nextY;

                state <= check_bl;
                checkingHor <= 0;
            end
            check_bl: begin
                state <= check_ul;
                x <= nextX;           // checks upper left next
                y <= nextY - 10'd31;
            end
            check_ul: begin
                state <= check_ur;
                x <= nextX + 10'd31;  // checks upper right next
                y <= nextY - 10'd31;
            end
            check_ur: begin
                state <= check_br;
                x <= nextX + 10'd31;  // checks bottom right next
                y <= nextY;
            end
            check_br: state <= checked;
            checked: begin
                if (checkingHor == 1)
                    state <= vertical;
                else begin
                    valid <= 1;
                    state <= done;
                end
            end
            done: begin
                if (!en) begin
                    state <= idle;
                end
            end
        endcase

        if (state >= check_bl && state <= check_br) begin
            // determine if we collided based on blocktype
            case (blockType)
                3'd1: collided = 1;
                3'd2: begin
                    if (player_yDir == down)
                        collided = 1;
                    else
                        collided = 0;
                end
                3'd3: playerWin <= 1;
                default: collided = 0;
            endcase

            // detect collision with destroyable block
            if (state == check_bl) begin
                // check collisions with block
                detect_AABB_collision(
                        x, y, block_xPos, block_yPos,
                        10'd32, 10'd32, 10'd32, 10'd32, collidedWithBlock
                    );

                // check collisions with lizard
                detect_AABB_collision(
                        x, y, lizard_xPos, lizard_yPos,
                        10'd32, 10'd32, 10'd32, 10'd32, collidedWithLizard
                    );
            end

            if (collided || collidedWithBlock)
                if (checkingHor)
                    if (player_xDir == left)
                        col[LEFT_COL] <= 1;
                    else
                        col[RIGHT_COL] <= 1;
                else
                    if (player_yDir == down)
                        col[BOT_COL] <= 1;
                    else
                        col[TOP_COL] <= 1;

            if (collidedWithLizard)
                playerKill <= 1;
        end
    end
endmodule


module collision_resolver(
        input clk,
        input sim_clk,

        // player state
        input [31:0] playerState,
        output reg [3:0] playerCol,
        output reg playerKill,
        output reg playerWin,

        // blade state
        input [26:0] bladeState,
        output reg bladeCol,

        // lizard state
        input [31:0] lizardState,
        output reg [1:0] lizardCol,
        output reg lizardKillCol,

        // block state
        input [19:0] blockPos,
        output reg blockCol,

        // enviornment
        input [2:0] blockType1,
        output [9:0] x1, y1,

        input [2:0] blockType2,
        output [9:0] x2, y2,

        input [2:0] blockType3,
        output [9:0] x3, y3
    );

    // player state
    reg [9:0] player_xPos, player_yPos;
    reg [4:0] player_xSpeed, player_ySpeed;
    reg player_xDir, player_yDir;

    wire tempPlayerKill;
    wire tempPlayerWin;
    wire [3:0] temp_col;
    reg playerEn;
    wire playerValid;

    // blade state
    reg [9:0] blade_xPos, blade_yPos;
    reg [4:0] blade_xSpeed;
    reg blade_xDir;

    wire tempBladeCol;
    reg bladeEn;
    wire bladeValid;

    // lizard state
    reg [9:0] lizard_xPos, lizard_yPos;
    reg [4:0] lizard_xSpeed;
    reg lizard_xDir;

    wire [1:0] tempLizardCol;
    wire tempLizardKillCol;
    reg lizardEn;
    wire lizardValid;
    reg [9:0] lizard_nextX;

    // block state
    reg [9:0] block_xPos, block_yPos;
    wire tempBlockCol;

    // sample inputs
    reg sim_clk_s, sim_clk_ss;

    always @(posedge clk) begin
        sim_clk_s <= sim_clk;
        sim_clk_ss <= sim_clk_s;
    end

    // sm
    localparam
        init = 3'd0,
        send = 3'd3;

    reg [2:0] state;

    initial begin
        state = init;
        playerEn = 0;
        bladeEn = 0;
        lizardEn = 0;
    end

    always @(posedge clk) begin
        case (state)
            init: begin
                // initialize inputs
                player_xPos <= playerState[31:22];
                player_yPos <= playerState[21:12];
                player_xSpeed <= playerState[11:7];
                player_ySpeed <= playerState[6:2];
                player_xDir <= playerState[1];
                player_yDir <= playerState[0];

                blade_xPos <= bladeState[26:17];
                blade_yPos <= bladeState[16:7];
                blade_xSpeed <= bladeState[6:2];
                blade_xDir <= bladeState[1];

                lizard_xPos <= lizardState[31:22];
                lizard_yPos <= lizardState[21:12];
                lizard_xSpeed <= lizardState[11:7];
                lizard_xDir <= lizardState[1];

                lizard_nextX <= lizardState[1] == 1'b0
                ? lizardState[31:22] - lizardState[11:7]
                : lizardState[31:22] + lizardState[11:7];

                block_xPos <= blockPos[19:10];
                block_yPos <= blockPos[9:0];

                // start colliding player
                playerEn <= 1;
                bladeEn <= 1;
                lizardEn <= 1;

                state <= send;
            end

            send: begin
                if (sim_clk_ss && playerValid && bladeValid && lizardValid) begin
                    playerCol <= temp_col;
                    bladeCol <= tempBladeCol;
                    lizardCol <= tempLizardCol;
                    lizardKillCol <= tempLizardKillCol;
                    playerKill <= tempPlayerKill;
                    playerWin <= tempPlayerWin;
                    blockCol <= tempBlockCol;
                    playerEn <= 0;
                    bladeEn <= 0;
                    lizardEn <= 0;
                    state <= init;
                end
            end
        endcase
    end

    player_resolver pc(.clk(clk),
                       .en(playerEn),
                       .player_xPos(player_xPos),
                       .player_yPos(player_yPos),
                       .player_xSpeed(player_xSpeed),
                       .player_ySpeed(player_ySpeed),
                       .player_xDir(player_xDir),
                       .player_yDir(player_yDir),
                       .playerKill(tempPlayerKill),
                       .playerWin(tempPlayerWin),
                       .lizard_xPos(lizard_nextX),
                       .lizard_yPos(lizard_yPos),
                       .block_xPos(block_xPos),
                       .block_yPos(block_yPos),
                       .blockType(blockType1),
                       .valid(playerValid),
                       .col(temp_col),
                       .x(x1),
                       .y(y1));

    blade_resolver br(.clk(clk),
                      .en(bladeEn),
                      .blade_xPos(blade_xPos),
                      .blade_yPos(blade_yPos),
                      .blade_xSpeed(blade_xSpeed),
                      .blade_xDir(blade_xDir),
                      .lizard_xPos(lizard_nextX),
                      .lizard_yPos(lizard_yPos),
                      .lizardKillCol(tempLizardKillCol),
                      .block_xPos(block_xPos),
                      .block_yPos(block_yPos),
                      .blockCol(tempBlockCol),
                      .blockType(blockType2),
                      .x(x2),
                      .y(y2),
                      .valid(bladeValid),
                      .col(tempBladeCol)
                     );

    lizard_resolver lr(.clk(clk),
                       .en(lizardEn),
                       .lizard_xPos(lizard_xPos),
                       .lizard_yPos(lizard_yPos),
                       .lizard_xSpeed(lizard_xSpeed),
                       .lizard_xDir(lizard_xDir),
                       .blockType(blockType3),
                       .x(x3),
                       .y(y3),
                       .valid(lizardValid),
                       .col(tempLizardCol)
                      );
endmodule
