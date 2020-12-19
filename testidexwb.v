`define OPNOP  3'b000
`define OPADD  3'b001
`define OPMUL  3'b010
`define OPADDI 3'b011

module Labtest;
   parameter WIDTH = 32;

   reg signed [WIDTH-1:0]  expres;
   wire signed [WIDTH-1:0] res;
   reg [4:0] 		   Rs1, Rs2, Rd;
   reg [2:0] 		   opcode;
   reg 			   start, clk, rst;
   reg signed [11:0] 	   imm;
   wire [4:0] 		   Rdout;
   integer 		   i;
   
   idexwb_pipe #(WIDTH) tst(res, Rdout, opcode, Rs1, Rs2, Rd, imm, start, clk, rst);
   initial begin
      clk    = 1'b0;
      rst    = 1'b0; #1 rst   = 1'b1; #1 rst   = 1'b0; 
      start  = 1'b0;
      #1 rst = 1'b1; #1;
      start  = 1'b1;
      opcode = `OPADDI;
      for (i=1; i<32; i++) begin
	 imm = $random;
	 Rs1 = 0;
	 Rs2 = i;		// not used here
	 Rd  = i;
	 #1 clk = 1'b1;
	 #1 clk = 1'b0;
	 $display($time, ", i: %4d, imm: %d, Rdout: %d, res: %d", i, imm, Rdout, res);
	 // $display("tst.do_add: %d", tst.do_add);
	 // Use a statement like the one above to inspect an intity within a
	 // module. In this case the wire do_add within the module instance tst of
	 // idexwb_pipe.
      end // for (i=1; i<32; i++)
      for (i=1; i<5; i++) begin // a few clock cycles to empty the pipeline
	 #1 clk = 1'b1; #1 clk = 1'b0;
	 $display($time, ", i: %4d, imm: %d, Rdout: %d, res: %d", i, imm, Rdout, res);
      end
      for (i=1; i<32; i++) begin // Print the contents of the register file
	 $display("regs[%2d] = %d", i, tst.regs.RF[i]);
      end
      opcode = `OPMUL;
      for (i=1; i<=9; i+=3) begin
	 Rs1   = i;
	 Rs2   = i+1;
	 Rd    = i+2;
	 expres= tst.regs.RF[i] * tst.regs.RF[i+1];
	 #1 clk = 1'b1; #1 clk = 1'b0;
	 $display($time, ", Rdout: %4d, expres: %d, res: %d", Rdout, expres, res);
      end
      for (i=1; i<5; i++) begin // a few clock cycles to empty the pipeline
	 #1 clk = 1'b1; #1 clk = 1'b0;
	 $display($time, ", Rdout: %4d, expres: %d, res: %d", Rdout, expres, res);
      end
      for (i=1; i<32; i++) begin // Print the contents of the register file
	 $display("regs[%2d] = %d", i, tst.regs.RF[i]);
      end
      opcode = `OPADD;
      for (i=10; i<=18; i+=3) begin
	 Rs1   = i;
	 Rs2   = i+1;
	 Rd    = i+2;
	 expres= tst.regs.RF[i] + tst.regs.RF[i+1];
	 #1 clk = 1'b1; #1 clk = 1'b0;
	 $display($time, ", Rdout: %4d, expres: %d, res: %d", Rdout, expres, res);
      end
      for (i=1; i<5; i++) begin // a few clock cycles to empty the pipeline
	 #1 clk = 1'b1; #1 clk = 1'b0;
	 $display($time, ", Rdout: %4d, expres: %d, res: %d", Rdout, expres, res);
      end
      for (i=1; i<32; i++) begin // Print the contents of the register file
	 $display("regs[%2d] = %d", i, tst.regs.RF[i]);
      end
      $finish;
   end // initial begin
endmodule // Labtest
