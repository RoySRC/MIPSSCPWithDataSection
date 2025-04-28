// Code your design here
// file: control.v


`timescale 1ns/1ns

module Controlunit(
	input [5:0] Opcode, 
	input [5:0] Func,
	input Zero,
	output reg MemtoReg,
	output reg  MemWrite,
	output reg  ALUSrc,
	output reg  RegDst,
	output reg  RegWrite,
	output reg  Jump,
	output reg  JAL,
	output reg  JR,
	output PCSrc,
	output reg  [5:0] ALUControl,
	output wire syscall,   // <== NEW: syscall output
	output reg start_mult, // mult instruction wires
	output reg mfhi_sel,   // mult instruction wires
	output reg mflo_sel    // mult instruction wires
);
                              
reg [12:0] temp;
reg Branch,B;

// Detect syscall instruction
assign syscall = (Opcode == 6'b000000) && (Func == 6'b001100);  // <== NEW

always @(*) begin 

    case (Opcode) 
        6'b000000: begin                          // R-type
                temp = 13'b0001100000000;        

                case (Func)
                    6'b100000: ALUControl = 6'b000000;    // ADD
                    6'b100001: ALUControl = 6'b000000;    // ADDU
                    6'b100010: ALUControl = 6'b000001;    // SUB
                    6'b100011: ALUControl = 6'b000001;    // SUBU
                    6'b100100: ALUControl = 6'b000010;    // AND
                    6'b100101: ALUControl = 6'b000011;    // OR
                    6'b100110: ALUControl = 6'b000100;    // XOR
                    6'b100111: ALUControl = 6'b001010;    // NOR
                    6'b101010: ALUControl = 6'b001000;    // SLT
                    6'b101011: ALUControl = 6'b001001;    // SLTU
                    6'b000000: ALUControl = 6'b000101;    // SLL
                    6'b000010: ALUControl = 6'b000110;    // SRL
                    6'b000011: ALUControl = 6'b000111;    // SRA
                    6'b000100: ALUControl = 6'b001011;    // SLLV
                    6'b000110: ALUControl = 6'b001100;    // SRLV
                    6'b000111: ALUControl = 6'b001101;    // SRAV
                    6'b001000: ALUControl = 6'b001111;    // JR
                    6'b001100: ALUControl = 6'b001100;	   // SYSCALL
                    6'b011000: begin  // MULT
						ALUControl = 6'b000000; // Can be duplicated because ctrl goes to alu64
						temp = 13'b1001100000000;
					end
					6'b010000: begin  // MFHI
						// control goes to alu32
						ALUControl = 6'b000000; // Don't care
						temp = 13'b0101100000000;
					end
					6'b010010: begin  // MFLO
						// control goes to alu32
						ALUControl = 6'b000000; // Don't care
						temp = 13'b0011100000000;
					end
                endcase

        end

        6'b100011: begin                          // LW
                        temp = 13'b0001010010000;     
                        ALUControl = 6'b000000;
                    end

        6'b101011: begin                          // SW
                         temp = 13'b0000010100000;      
                         ALUControl = 6'b000000;
                    end  

        6'b000100: begin                          // BEQ
                         temp = 13'b0000001000000;      
                        ALUControl = 6'b000001; 
                    end      

        6'b000101: begin                          // BNE
                        temp = 13'b0000001000001;  
                        ALUControl = 6'b000001; 
                    end

        6'b001000: begin                          // ADDI
                        temp = 13'b0001010000000;  
                        ALUControl = 6'b000000; 
                    end  

        6'b001001: begin                          // ADDIU
                        temp = 13'b0001010000000;  
                        ALUControl = 6'b000000; 
                    end  

        6'b001100: begin                          // ANDI
                        temp = 13'b0001010000000;  
                        ALUControl = 6'b000010; 
                    end 

        6'b001101: begin                          // ORI
                        temp = 13'b0001010000000;  
                        ALUControl = 6'b000011; 
                    end  

        6'b001110: begin                          // XORI
                        temp = 13'b0001010000000;  
                        ALUControl = 6'b000100; 
                    end       

        6'b001010: begin                          // SLTI
                        temp = 13'b0001010000000;  
                        ALUControl = 6'b001000; 
                    end 

        6'b001011: begin                          // SLTIU
                        temp = 13'b0001010000000;  
                        ALUControl = 6'b001001; 
                    end  

        6'b000010: begin                          // J
                        temp = 13'b0000000001000;  
                        ALUControl = 6'b000010; 
                    end 
        6'b000011: begin                          // JAL
                        temp = 13'b0001000000100;  
                        ALUControl = 6'b000010; 
                    end 
        6'b000011: begin                          // JR
                        temp = 13'b0000000000010;  
                        ALUControl = 6'b001111; 
                    end 
        6'b001111:  begin                         // LUI
                        temp = 13'b0001010000000;  
                        ALUControl = 6'b001110; 
                    end          
        default:   begin
        	temp = 15'bxxxxxxxxxxxxxxx;      // NOP
        end
    endcase
   

    // each of these are 1-bit
    {start_mult,mfhi_sel,mflo_sel,RegWrite,RegDst,ALUSrc,Branch,MemWrite,MemtoReg,Jump,JAL,JR,B} = temp;
    // $display("RegWrite : %d, RegDst : %d, ALUSrc : %d, Branch : %d, MemWrite : %d, MemtoReg : %d, Jump : %d, JAL : %d, JR : %d, B : %d",
//     RegWrite,RegDst,ALUSrc,Branch,MemWrite,MemtoReg,Jump,JAL,JR,B);
// 	$display("control::start_mult: %b", start_mult);
// 	$display("control::temp: %b", temp);

end 

assign PCSrc = Branch & (Zero ^ B);



endmodule