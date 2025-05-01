// file: ram.v
// author: @mohamed_minawi
`timescale 1ns/1ns

module ram(
  clk,
  we, // write enable
  addr,
  din,
  dout
);

parameter depth = 512;
parameter bits = 32;
parameter width = 32;

input clk, we;
input [bits-1:0] addr;
input [width-1:0] din;

output [width-1:0] dout;

reg [width-1:0] dout_reg;
assign dout = dout_reg;

reg [width-1:0] Dmem [depth-1:0];


initial begin
    //$readmemb("test_input/ds.test.out.no_address.data.bin", Dmem);
    //$readmemb("test_input/ds.test.out.no_address.data.bin", Dmem);
    // $readmemb("test_input/increment_array.out.no_address.data.bin", Dmem);
//     $display("INFO: RAM initialized");

    // Optional: print first 10 memory locations for verification
//     $display("INFO: First 10 entries of RAM following initialization:");
end

// assign dout = Dmem[addr];
    
always @(posedge clk) begin
    if (we) begin
      if (addr[1:0] != 2'b00) begin
        $display("WARNING: Unaligned access at addr %08h", addr);
        $finish;
      end
      Dmem[addr[31:2]] <= din;
//       $display("INFO: RAM write - Addr: 0x%08X (word %0d), Data: 0x%08X", addr, addr[31:2], din);
    end
end

always @(*) begin
  dout_reg = Dmem[addr[31:2]];
//   $display("INFO: RAM read  - Addr: 0x%08X (word %0d), Data: 0x%08X", addr, addr[31:2], dout_reg);
end


//assign dout = Dmem[addr];   


endmodule