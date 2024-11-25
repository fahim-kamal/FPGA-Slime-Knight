`timescale 1ns / 1ps

module level(
        input clk,

        // pins for display
        input [9:0] x1,
        input [9:0] y1,
        output data1,

        // pins for collision
        input [9:0] x2,
        input [9:0] y2,
        output data2
    );
    parameter GRID_SIZE = 32;
    parameter ROW_MAX = 15;
    parameter COL_MAX = 19;
    parameter LEFT = 143;
    parameter TOP = 34;

    reg [COL_MAX:0] level [ROW_MAX:0];

    initial begin
        $readmemb("lvl1.mem", level);
    end

    // first pinout
    wire valid1;
    wire [5:0] row_ptr1, col_ptr1;

    assign row_ptr1 = (y1 - TOP) >> 5;
    assign col_ptr1 = (x1 - LEFT) >> 5;

    assign valid1 = (row_ptr1 >= 0 && row_ptr1 <= ROW_MAX) &&
           (col_ptr1 >= 0 && col_ptr1 <= COL_MAX);

    assign data1 = !valid1 ? 3 : level[row_ptr1][col_ptr1];

    // second pinout
    wire valid2;
    wire [5:0] row_ptr2, col_ptr2;

    assign row_ptr2 = (y2 - TOP) >> 5;
    assign col_ptr2 = (x2 - LEFT) >> 5;

    assign valid2 = (row_ptr2 >= 0 && row_ptr2 <= ROW_MAX) &&
           (col_ptr2 >= 0 && col_ptr2 <= COL_MAX);

    assign data2 = !valid2 ? 3 : level[row_ptr2][col_ptr2];

endmodule
