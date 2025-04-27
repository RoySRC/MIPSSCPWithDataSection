// file: MIPS_SCP_tb.v
// Testbench for MIPS_SCP

`timescale 1ns/1ns

module MIPS_SCP_tb;

	//Inputs
	reg clk;
    reg reset;

	//Outputs


	//Instantiation of Unit Under Test
	MIPS_SCP uut (
		.clk(clk),
		.reset(reset)
	);

// 	task print_registers;
// 		integer i;
// 		begin
// 			$display("Register Contents:");
// 			for (i = 0; i < 32; i = i + 1) begin
// 				$display("R%0d = %h", i, uut.datapathcomp.RF.register[i]);
// 			end
// 		end
// 	endtask

    always #10 clk = ~clk;
  integer i;
  initial begin
    // Optional: enable waveform dumping
//     $dumpfile("dump.vcd");
//     $dumpvars(0, MIPS_SCP_tb);

    clk = 0;
    reset = 1;
    #100;            // Hold reset high for 100ns
    reset = 0;

    // Run simulation for a long duration
    #500;

	#10000000; // Wait for writes to finish (adjust if needed)

	$display("==== Final DMEM Contents ====");
	for (i = 0; i < 64; i = i + 1) begin
		$display("DMEM[0x%08X] = 0x%08X", 32'h10010000 + (i << 2), 
		uut.dmem.Dmem[i]);
	end

	$display("");
	$display("==== Final IMEM Contents ====");
	for (i = 0; i < 64; i = i + 1) begin
		$display("IMEM[0x%08X] = 0x%08X", i << 2, uut.imem.Imem[i]);
	end
	
	$display("");
	$display("==== Final HMEM Contents ====");
	for (i = 0; i < 64; i = i + 1) begin
		$display("HMEM[0x%08X] = 0x%08X", 32'h10000000 + (i << 2), 
		uut.heap_ram.Dmem[i]);
	end

	$display("");
	$display("==== Register Contents ====");
	for (i = 0; i < 32; i = i + 1) begin
		$display("R%0d = %h", i, uut.datapathcomp.RF.register[i]);
	end
	
// 	$display("");
// 	$display("==== Register Contents SYSCALL ====");
// 	for (i = 0; i < 32; i = i + 1) begin
// 		$display("R%0d = %h", i, uut.datapathcomp.RF_syscall.register[i]);
// 	end

    $finish;
  end
endmodule