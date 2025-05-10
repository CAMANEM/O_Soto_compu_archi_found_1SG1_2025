module encoder (input logic I0, I1, I2, I3, output logic O1, O0);

	assign O1 = (I1 & ~I3);
	assign O0 = (I0 & ~I1) | (I2 & ~I3);
	
endmodule