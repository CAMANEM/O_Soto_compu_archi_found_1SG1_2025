module Alu_4b (
    input  logic [3:0] A,
    input  logic [3:0] B,
    input  logic [1:0] sel,      // Selector para operación
    output logic [3:0] result,
	 output logic [3:0] flags  // 3=Z 2=N 1=C 0=o_f

);
    logic [3:0] and_result;
	 logic [3:0] and_flags;
	 
    logic [3:0] xor_result;
    logic [3:0] xor_flags;
	 
	 logic [3:0] sub_result;
    logic [3:0] sub_flags;
	 
	 logic [3:0] mul_result;
	 logic [3:0] mul_flags;
	
	 and_4b u_and (.A(A),
						.B(B), 
						.Y(and_result),
						.F(and_flags)
	 );
	 
    xor_4b u_or (.A(A),
					 .B(B),
					 .Y(xor_result),
					 .F(xor_flags)
	 );
	 
	 sub_4b u_sub (.A(A),
	               .B(B),
				  	   .Y(sub_result),
						.F(sub_flags)
	 );
	
	 mult_4b u_mult (.A(A),
						  .B(B),
						  .P(mul_result),
						  .F(mul_flags)
	 );
    
    mux4_1 mux_out (
        .in0(mul_result),   // sel = 00 → multiplicación
        .in1(sub_result),   // sel = 01 → resta
        .in2(and_result),   // sel = 10 → AND
        .in3(xor_result),   // sel = 11 → XOR
        .sel(sel),
        .out(result)
    );
	 
	 mux4_1 mux_flags (
	     .in0(mul_flags), // sel = 00 → multiplicación
		  .in1(sub_flags), // sel = 01 → resta
		  .in2(and_flags), // sel = 10 → AND
		  .in3(xor_flags), // sel = 11 → XOR
		  .sel(sel),
		  .out(flags)
	 );
endmodule
