//Vrajesh Patel
//4th December 2020
//EECS login: vrajesh1
//

`define OPNOP  3'b000
`define OPADD  3'b001
`define OPMUL  3'b010
`define OPADDI 3'b011

module rfile(R1,R2,W,WD,Wctl,RD1,RD2,clock,rst);
   parameter WIDTH = 16;
   input [4:0]            R1,R2,W;   // Select what to read/write
   input [WIDTH-1:0] 	  WD;
   input 	          Wctl, clock, rst;
   output [WIDTH-1:0] 	  RD1,RD2;
   reg signed [WIDTH-1:0] RF[31:0];
   genvar 		  i;
   
   assign RD1 = RF[R1];
   assign RD2 = RF[R2];
   generate
      for (i=0; i<32; i=i+1) begin:thislab
      always @(negedge rst) begin
         RF[i] <= {WIDTH{1'b0}};
      end
   end
   endgenerate
   always @(posedge clock)
     if (Wctl) RF[W] <= WD;
endmodule

module yAdder1(z, cout, a, b, cin); 
   output z, cout; 
   input  a, b, cin; 
   xor left_xor(tmp, a, b); 
   xor right_xor(z, cin, tmp); 
   and left_and(outL, a, b); 
   and right_and(outR, tmp, cin); 
   or my_or(cout, outR, outL); 
endmodule // yAdder1

module yMux1(z, a, b, c); 
   output z; 
   input  a, b, c; 
   wire   notC, upper, lower; 
   not my_not(notC, c); 
   and upperAnd(upper, a, notC); 
   and lowerAnd(lower, c, b); 
   or my_or(z, upper, lower); 
endmodule // yMux1

module yMux(z, a, b, c); 
   parameter SIZE = 7; 
   output [SIZE-1:0] z; 
   input [SIZE-1:0]  a, b; 
   input             c; 
   yMux1 mine[SIZE-1:0](z, a, b, c); 
endmodule // yMux

module yMux4to1(z, a0,a1,a2,a3, c); 
   parameter SIZE = 2; 
   output [SIZE-1:0] z; 
   input [SIZE-1:0]  a0, a1, a2, a3; 
   input [1:0]       c; 
   wire [SIZE-1:0]   zLo, zHi; 
   yMux #(SIZE) lo(zLo, a0, a1, c[0]); 
   yMux #(SIZE) hi(zHi, a2, a3, c[0]); 
   yMux #(SIZE) final(z, zLo, zHi, c[1]); 
endmodule // yMux4to1

module yMux8to1(z, a0,a1,a2,a3, a4, a5, a6, a7, c); 
   parameter SIZE = 2; 
   output [SIZE-1:0] z; 
   input [SIZE-1:0]  a0, a1, a2, a3, a4, a5, a6, a7; 
   input [2:0]       c; 
   wire [SIZE-1:0]   zLo, zHi; 
   yMux4to1 #(SIZE) lo(zLo, a0, a1, a2, a3, c[1:0]); 
   yMux4to1 #(SIZE) hi(zHi, a4, a5, a6, a7, c[1:0]); 
   yMux #(SIZE) final(z, zLo, zHi, c[2]); 
endmodule // yMux4to1

module yAdder(s, cout, a, b, cin);
   parameter SIZE = 2;
   output [SIZE-1:0] s; 
   output        cout; 
   input [SIZE-1:0]  a, b; 
   input         cin; 
   wire [SIZE-1:0]       in, out; 
   yAdder1 mine[SIZE-1:0](s, out, a, b, in); 
   assign {cout,in} = {out,cin};
endmodule // yAdder


module mult2(m,a,b);
   input [1:0] a, b;
   output [3:0] m;

   assign m[3] = a[1]&a[0]&b[1]&b[0];
   assign m[2] = a[1]&~a[0]&b[1] | a[1]&b[1]&~b[0];
   assign m[1] = a[1]&b[0]&(~b[1]|~a[0]) | a[0]&b[1]&(~a[1]|~b[0]);
   assign m[0] = a[0]&b[0];
endmodule // mult2

module mult4(m,a,b);
   parameter WIDTH = 4;
   input [WIDTH-1:0]        a, b;
   output [2*WIDTH-1:0]     m;
   wire [WIDTH-1:0] 	    a1b1, a1b0, a0b1, a0b0;
   wire [WIDTH:0] 	    a1b0pa0b1;
   wire 		    nowhere;
   
   mult2 m3(a1b1,a[WIDTH-1:WIDTH/2],b[WIDTH-1:WIDTH/2]);
   mult2 m2(a1b0,a[WIDTH-1:WIDTH/2],b[WIDTH/2-1:0]);
   mult2 m1(a0b1,a[WIDTH/2-1:0],b[WIDTH-1:WIDTH/2]);
   mult2 m0(a0b0,a[WIDTH/2-1:0],b[WIDTH/2-1:0]);

   yAdder #(WIDTH) a0(a1b0pa0b1[WIDTH-1:0],a1b0pa0b1[WIDTH],a1b0,a0b1,1'b0);
   yAdder #(2*WIDTH) a1(m, nowhere,
			  {a1b1,a0b0},
			  {{(WIDTH/2-1){1'b0}},a1b0pa0b1,{(WIDTH/2){1'b0}}},1'b0);
endmodule // mult4

module mult4_stg(mr,a,b,start,clk, rst);
   parameter WIDTH = 4;
   input [WIDTH-1:0]        a, b;
   output reg [2*WIDTH-1:0] mr;
   input 		    start, clk, rst;
   wire [2*WIDTH-1:0] 	    m;

   mult4 mult(m, a, b);
   always @(negedge rst) begin
      mr = {(2*WIDTH){1'b0}};
   end
   always @(posedge clk) begin
      if (start) mr = m;
   end // always @ (posedge clk)
endmodule // mult4_stg

module mult8_stg(mr,a,b,start,clk, rst);
   parameter WIDTH = 8;
   input [WIDTH-1:0]        a, b;
   output reg [2*WIDTH-1:0] mr;
   input 		    start, clk, rst;
   wire [2*WIDTH-1:0] 	    m;
   wire [WIDTH-1:0] 	    a1b1, a1b0, a0b1, a0b0;
   wire [WIDTH:0] 	    a1b0pa0b1;
   wire 		    nowhere;
   
   mult4_stg m3(a1b1,a[WIDTH-1:WIDTH/2],b[WIDTH-1:WIDTH/2],start,clk, rst);
   mult4_stg m2(a1b0,a[WIDTH-1:WIDTH/2],b[WIDTH/2-1:0],start,clk, rst);
   mult4_stg m1(a0b1,a[WIDTH/2-1:0],b[WIDTH-1:WIDTH/2],start,clk, rst);
   mult4_stg m0(a0b0,a[WIDTH/2-1:0],b[WIDTH/2-1:0],start,clk, rst);

   yAdder #(WIDTH) a0(a1b0pa0b1[WIDTH-1:0],a1b0pa0b1[WIDTH],a1b0,a0b1,1'b0);
   yAdder #(2*WIDTH) a1(m, nowhere,
			  {a1b1,a0b0},
			  {{(WIDTH/2-1){1'b0}},a1b0pa0b1,{(WIDTH/2){1'b0}}},1'b0);
   always @(negedge rst) begin
      mr = {(2*WIDTH){1'b0}};
   end
   always @(posedge clk) begin
      if (start) mr = m;
   end // always @ (posedge clk)
endmodule // mult4_stg


module mult_width(mr,a,b,start,clk, rst);
   parameter WIDTH = 16;
   input [WIDTH-1:0]        a, b;
   output reg [2*WIDTH-1:0] mr;
   input 		    start, clk, rst;
   wire [2*WIDTH-1:0] 	    m;
   wire [WIDTH-1:0] 	    a1b1, a1b0, a0b1, a0b0;
   wire [WIDTH:0] 	    a1b0pa0b1;
   wire 		    nowhere;

   generate
      if (WIDTH==8) begin
	 mult4_stg m3(a1b1,a[WIDTH-1:WIDTH/2],b[WIDTH-1:WIDTH/2],start,clk, rst);
	 mult4_stg m2(a1b0,a[WIDTH-1:WIDTH/2],b[WIDTH/2-1:0],start,clk, rst);
	 mult4_stg m1(a0b1,a[WIDTH/2-1:0],b[WIDTH-1:WIDTH/2],start,clk, rst);
	 mult4_stg m0(a0b0,a[WIDTH/2-1:0],b[WIDTH/2-1:0],start,clk, rst);
      end
      else begin
	 mult_width #(WIDTH/2) m3(a1b1,a[WIDTH-1:WIDTH/2],b[WIDTH-1:WIDTH/2],start,clk, rst);
	 mult_width #(WIDTH/2) m2(a1b0,a[WIDTH-1:WIDTH/2],b[WIDTH/2-1:0],start,clk, rst);
	 mult_width #(WIDTH/2) m1(a0b1,a[WIDTH/2-1:0],b[WIDTH-1:WIDTH/2],start,clk, rst);
	 mult_width #(WIDTH/2) m0(a0b0,a[WIDTH/2-1:0],b[WIDTH/2-1:0],start,clk, rst);
      end // else: !if(WIDTH==8)
      
      yAdder #(WIDTH) a0(a1b0pa0b1[WIDTH-1:0],a1b0pa0b1[WIDTH],a1b0,a0b1,1'b0);
      yAdder #(2*WIDTH) a1(m, nowhere,
			   {a1b1,a0b0},
			   {{(WIDTH/2-1){1'b0}},a1b0pa0b1,{(WIDTH/2){1'b0}}},1'b0);
   endgenerate
   always @(negedge rst) begin
      mr = {(2*WIDTH){1'b0}};
   end
   always @(posedge clk) begin
      if (start) mr = m;
   end // always @ (posedge clk)
endmodule // mult4_stg

module mult_pipe(mr,a,b,start,Rdin,Rdout,clk, rst);
   parameter WIDTH = 16;
   localparam levels = $clog2(WIDTH)-1;
   
   input [WIDTH-1:0]       a, b;
   output [2*WIDTH-1:0]    mr;
   input [4:0] 		   Rdin;
   output [4:0] 	   Rdout;
   input 		   start, clk, rst;
   reg [4:0] 		   Rd_pipe[levels-1:0];
   genvar 		   i;

   mult_width #(WIDTH) mw(mr,a,b,start,clk, rst);
   generate
      for (i=0; i<levels; i = i+1)
	always @(negedge rst)
	  Rd_pipe[i] = {5{1'b0}};
      for (i=0; i<levels-1; i = i+1)
	always @(posedge clk) 
	  if (start) Rd_pipe[i+1] <= Rd_pipe[i];
   endgenerate
   always @(posedge clk) 
     if (start) Rd_pipe[0] <= Rdin;
   assign Rdout = Rd_pipe[levels-1];

endmodule // mult_pipe


module add_pipe(ar,a,b,start,Rdin,Rdout,clk, rst);
 parameter WIDTH = 16;
   localparam levels = $clog2(WIDTH)-1;
   wire [WIDTH-1:0]       mars;
   input [WIDTH-1:0]       a, b;
   output [WIDTH-1:0]    ar;
   input [4:0] 		   Rdin;
   output  [4:0] 	   Rdout;
   input 		   start, clk, rst;
   reg [WIDTH-1:0] 		   Rd_pipe[levels-1:0];
   reg [WIDTH-1:0]         Rd_pipeout[levels-1:0];
   genvar 		   i;
   
   wire x;
   yAdder #(WIDTH) mw(mars,x,a,b,1'b0);

 generate

        for (i = 0; i < levels; i = i + 1)
            always @(negedge rst) begin
                Rd_pipe[i] = {10{1'b0}};
                Rd_pipeout[i] = {10{1'b0}};
            end

        for (i = 0; i < levels-1; i = i + 1) begin
             always @(posedge clk) 
                if(start) begin
                    Rd_pipe[i+1] <= Rd_pipe[i];
                    Rd_pipeout[i+1] <= Rd_pipeout[i];
                end
             
        end 
      endgenerate


   always @(posedge clk)
        if(start) begin
            Rd_pipe[0] <= Rdin;
            Rd_pipeout[0] <= mars;
        end
        assign ar = Rd_pipeout[levels-1];
        assign Rdout =  Rd_pipe[levels-1];
endmodule // add_pipe


module predecode(opcode, Rs1, Rs2, Rd, imm, ins);
   parameter WIDTH = 16;
   output [2:0]         opcode;
   output [4:0] 	Rs1, Rs2, Rd;
   output [11:0] 	imm;
   input [31:0] 	ins;

   assign opcode = ins[2:0];
   assign Rs1    = ins[7:3];
   assign Rd     = ins[12:8];
   assign Rs2    = ins[17:13];
   assign imm    = ins[24:13];
endmodule // predecode




module idexwb_pipe(res, Rdout, opcode, Rs1, Rs2, Rd, imm, start, clk, rst);

parameter WIDTH = 16;
parameter SIZE = 5;
output [WIDTH-1:0]res;
output [4:0] Rdout;
input [4:0] Rs1,Rs2;
input [4:0]Rd;
input signed [11:0] imm;
input [2:0] opcode;
input start,clk,rst;
wire [WIDTH-1:0] RD1,RD2;
reg [31:0] empty;
wire [4:0] Rdout1,Rdout2,Rdout3;
wire [WIDTH-1:0] val1,val3,val4;
wire [2*WIDTH-1:0] val2;


//choose whether its add or addi;
wire [4:0] Rdin2, Rdin1,Rdin;

//sign extending the bit value for imm
wire [31:0] immnew;
wire [19:0] zeros, ones;
wire [31:0] immOut, saveImm;
assign zeros = 20'h00000;
assign ones = 20'hFFFFF;
assign saveImm[11:0] = imm; 
assign immOut[11:0] = imm;
yMux #(20) se(immOut[31:12], zeros, ones, imm[11]);
yMux #(20) saveImmSe(saveImm[31:12], zeros, ones, imm[11]);
yMux #(32) immSelection(immnew, immOut, saveImm, imm[5]);

assign Rdin2 = (opcode === 3'b001)? Rd:0;
assign Rdin1 = (opcode === (3'b010)) ? Rd:0;
assign Rdin = (opcode === 3'b011) ? Rd:0;

wire [WIDTH-1:0] var1,var2,var3;

wire [WIDTH-1:0] RDnew,RDnew1,RDnew2;
assign ch1 = (opcode === 3'b001) ? 1:0;
assign ch2 = (opcode === 3'b010) ? 1:0;
assign ch3 = (opcode === 3'b011) ? 1:0;

wire [WIDTH-1:0] helper;
assign helper = 32'b0;

yMux #(WIDTH) nowhere (RDnew,helper,RD1,ch1);
yMux #(WIDTH) now (RDnew2,helper,RD1,ch3);
yMux #(WIDTH) notnow (RDnew1, helper,RD1,ch2);

assign tmp = (opcode === 3'b001) ? 1:0;
assign tmp1 = (opcode === 3'b010) ? 1:0;
assign tmp4 = (opcode === 3'b011) ? 1:0;

//assign tmp3 = tmp&Rdin2;
yMux #(WIDTH) stageI (var1,helper,RD2,tmp);
yMux #(WIDTH) stageII (var3,helper,immnew,tmp4);
yMux #(WIDTH) stageIII (var2,helper,RD2,tmp1);

add_pipe #(WIDTH) call1 (val1,RDnew,var1,start,Rdin2,Rdout1,clk,rst);
add_pipe #(WIDTH) call3 (val3,RDnew2,var3,start,Rdin,Rdout3,clk,rst);
mult_pipe #(WIDTH) call2 (val2,RDnew1,var2,start,Rdin1,Rdout2,clk,rst);

assign res = val2[WIDTH-1:0] | (val1 | val3);

assign Rdout = Rdout1 | Rdout2 | Rdout3;

rfile #(WIDTH) regs (Rs1, Rs2, Rdout, res, (|Rdout), RD1, RD2, clk, rst);

endmodule



module if_pipe(ins, start, clk, rst);
    parameter WIDTH = 32;
   output reg [31:0] ins;
   input start,clk,rst;
   reg [31:0] 	       imem[63:0];
   reg [WIDTH-1:0]     PC;

   always @(posedge rst) begin
         $readmemb("compmem.dat", imem, 6'd0, 6'd22);
          PC = 0;
         end 

            
   always @(posedge clk) 
        if(start) begin
            PC <= PC + 1;
            ins <= imem[PC];
        end
    
endmodule // if_pipe
