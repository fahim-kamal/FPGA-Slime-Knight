`timescale 1ns / 1ps

module player(
        input sim_clk,
        input [3:0] playerCol,
        output [19:0] playerPos
    );
    localparam MAX_SPEED = 20;

    reg [9:0] xPos;
    reg [9:0] yPos;
    reg [9:0] xSpeed;
    reg [9:0] ySpeed;

    initial
    begin
        xPos = 10'd200;
        yPos = 10'd300;
        xSpeed = 10'd1;
        ySpeed = 10'd0;
    end

    always @(posedge sim_clk) begin
        xPos <= xPos + xSpeed;
        if (playerCol == 4'b1111) begin
            xSpeed <= 0;
            xPos <= xPos - 1;
        end
    end

    assign playerPos = {xPos, yPos};

endmodule
