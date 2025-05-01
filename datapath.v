// file: Datapath.v


`include "adder.v"
`include "alu32.v"
`include "alu64.v"
`include "flopr_param.v"
`include "mux2.v"
`include "mux4.v"
`include "regfile32.v"
`include "signext.v"
`include "sl2.v"

`timescale 1ns/1ns

module Datapath#(
	parameter [31:0] HEAP_BASE = 32'h10000000,
	parameter [31:0] HEAP_SIZE = 32'h000000fc
)(
	input clk,
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
	input [31:0] ReadData,	// Memory read data from dmem OR heap
	input [31:0] Instr,
	input syscall,             // <<== NEW: syscall input
	output [31:0] PC,
	output ZeroFlag,
	output [31:0] datatwo, 
	output [31:0] ALUResult,
	output [31:0] WriteData,    // Value to write to memory (dmem or heap)
	output [31:0] MemAddr,       // Address to access memory
	output [31:0] v0_data,
	output [31:0] a0_data,
	input  start_mult, 
	input  mfhi_sel, 
	input  mflo_sel
);


wire [31:0] PCNext, PCNextIn, PCplus4, PCbeforeBranch, PCBranch;
wire [31:0] extendedimm, extendedimmafter, MUXresult, Writedata, dataone, aluop2;
wire [4:0] writereg, writeregInt;
wire JSrc;


// PC 
flopr_param #(32) PCregister(clk,reset, PC, PCNext);
adder #(32) pcadd4(PC, 32'd4 ,PCplus4);
slt2 shifteradd2(extendedimm,extendedimmafter);
adder #(32) pcaddsigned(extendedimmafter,PCplus4,PCbeforeBranch);
mux2 #(32) branchmux(PCplus4 , PCbeforeBranch, PCSrc, PCBranch);


assign JSrc = Jump | JAL;

mux2 #(32) jumpmux(PCBranch, {PCplus4[31:28],Instr[25:0],2'b00 }, JSrc,PCNextIn);

mux2 #(32) jRmux(PCNextIn, ALUResult,  JR, PCNext);

initial begin
	$monitor("PC: %h | PCNextIn: %h | ALUResult: %h | JR: %h | PCNext: %h",
	PC, PCNextIn, ALUResult, JR, PCNext
	);
end

// Register File 

mux2 #(5) writeopmux(Instr[20:16],Instr[15:11],RegDst, writeregInt);


mux2 #(32) resultmux(ALUResult, ReadData, MemtoReg, MUXresult);

mux2 #(5) writeafmux(writeregInt, 5'b11111, JAL, writereg);
mux2 #(32) jalmux(MUXresult, PCplus4, JAL, Writedata);



wire [4:0] read_addr1 = syscall ? 5'd2 : Instr[25:21]; // if syscall, read $v0
wire [4:0] read_addr2 = syscall ? 5'd4 : Instr[20:16]; // if syscall, read $a0


reg [31:0] heap_pointer;

wire [31:0] final_writedata = (syscall && (dataone == 32'd9)) ? heap_pointer : 
							  (mfhi_sel === 1'b1) ? HI :
							  (mflo_sel === 1'b1) ? LO : Writedata;
wire [4:0] final_writereg = (syscall && (dataone == 32'd9)) ? 5'd2 : writereg;

assign v0_data = dataone; // $v0 is register 2
assign a0_data = datatwo; // $a0 is register 4

registerfile32 #(.sp_fp_base(HEAP_BASE + HEAP_SIZE)) RF(
  clk,
  RegWrite, 
  reset, 
  read_addr1, 
  read_addr2, 
  final_writereg, 
  final_writedata, 
  dataone,
  datatwo
); 


// ALU32

alu32 alucomp(dataone, aluop2, ALUControl, Instr[10:6], ALUResult, ZeroFlag);
signext immextention(Instr[15:0],extendedimm);
mux2 #(32) aluop2sel(datatwo,extendedimm, ALUSrc, aluop2);


// ALU 64

wire [63:0] ALU64Result;
wire ZeroFlag64;
alu64 alu64comp(dataone, aluop2, ALUControl, Instr[10:6], ALU64Result, ZeroFlag64);
mux2 #(1) zero64sel(ZeroFlag, ZeroFlag64, start_mult, ZeroFlag);


reg [31:0] HI, LO;

always @(posedge clk) begin
    if (start_mult == 1'b1) begin
        HI <= ALU64Result[63:32];
        LO <= ALU64Result[31:0];
    end
end




// Memory write path
assign WriteData = datatwo;    // value to be written to memory (either heap or dmem)
assign MemAddr   = ALUResult;  // address calculated




endmodule