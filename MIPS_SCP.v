// file: MIPS_SCP.v

`include "datapath.v"
`include "ram.v"
`include "rom.v"
`include "control.v"

`timescale 1ns/1ns

module MIPS_SCP(
    input clk,
    input reset
);

// Wires for datapath
wire [31:0] PC, Instr;
wire [31:0] ReadDataHeap, ReadDataDmem, FinalReadData;
wire [31:0] WriteData, ALUResult, MemAddr, datatwo;
wire RegDst, RegWrite, ALUSrc, Jump, JAL, JR, MemtoReg, PCSrc, Zero, MemWrite, SysCall;
wire [5:0] ALUControl;

// --- Memory system wiring ---
wire [31:0] heap_addr;
wire [31:0] heap_din;
wire [31:0] heap_dout;
wire heap_we;

// Memory address detection
parameter [31:0] HEAP_BASE = 32'h10000000;
wire is_heap_addr = (MemAddr >= HEAP_BASE);

assign heap_we = MemWrite & is_heap_addr;
assign heap_addr = MemAddr - HEAP_BASE;
assign heap_din = WriteData;

wire dmem_we = MemWrite & ~is_heap_addr;

// Final memory read mux
assign FinalReadData = is_heap_addr ? heap_dout : ReadDataDmem;

// --- Module Instantiations ---

// Datapath
Datapath #(
    .HEAP_BASE(HEAP_BASE)
) datapathcomp(
    clk,
    reset,
    RegDst,
    RegWrite,
    ALUSrc,
    Jump,
    JAL,
    JR,
    MemtoReg,
    PCSrc,
    ALUControl,
    FinalReadData,   // Memory Read Data
    Instr,
    SysCall,
    PC,
    Zero,
    datatwo,
    ALUResult,
    WriteData,
    MemAddr
);

// Controller
Controlunit controller(
    Instr[31:26], 
    Instr[5:0], 
    Zero,
    MemtoReg,
    MemWrite,
    ALUSrc,
    RegDst,
    RegWrite,
    Jump,
    JAL,
    JR,
    PCSrc,
    ALUControl,
    SysCall
);

// Data Memory (DMEM)
ram dmem(
    .clk(clk),
    .we(dmem_we),
    .addr(MemAddr),
    .din(WriteData),
    .dout(ReadDataDmem)
);

// Heap Memory (HEAP_RAM)
ram heap_ram(
    .clk(clk),
    .we(heap_we),
    .addr(heap_addr),
    .din(heap_din),
    .dout(heap_dout)
);

// Instruction Memory (IMEM)
rom imem(
    .addr(PC),
    .dout(Instr)
);

// Load memory contents at simulation start
initial begin
    $readmemb("test_input/increment_array.out.no_address.data.bin", dmem.Dmem);
    $readmemb("test_input/increment_array.out.no_address.text.bin", imem.Imem);
end

endmodule
