// file: ALU.v


`timescale 1ns/1ns

module alu64( input [31:0] a, 
            input [31:0] b,
            input [5:0] f,
            input [4:0] shamt,
            output reg [63:0] y, 
            output reg zero);

always @ (*) begin
    case (f)
        6'b000000: begin
        	y = $signed(a) * $signed(b);                             // MULT
		end
    endcase
         zero = (y==8'b0);
     end
endmodule