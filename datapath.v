// file: Datapath.v


`include "adder.v"
`include "alu32.v"
`include "flopr_param.v"
`include "mux2.v"
`include "mux4.v"
`include "regfile32.v"
`include "signext.v"
`include "sl2.v"

`timescale 1ns/1ns

module Datapath(input clk,
                input reset,
                input RegDst,
                input RegWrite,
                input ALUSrc,
                input Jump,
                input JAL,
                input JR,
                input MemtoReg,
                input PCSrc,
                input [5:0] ALUControl,
                input [31:0] ReadData,
                input [31:0] Instr,
                input syscall,             // <<== NEW: syscall input
                output [31:0] PC,
                output ZeroFlag,
                output [31:0] datatwo, 
                output [31:0] ALUResult);


wire [31:0] PCNext, PCNextIn, PCplus4, PCbeforeBranch, PCBranch;
wire [31:0] extendedimm, extendedimmafter, MUXresult, Writedata, dataone, aluop2;
wire [4:0] writereg, writeregInt;
wire JSrc;

// New wires for syscall ($v0 and $a0)
wire [31:0] rf_rd2;   // Register 2: $v0
wire [31:0] rf_rd4;   // Register 4: $a0

// PC 
flopr_param #(32) PCregister(clk,reset, PC,PCNext);
adder #(32) pcadd4(PC, 32'd4 ,PCplus4);
slt2 shifteradd2(extendedimm,extendedimmafter);
adder #(32) pcaddsigned(extendedimmafter,PCplus4,PCbeforeBranch);
mux2 #(32) branchmux(PCplus4 , PCbeforeBranch, PCSrc, PCBranch);

assign JSrc = Jump | JAL;

mux2 #(32) jumpmux(PCBranch, {PCplus4[31:28],Instr[25:0],2'b00 }, JSrc,PCNextIn);

mux2 #(32) jRmux(PCNextIn, ALUResult,  JR,PCNext);

// Register File 

mux2 #(5) writeopmux(Instr[20:16],Instr[15:11],RegDst, writeregInt);


mux2 #(32) resultmux(ALUResult, ReadData, MemtoReg, MUXresult);

mux2 #(5) writeafmux(writeregInt, 5'b11111, JAL, writereg);
mux2 #(32) jalmux(MUXresult, PCplus4, JAL, Writedata);

registerfile32 RF(
  clk,
  RegWrite, 
  reset, 
  Instr[25:21], 
  Instr[20:16], 
  writereg, 
  Writedata, 
  dataone,
  datatwo
); 

// Syscall register reads
// (Manually read $v0 and $a0 for syscall handling)
registerfile32 RF_syscall(
    clk,
    1'b0,          // No writes
    reset,
    5'd2,          // Read register $v0
    5'd4,          // Read register $a0
    5'd0,          // Dummy write register
    32'd0,         // Dummy write data
    rf_rd2,        // Output $v0
    rf_rd4         // Output $a0
);

// ALU

alu32 alucomp(dataone, aluop2, ALUControl, Instr[10:6], ALUResult, ZeroFlag);
signext immextention(Instr[15:0],extendedimm);
mux2 #(32) aluop2sel(datatwo,extendedimm, ALUSrc, aluop2);


// Syscall handling
always @(posedge clk) begin
    if (syscall) begin
        case (rf_rd2)
            32'd1: begin
                $display("Syscall Print Integer: %d", rf_rd4);
            end
            32'd4: begin
                $display("Syscall Print String Address: %h", rf_rd4);
                // You can later implement memory read for string printing
            end
            32'd10: begin
                $display("Syscall Exit");
                $finish;
            end
            default: begin
                $display("Unknown syscall code: %d", rf_rd2);
            end
        endcase
    end
end

endmodule