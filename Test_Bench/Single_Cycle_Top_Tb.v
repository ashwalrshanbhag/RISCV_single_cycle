`timescale 1ns/1ps

module Single_Cycle_top_tb;

    reg clk;
    reg rst;

    Single_Cycle_Top dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset + run (ACTIVE-HIGH RESET)
    initial begin
        rst = 1;        // ASSERT reset
        #20;            // hold reset for 2 cycles
        rst = 0;        // RELEASE reset → CPU RUNS

        #500;           // enough for all memfile instructions
        $display("Simulation finished");
        $finish;
    end

endmodule
