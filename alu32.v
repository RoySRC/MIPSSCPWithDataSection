// file: ALU.v


`timescale 1ns/1ns

module alu32( input [31:0] a, 
            input [31:0] b,
            input [5:0] f,
            input [4:0] shamt,
            output reg [31:0] y, 
            output reg zero);

always @ (*) begin

    case (f)
        6'b000000: y = a + b;                             // ADD
        6'b000001: y = a - b;                             // SUB
        6'b000010: y = a & b;                             // AND
        6'b000011: y = a | b;                             // OR
        6'b000100: y = a ^ b;                             // XOR
        6'b000101: y = b << shamt;                        // SLL
        6'b000110: y = b >> shamt;                        // SRL
        6'b000111: y = $signed($signed(b) >>> shamt);     // SRA
        6'b001000: y = $signed(a) < $signed(b) ? 1 : 0;   // SLT
        6'b001001: y = a < b ? 1 : 0;                     // SLTU
        6'b001010: y = ~ (a | b);                         // NOR 
        6'b001011: y = b << a;                            // SLLV
        6'b001100: y = b >> a;                            // SRLV
        6'b001101: y = $signed($signed(b) >>> a);         // SRAV
        6'b001110: y = {b[15:0], 16'b0};                  // LUI
        6'b001111: y = a;                                  // JR
    endcase
         zero = (y==8'b0);
     end
endmodule