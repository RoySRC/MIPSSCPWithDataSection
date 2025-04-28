// file: REGISTER FILE.v


`timescale 1ns/1ns

module registerfile32 (input clk,
                    input we, 
                    input reset,
                    input [4:0] ra1,
                    input [4:0] ra2,
                    input [4:0] wa,     // write address
                    input [31:0] wd,    // write data
                    output [31:0] rd1, 
                    output [31:0] rd2); 
                    
parameter sp_fp_base = 512;                     
reg [31:0] register [31:0];

assign rd1 = register[ra1];
assign rd2 = register[ra2];

integer i;

initial begin
    for (i=1; i<32; i=i+1) begin
         register[i] <= 32'd0;
	end
	register[0] = 0;
    register[28] = 32'h00000400; // $gp
    register[29] = sp_fp_base; // $sp
    register[30] = sp_fp_base; // $fp
end
    
always @(posedge clk)
begin
    if(reset) begin
    	for(i = 0; i < 32; i = i + 1) register[i] = 32'd0;
    	register[0] = 0;
		register[28] = 32'h00000400; // $gp
		register[29] = sp_fp_base; // $sp
		register[30] = sp_fp_base; // $fp
    end
    else if (we)
        if(wa != 0) register[wa] = wd;
    
end

endmodule