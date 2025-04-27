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

module Datapath#(
    parameter [31:0] HEAP_BASE = 32'h00000080
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
	output [31:0] MemAddr       // Address to access memory
);


wire [31:0] PCNext, PCNextIn, PCplus4, PCbeforeBranch, PCBranch;
wire [31:0] extendedimm, extendedimmafter, MUXresult, Writedata, dataone, aluop2;
wire [4:0] writereg, writeregInt;
wire JSrc;


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



wire [4:0] read_addr1 = syscall ? 5'd2 : Instr[25:21]; // if syscall, read $v0
wire [4:0] read_addr2 = syscall ? 5'd4 : Instr[20:16]; // if syscall, read $a0


reg [31:0] heap_pointer;

wire [31:0] final_writedata = (syscall && (dataone == 32'd9)) ? heap_pointer : Writedata;
wire [4:0] final_writereg = (syscall && (dataone == 32'd9)) ? 5'd2 : writereg;



registerfile32 RF(
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


// ALU

alu32 alucomp(dataone, aluop2, ALUControl, Instr[10:6], ALUResult, ZeroFlag);
signext immextention(Instr[15:0],extendedimm);
mux2 #(32) aluop2sel(datatwo,extendedimm, ALUSrc, aluop2);


// Memory write path
assign WriteData = datatwo;    // value to be written to memory (either heap or dmem)
assign MemAddr   = ALUResult;  // address calculated


// Syscall handling
always @(posedge clk) begin
	if (reset) begin
		// This must be changed if the size of DMem increases, since we're using that
		// as one physical memory
        heap_pointer <= HEAP_BASE; // Heap starts here
    end
    if (syscall) begin
        case (dataone)
            32'd1: begin
                $display("Syscall Print Integer: %h", datatwo);
            end
            32'd4: begin
                $display("Syscall Print String Address: %h", datatwo);
            end
            32'd9: begin
                $display("Syscall Memory Allocation, bytes requested: %d", datatwo);
                heap_pointer <= heap_pointer + datatwo; // move heap up by requested size
                // $v0 must be updated with old heap_pointer
            end
            32'd10: begin
                $display("Syscall Exit");
                $finish;
            end
            default: begin
                $display("Unknown syscall code: %d", dataone);
            end
        endcase
    end
end


endmodule