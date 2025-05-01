// file: rom.v


`timescale 1ns/1ns

module rom(addr,dout);

parameter depth = 8192;
parameter bits = 32;
parameter width = 32;


input [bits-1:0] addr;
output [width-1:0] dout;

reg [width-1:0] Imem[depth-1:0];
    
initial begin
    //$readmemb("test_input/increment_array.out.no_address.text.bin", Imem);
    //$readmemb("test.bin", Imem);
    //$readmemb("test_input/ds.test.out.no_address.text.bin", Imem);
    //$readmemb("test_input/increment_array.out.no_address.text.bin", Imem);
end 


assign dout= Imem[addr/4]; 



endmodule