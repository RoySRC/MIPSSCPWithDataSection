// Code your design here
// file: control.v


`timescale 1ns/1ns

module Controlunit(input [5:0] Opcode, 
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
               output reg  [3:0] ALUControl
               );
               
reg [9:0] temp;
reg Branch,B;

always @(*) begin 

    case (Opcode) 
        6'b000000: begin                          // R-type
                temp <= 10'b1100000000;        

                case (Func)
                    6'b100000: ALUControl <= 4'b0000;    // ADD
                    6'b100001: ALUControl <= 4'b0000;    // ADDU
                    6'b100010: ALUControl <= 4'b0001;    // SUB
                    6'b100011: ALUControl <= 4'b0001;    // SUBU
                    6'b100100: ALUControl <= 4'b0010;    // AND
                    6'b100101: ALUControl <= 4'b0011;    // OR
                    6'b100110: ALUControl <= 4'b0100;    // XOR
                    6'b100111: ALUControl <= 4'b1010;    // NOR
                    6'b101010: ALUControl <= 4'b1000;    // SLT
                    6'b101011: ALUControl <= 4'b1001;    // SLTU
                    6'b000000: ALUControl <= 4'b0101;    // SLL
                    6'b000010: ALUControl <= 4'b0110;    // SRL
                    6'b000011: ALUControl <= 4'b0111;    // SRA
                    6'b000100: ALUControl <= 4'b1011;    // SLLV
                    6'b000110: ALUControl <= 4'b1100;    // SRLV
                    6'b000111: ALUControl <= 4'b1101;    // SRAV
                    6'b001000: ALUControl <= 4'b1111;    // JR
                endcase

            end

        6'b100011: begin                          // LW
                        temp <= 10'b1010010000;     
                        ALUControl <= 4'b0000;
                    end

        6'b101011: begin                          // SW
                         temp <= 10'b0010100000;      
                         ALUControl <= 4'b0000;
                    end  

        6'b000100: begin                          // BEQ
                         temp <= 10'b0001000000;      
                        ALUControl <= 4'b0001; 
                    end      

        6'b000101: begin                          // BNE
                        temp <= 10'b0001000001;  
                        ALUControl <= 4'b0001; 
                    end

        6'b001000: begin                          // ADDI
                        temp <= 10'b1010000000;  
                        ALUControl <= 4'b0000; 
                    end  

        6'b001001: begin                          // ADDIU
                        temp <= 10'b1010000000;  
                        ALUControl <= 4'b0000; 
                    end  

        6'b001100: begin                          // ANDI
                        temp <= 10'b1010000000;  
                        ALUControl <= 4'b0010; 
                    end 

        6'b001101: begin                          // ORI
                        temp <= 10'b1010000000;  
                        ALUControl <= 4'b0011; 
                    end  

        6'b001110: begin                          // XORI
                        temp <= 10'b1010000000;  
                        ALUControl <= 4'b0100; 
                    end       

        6'b001010: begin                          // SLTI
                        temp <= 10'b1010000000;  
                        ALUControl <= 4'b1000; 
                    end 

        6'b001011: begin                          // SLTIU
                        temp <= 10'b1010000000;  
                        ALUControl <= 4'b1001; 
                    end  

        6'b000010: begin                          // J
                        temp <= 10'b0000001000;  
                        ALUControl <= 4'b0010; 
                    end 
        6'b000011: begin                          // JAL
                        temp <= 10'b1000000100;  
                        ALUControl <= 4'b0010; 
                    end 
        6'b000011: begin                          // JR
                        temp <= 10'b0000000010;  
                        ALUControl <= 4'b1111; 
                    end 
        6'b001111:  begin                         // LUI
                        temp <= 10'b1010000000;  
                        ALUControl <= 4'b1110; 
                    end          
        default:   temp <= 12'bxxxxxxxxxxxx;      // NOP
    endcase
   

    
    {RegWrite,RegDst,ALUSrc,Branch,MemWrite,MemtoReg,Jump,JAL,JR,B} = temp;

end 

assign PCSrc = Branch & (Zero ^ B);



endmodule