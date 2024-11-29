`timescale 1ns / 1ps

module clk(
        input ClkPort,
        output sim_clk
    );
    reg [26:0] clk_ctr;

    initial
        clk_ctr = 0;

    always @(posedge ClkPort)
        clk_ctr <= clk_ctr + 1;

    // outputs
    assign sim_clk = clk_ctr[21:20];
endmodule
