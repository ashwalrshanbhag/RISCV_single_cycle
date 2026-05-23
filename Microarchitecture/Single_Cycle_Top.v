`timescale 1ns/1ps
module Single_Cycle_Top(clk,rst);

    input clk,rst;

    wire [31:0] PC_Top,RD_Instr,RD1_Top,Imm_Ext_Top,ALUResult,ReadData,PCPlus4,RD2_Top,SrcB,Result;
    wire Branch_Top, Zero_Top, PCSel;
    wire [31:0] PCBranch_Top, PC_Next_Top;
    wire RegWrite,MemWrite,ALUSrc,ResultSrc;
    wire [1:0]ImmSrc;
    wire [2:0]ALUControl_Top;


// 1. Calculate Branch Target: PC + Imm_Ext
    PC_Adder PC_Branch_Adder(
        .a(PC_Top),
        .b(Imm_Ext_Top),
        .c(PCBranch_Top)
    );

    // 2. Branch Logic Switch: Jump only if it's a branch instruction AND condition is met
    assign PCSel = Branch_Top & Zero_Top;

    // 3. The New PC Multiplexer (Chooses next address)
    Mux Mux_PC_Selection(
        .a(PCPlus4),       // Path 0: Keep going sequentially (PC + 4)
        .b(PCBranch_Top),  // Path 1: Take the leap (PC + Immediate)
        .s(PCSel),
        .c(PC_Next_Top)
    );


    PC_Module PC(
        .clk(clk),
        .rst(rst),
        .PC(PC_Top),
        .PC_Next(PC_Next_Top) // Updated from PCPlus4
    );
    
    Instruction_Memory Instruction_Memory(
                          
                            .A(PC_Top),
                            .RD(RD_Instr)
    );

    Register_File Register_File(
                            .clk(clk),
                            .rst(rst),
                            .WE3(RegWrite),
                            .WD3(Result),
                            .A1(RD_Instr[19:15]),
                            .A2(RD_Instr[24:20]),
                            .A3(RD_Instr[11:7]),
                            .RD1(RD1_Top),
                            .RD2(RD2_Top)
    );

     // Sign extend (use full ImmSrc)
     Sign_Extend Sign_Extend(
                            .In(RD_Instr),
                            .ImmSrc(ImmSrc),
                            .Imm_Ext(Imm_Ext_Top)
     );

    Mux Mux_Register_to_ALU(
                            .a(RD2_Top),
                            .b(Imm_Ext_Top),
                            .s(ALUSrc),
                            .c(SrcB)
    );

    ALU ALU(
            .A(RD1_Top),
            .B(SrcB),
            .Result(ALUResult),
            .ALUControl(ALUControl_Top),
            .OverFlow(),
            .Carry(),
            .Zero(Zero_Top),
            .Negative()
    );

    Control_Unit_Top Control_Unit_Top(
        .Op(RD_Instr[6:0]),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch_Top),   // Updated to pass branch control signal
        .funct3(RD_Instr[14:12]),
        .funct7(RD_Instr[31:25]),
        .ALUControl(ALUControl_Top)
    );
    

    Data_Memory Data_Memory(
                        .clk(clk),
                        .WE(MemWrite),
                        .WD(RD2_Top),
                        .A(ALUResult),
                        .RD(ReadData)
    );

    Mux Mux_DataMemory_to_Register(
                            .a(ALUResult),
                            .b(ReadData),
                            .s(ResultSrc),
                            .c(Result)
    );

endmodule
