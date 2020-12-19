`define OPNOP  3'b000
`define OPADD  3'b001
`define OPMUL  3'b010
`define OPADDI 3'b011

module Labtest;
   parameter WIDTH = 32;

   reg 			   start, clk, rst;
   wire [31:0] 		   ins;
   wire [4:0] 		   Rs1, Rs2, Rd;
   wire [11:0] 		   imm; 
   wire [2:0] 		   opcode;
   wire signed [WIDTH-1:0] res;
   wire [4:0] 		   Rdout;
   integer 		   i;
   
   if_pipe #(WIDTH) IF(ins, start, clk, rst);
   predecode #(WIDTH) ID1(opcode, Rs1, Rs2, Rd, imm, ins);
   idexwb_pipe #(WIDTH) tst(res, Rdout, opcode, Rs1, Rs2, Rd, imm, start, clk, rst);
   initial begin
      clk    = 1'b0;
      rst    = 1'b0; #1 rst   = 1'b1; #1 rst   = 1'b0; 
      start  = 1'b0;
      #1 rst = 1'b1; #1;
      start  = 1'b1;
      for (i=1; i<20; i++) begin // a few clock cycles to execute all instructions
	 #1 clk = 1'b1; #1 clk = 1'b0;
	 //$display("ins: %32b, PC: %d, opcode: %3b", ins, IF.PC, opcode);
	 $display($time, ", Rdout: %4d, res: %d", Rdout, res);
      end
      for (i=1; i<10; i++) begin // Print the contents of the register file
	 $display("regs[%2d] = %d", i, tst.regs.RF[i]);
      end
   end
endmodule // Labtest
