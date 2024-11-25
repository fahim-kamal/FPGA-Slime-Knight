`timescale 1ns / 1ps

/*
    RESOLVERS MUST BE A STATE MACHINE WHICH HAS FOLLOWING STATES: 
      start -> 3'd0
      init -> 3'd1
*/ 

task player_resolver(
        output reg [3:0] state,
        input [9:0] playerX, playerY,
        input blockType,
        output reg [3:0] col,
        output reg [9:0] x, y
    );

    localparam
        idle = 3'd0,
        init = 3'd1,   // check bottom left corner
        check_pu = 3'd2,  // check top corner
        check_pur = 3'd3, // check top right corner
        check_pr = 3'd4;  // check bottom right corner

    begin
        case (state)
            init: begin
                state <= check_pu;

                // up
                x <= playerX;
                y <= playerY - 10'd32;
            end
            check_pu: begin
                state <= check_pur;

                // up right
                x <= playerX + 10'd32;
                y <= playerY - 10'd32;
            end
            check_pur: begin
                state <= check_pr;

                // right
                x <= playerX + 10'd32;
                y <= playerY;
            end
            check_pr: state <= idle;
        endcase

        if (state != idle) begin
            case (blockType)
                1'b1: col <= 4'b1111;
                default: col <= col; // has to be here
            endcase
        end
    end
endtask


module collision_resolver(
        input clk,
        input sim_clk,

        // player state
        input [19:0] playerPos,
        output reg [3:0] playerCol,

        // enviornment
        input blockType,
        output reg [9:0] x, y

    );

    localparam
        idle = 3'd0,
        init = 3'd1;

    reg [2:0] state;

    reg sim_clk_s;
    reg sim_clk_ss;

    // sample inputs
    always @(posedge clk) begin
        sim_clk_s <= sim_clk;
        sim_clk_ss <= sim_clk_s;
    end

    reg [9:0] playerX;
    reg [9:0] playerY;

    reg [3:0] temp_col;

    // sm
    initial begin
        temp_col = 4'b0000;
        state = init;
        playerX = playerPos[19:10];
        playerY = playerPos[9:0];
        x = playerX;
        y = playerY;
    end

    always @(posedge clk) begin
        if (state == idle)
            if (sim_clk_ss) begin
                temp_col <= 4'b0000;
                playerCol <= temp_col;

                state <= init;

                playerX <= playerPos[19:10];
                playerY <= playerPos[9:0];

                x <= playerPos[19:10];
                y <= playerPos[9:0];
            end

        player_resolver(state, playerX, playerY, blockType, temp_col, x, y);
    end
endmodule
