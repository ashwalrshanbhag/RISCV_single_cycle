`timescale 1ns/1ps
module Data_Memory(clk,WE,WD,A,RD);

    input clk,WE;
    input [31:0] A, WD;
    output [31:0] RD;

    reg [31:0] mem [1023:0];

    integer i;
    initial begin
        for (i=0; i<1024; i=i+1)
            mem[i] = 32'b0;
    end
    
    assign RD = mem[A[31:2]]; 

    always @(posedge clk) begin
        if (WE) begin
            mem[A[31:2]] <= WD;
        end
    end

endmodule
