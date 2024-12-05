`timescale 1ns / 1ps

module blade(
        input sim_clk,
        input shoot,
        input [9:0] player_xPos, player_yPos,
        input [4:0] player_xSpeed,
        input player_xDir,
        input bladeCol,
        output [26:0] bladeState
    );
    reg [9:0] xPos, yPos;
    reg [4:0] xSpeed;  // does not move vertically
    reg xDir;
    reg isActive;

    reg [9:0] nextX;

    localparam X_OFFSET = 40,
               Y_OFFSET = 8,
               X_SPEED_OFFSET = 8;

    localparam init = 1'b0,
               move = 1'b1;

    reg state;

    initial begin
        state = init;
    end

    always @(posedge sim_clk) begin
        case (state)
            init: begin
                if (shoot) begin
                    xPos <= player_xDir == 1'b0
                    ? player_xPos - X_OFFSET - 28
                    : player_xPos + X_OFFSET;

                    yPos <= player_yPos - Y_OFFSET;

                    xSpeed <= player_xSpeed + X_SPEED_OFFSET;
                    xDir <= player_xDir;

                    isActive <= 1;

                    state <= move;
                end
            end

            move: begin
                nextX = xDir == 1'b0
                ? xPos - xSpeed
                : xPos + xSpeed;

                xPos <= nextX;

                if (nextX < 144 || nextX > 783 || bladeCol) begin
                    xPos <= 0;
                    yPos <= 0;
                    xSpeed <= 0;
                    isActive <= 0;
                    state <= init;
                end
            end
        endcase
    end

    assign bladeState = {xPos, yPos, xSpeed, xDir, isActive};
endmodule
