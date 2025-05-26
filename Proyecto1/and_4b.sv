module and_4b (
    input  logic [3:0] A,
    input  logic [3:0] B,
    output logic [3:0] Y,
	 output logic [3:0] F
);
    and (Y[0], A[0], B[0]);
    and (Y[1], A[1], B[1]);
    and (Y[2], A[2], B[2]);
    and (Y[3], A[3], B[3]);
	 
	     assign F[3] = (Y == 4'b0000); // Zero flag
    assign F[2] = Y[3];               // Negative flag (bit más significativo)
    assign F[1] = 1'b0;               // Carry no 
    assign F[0] = 1'b0;               // Overflow no 
	 
endmodule
