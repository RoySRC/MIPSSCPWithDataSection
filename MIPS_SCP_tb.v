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
	for (i = 0; i < 128; i = i + 1) begin
		$display("DMEM[0x%08X] = 0x%08X", 32'h10010000 + (i << 2), 
		uut.dmem.Dmem[i]);
	end

	$display("");
	$display("==== Final IMEM Contents ====");
	for (i = 0; i < 128; i = i + 1) begin
		$display("IMEM[0x%08X] = 0x%08X", 32'h10010000 + (i << 2), 
		uut.imem.Imem[i]);
	end

    $finish;
  end
endmodule