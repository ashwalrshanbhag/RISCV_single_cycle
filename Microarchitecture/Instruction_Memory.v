`timescale 1ns/1ps
module Instruction_Memory(
    input  [31:0] A,
    output [31:0] RD
);

  reg [31:0] mem [0:1023];

  // Word-aligned instruction fetch
  assign RD = mem[A[11:2]];

  initial begin
    $readmemh("memfile.mem", mem);
  end

endmodule
