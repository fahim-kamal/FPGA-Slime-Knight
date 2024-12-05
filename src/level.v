`timescale 1ns / 1ps

parameter ROW_MAX = 14;
parameter COL_MAX = 19;
parameter LEFT = 144;
parameter TOP = 35;

module set_ptr (
        input [9:0] x, y,
        output [5:0] row_ptr, col_ptr,
        output valid
    );

    assign row_ptr = (y - TOP) >> 5;   // divide by 5
    assign col_ptr = (x - LEFT) >> 5;

    assign valid = (row_ptr >= 0 && row_ptr <= ROW_MAX) &&
           (col_ptr >= 0 && col_ptr <= COL_MAX);
endmodule

module level(
        // pins for display
        input [9:0] x1,
        input [9:0] y1,
        output [2:0] data1,

        // pins for collision
        input [9:0] x2,
        input [9:0] y2,
        output [2:0] data2,

        input [9:0] x3,
        input [9:0] y3,
        output [2:0] data3,

        input [9:0] x4,
        input [9:0] y4,
        output [2:0] data4
    );
    reg [2:0] level [0:ROW_MAX][0:COL_MAX];

    initial begin
        $readmemb("lvl1.mem", level);
    end

    wire [5:0] row_ptr1, col_ptr1;
    wire [5:0] row_ptr2, col_ptr2;
    wire [5:0] row_ptr3, col_ptr3;
    wire [5:0] row_ptr4, col_ptr4;
    wire valid1, valid2, valid3, valid4;

    // first pinout
    set_ptr sp1(
                .x(x1),
                .y(y1),
                .row_ptr(row_ptr1),
                .col_ptr(col_ptr1),
                .valid(valid1)
            );

    // second pinout
    set_ptr sp2(
                .x(x2),
                .y(y2),
                .row_ptr(row_ptr2),
                .col_ptr(col_ptr2),
                .valid(valid2)
            );

    // third pinout
    set_ptr sp3(
                .x(x3),
                .y(y3),
                .row_ptr(row_ptr3),
                .col_ptr(col_ptr3),
                .valid(valid3)
            );

    set_ptr sp4(
                .x(x4),
                .y(y4),
                .row_ptr(row_ptr4),
                .col_ptr(col_ptr4),
                .valid(valid4)
            );

    // output
    assign data1 = !valid1 ? 3 : level[row_ptr1][col_ptr1];
    assign data2 = !valid2 ? 3 : level[row_ptr2][col_ptr2];
    assign data3 = !valid3 ? 3 : level[row_ptr3][col_ptr3];
    assign data4 = !valid4 ? 3 : level[row_ptr4][col_ptr4];
endmodule
