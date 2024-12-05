`timescale 1ns / 1ps

/*
    RESOLVERS MUST BE A STATE MACHINE WHICH HAS FOLLOWING STATES: 
      start -> 3'd0
      init -> 3'd1
*/ 

module blade_resolver(
        input clk,
        input en,

        input [9:0] blade_xPos, blade_yPos,
        input [4:0] blade_xSpeed,
        input blade_xDir,

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

    always @(posedge clk) begin
        case (state)
            idle: begin
                if (en) begin
                    col <= 0;
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
                default: collided = 1;
            endcase

            if (collided)
                col <= 1;
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

        // enviornment
        input [2:0] blockType,
        output reg [9:0] x, y,

        // output
        output reg valid,
        output reg [3:0] col
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
                default: collided = 0;
            endcase

            if (collided)
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
        end
    end
endmodule


module collision_resolver(
        input clk,
        input sim_clk,

        // player state
        input [31:0] playerState,
        output reg [3:0] playerCol,

        // blade state
        input [26:0] bladeState,
        output reg bladeCol,

        // enviornment
        input [2:0] blockType1,
        output [9:0] x1, y1,

        input [2:0] blockType2,
        output [9:0] x2, y2

    );

    // player state
    reg [9:0] player_xPos, player_yPos;
    reg [4:0] player_xSpeed, player_ySpeed;
    reg player_xDir, player_yDir;

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

                // start colliding player
                playerEn <= 1;
                bladeEn <= 1;

                state <= send;
            end

            send: begin
                if (sim_clk_ss && playerValid && bladeValid) begin
                    playerCol <= temp_col;
                    bladeCol <= tempBladeCol;
                    playerEn <= 0;
                    bladeEn <= 0;
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
                      .blockType(blockType2),
                      .x(x2),
                      .y(y2),
                      .valid(bladeValid),
                      .col(tempBladeCol)
                     );
endmodule

