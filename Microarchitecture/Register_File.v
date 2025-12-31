`timescale 1ns/1ps

module Register_File(
    input         clk,
    input rst,  // ACTIVE-HIGH reset
    input         WE3,
    input  [4:0]  A1,
    input  [4:0]  A2,
    input  [4:0]  A3,
    input  [31:0] WD3,
    output [31:0] RD1,
    output [31:0] RD2
);

    reg [31:0] Register [31:0];
    integer i;

    // Optional sim init
    initial begin
        for (i = 0; i < 32; i = i + 1)
            Register[i] = 32'b0;
    end

    // Write + reset logic
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                Register[i] <= 32'b0;
        end else begin
            if (WE3 && (A3 != 5'd0))
                Register[A3] <= WD3;

            Register[0] <= 32'b0;   // x0 hardwired
        end
    end

    // Read logic
    assign RD1 = (A1 == 5'd0) ? 32'b0 : Register[A1];
    assign RD2 = (A2 == 5'd0) ? 32'b0 : Register[A2];

endmodule
