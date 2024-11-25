`timescale 1ns / 1ps

module clk(
        input ClkPort,
        output sim_clk,
        output clk25
    );
    reg [26:0] clk_ctr;

    initial
        clk_ctr = 0;

    always @(posedge ClkPort)
        clk_ctr <= clk_ctr + 1;

    // outputs
    assign sim_clk = clk_ctr[21:20];
    assign clk_25 = clk_ctr[1:0];
endmodule
