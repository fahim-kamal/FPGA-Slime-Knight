`timescale 1ns / 1ps

module player(
        input sim_clk,
        input [3:0] playerCol,
        output [19:0] playerPos
    );
    reg [9:0] xPos;
    reg [9:0] yPos;
    reg [9:0] xSpeed;
    reg [9:0] ySpeed;

    localparam left = 1'b0,
               right = 1'b1;

    reg playerDir;

    initial
    begin
        xPos = 10'd200;
        yPos = 10'd300;
        xSpeed = 10'd3;
        ySpeed = 10'd0;
        playerDir = 1'b1;
    end

    always @(posedge sim_clk) begin
        if (playerDir == left)
            xPos <= xPos - xSpeed;
        else if (playerDir == right)
            xPos <= xPos + xSpeed;

        // if we detect a collision on this move
        // stop moving
        if (playerCol == 4'b1111) begin
            if (playerDir == right)
                xPos <= xPos - ((xPos - 144) & 31) - 1;
            if (playerDir == left)
                xPos <= xPos + (32 - ((xPos - 144) & 31));

            playerDir <= playerDir == left ? right : left;
        end
    end

    assign playerPos = {xPos, yPos};

endmodule
