# Verilog
Understanding the operation of registers (Verilog)

The following file(proc.v) is written in Verilog. It implements registers by creating, reading, writing values from the registers. It's execution could be examined by running it with the test benches provided with it. 
The file has the significant use of the following modules included 
   yAdder  (adds two inputs togather),
   yMux    (works similar to a conditional operator. Choses input based on a value(cin, 1 bit) supplied),
   add_pipe, 
   mult_pipe,
   idexwb_pipe,
   if_pipe.
The first test bench executed the operation of add_pipe which basically adds two source registers or adds a source register with the immediate. 
The second test bench executes the operation of idexwb_pipe which basically is registers being called from the memory (read) and register being over written (write). 
The last test bench executes the operation of if_pipe which basically shows how the data is read from the memory address after its loaded.
