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
wire start_mult; // mult instruction wires
wire mfhi_sel;   // mult instruction wires
wire mflo_sel;    // mult instruction wires


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
wire [31:0] v0_data, a0_data;

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
    MemAddr,
    v0_data, 
    a0_data,
    start_mult, mfhi_sel, mflo_sel
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
    SysCall,
	start_mult, mfhi_sel, mflo_sel
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






reg [31:0] addr;
reg [31:0] word;
reg [7:0] byte;
integer i;
                
                
// Syscall handling
always @(posedge clk) begin
	if (reset) begin
		// This must be changed if the size of DMem increases, since we're using that
		// as one physical memory
        datapathcomp.heap_pointer = HEAP_BASE; // Heap starts here
    end
    if (SysCall) begin
        case (v0_data)
        	32'd1: begin
                $display("Syscall Print Integer: %d", a0_data);
            end
            4: begin
                addr = a0_data; // string address
                $write("Syscall Print String: ");
                begin : PRINT_LOOP  // <<-- Name the block
					while (1) begin
						if (addr < HEAP_BASE) begin
							word = dmem.Dmem[addr >> 2];
						end else begin
							word = heap_ram.Dmem[(addr - HEAP_BASE) >> 2];
						end
			
						for (i = addr[1:0]; i < 4; i = i + 1) begin
							byte = word[31 - 8*i -: 8];
							if (byte == 8'h00) begin
								disable PRINT_LOOP; // <<-- Proper disable
							end
							$write("%s", byte);
						end
			
						addr = addr + (4 - addr[1:0]); // move to next word boundary
					end
				end
                
                $write("\n");
            end
            32'd9: begin
                $display("Syscall Memory Allocation, bytes requested: %d", a0_data);
                datapathcomp.heap_pointer <= datapathcomp.heap_pointer + a0_data; // move heap up by requested size
                // $v0 must be updated with old heap_pointer
            end
            32'd10: begin
                $display("Syscall Exit");
                $finish;
            end
            default: begin
                $display("Unsupported syscall: %d", v0_data);
                // $finish;
            end
        endcase
    end
end









endmodule
