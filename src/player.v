`timescale 1ns / 1ps

module player(
        input sim_clk,
        input reset,
        input jump_r,
        input [3:0] playerCol,
        input [31:0] initPlayerState,
        output [31:0] playerState
    );
    reg [9:0] xPos, yPos;
    reg [4:0] xSpeed, ySpeed;
    reg xDir, yDir;

    localparam left = 1'b0,
               right = 1'b1,
               down = 1'b0,
               up = 1'b1;

    localparam GRAVITY = 1;

    localparam BOT_COL = 4'd1;

    initial
    begin
        xPos = 10'd176;
        yPos = 10'd99;
        xSpeed = 5'd4;
        ySpeed = 5'd0;
        xDir = right;
        yDir = down;
    end

    wire HOR_COL;
    wire VERT_COL;

    assign HOR_COL = playerCol[0] || playerCol[2];
    assign VERT_COL = playerCol[1] || playerCol[3];

    // jump
    reg airborne;

    always @(posedge sim_clk) begin
        if (reset) begin
            xPos <= initPlayerState[31:22];
            yPos <= initPlayerState[21:12];
            xSpeed <= initPlayerState[11:7];
            ySpeed <= initPlayerState[6:2];
            xDir <= initPlayerState[1];
            yDir <= initPlayerState[0];
        end
        else begin
            // update positions
            xPos <= xDir == left
                 ? xPos - xSpeed
                 : xPos + xSpeed;

            yPos <= yDir == down
                 ? yPos + ySpeed:
                 yPos - ySpeed;

            // update speeds
            if (jump_r && !airborne && (playerCol[BOT_COL] || ySpeed == 0)) begin
                ySpeed <= 17; // will subtract on this clock
                yDir <= up;
                airborne <= 1;
            end
            else begin
                if (yDir == down)
                    ySpeed <= ySpeed + GRAVITY;
                else begin
                    if (ySpeed > GRAVITY)
                        ySpeed <= ySpeed - GRAVITY;
                    else begin
                        ySpeed <= 0;
                        yDir <= down;
                    end
                end

            end

            // horizontal collision
            if (HOR_COL) begin
                // move to grid boundary
                xPos <= xDir == left
                     ? xPos - xSpeed + (32 - ((xPos - xSpeed - 144) & 31))
                     : xPos + xSpeed - ((xPos + xSpeed - 144) & 31) - 1;

                xDir <= xDir == left ? right : left;
            end

            if (VERT_COL) begin
                if (playerCol[BOT_COL]) begin
                    yPos <= yPos + ySpeed - ((yPos + ySpeed - 35) & 31) - 1;
                    ySpeed <= 0;
                    airborne <= 0;
                end
                else begin
                    yPos <= yPos - ySpeed + (32 - (((yPos - ySpeed - 35) & 31) + 1));
                    ySpeed <= 0;
                    yDir <= down;
                end
            end

        end
    end

    assign playerState = {xPos, yPos, xSpeed, ySpeed, xDir, yDir};

endmodule
