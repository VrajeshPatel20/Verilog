module Labtest;
   parameter WIDTH = 32;
   
   reg [WIDTH-1:0]    a, b, expa;
   wire [2*WIDTH-1:0] m;
   wire [WIDTH-1:0]   addout;
   integer 	      i,j;
   reg [2*WIDTH-1:0]  expm;
   reg 		      clk, rst, start;
   reg [4:0] 	      Rdin;
   wire [4:0] 	      Rdout;

   add_pipe #(WIDTH) testm(addout, a, b, start, Rdin, Rdout, clk, rst);
   initial begin
      clk   = 1'b0;
      rst   = 1'b0; #1 rst   = 1'b1; #1 rst   = 1'b0; 
      start = 1'b0;
      #1 rst = 1'b1; #1;
      for (i=0; i<40; i++) begin
	 a = $random;
	 b = $random;
	 Rdin = i;
	 expm = a*b;
	 expa = (a+b) & {WIDTH{1'b1}};
	 start = 1'b1;
	 #1 clk = 1'b1;
	 #1 clk = 1'b0;
	 //$display($time, ", a: %d, b: %d, m: %d, Rdout: %d, expm: %d, Rdin: %d", a, b, m, Rdout, expm, Rdin);
	 $display($time, ", a: %d, b: %d, addout: %d, Rdout: %d, expa: %d, Rdin: %d", a, b, addout, Rdout, expa, Rdin);
      end
      $finish;
   end // initial begin
endmodule // LabM
