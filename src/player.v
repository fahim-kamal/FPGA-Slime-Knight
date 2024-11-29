`timescale 1ns / 1ps

module player(
        input sim_clk,
        input reset,
        input [3:0] playerCol,
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
        xSpeed = 5'd2;
        ySpeed = 5'd0;
        xDir = right;
        yDir = down;
    end

    reg [1:0] counter;
    wire GRAVITY_STEP;

    assign GRAVITY_STEP = counter == 2'd1;

    always @ (posedge sim_clk) begin
        counter <= counter + 1;
    end

    wire HOR_COL;
    wire VERT_COL;

    assign HOR_COL = playerCol[0] || playerCol[2];
    assign VERT_COL = playerCol[1] || playerCol[3];

    always @(posedge sim_clk) begin
        if (reset) begin
            xPos = 10'd176;
            yPos = 10'd99;
            xSpeed = 5'd2;
            ySpeed = 5'd0;
            xDir = right;
            yDir = down;
        end
        else begin
            xPos <= xDir == left
                 ? xPos - xSpeed
                 : xPos + xSpeed;


            // if (GRAVITY_STEP) begin
            yPos <= yDir == down
                 ? yPos + ySpeed:
                 yPos - ySpeed;

            ySpeed <= ySpeed + GRAVITY;
            // end

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
                end
            end
        end
    end

    assign playerState = {xPos, yPos, xSpeed, ySpeed, xDir, yDir};

endmodule
