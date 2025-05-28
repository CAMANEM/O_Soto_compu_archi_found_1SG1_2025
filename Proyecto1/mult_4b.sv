module mult_4b (
    input  logic [3:0] A,       // Multiplicando
    input  logic [3:0] B,       // Multiplicador
    output logic [7:0] P,       // Producto (8 bits)
    output logic [3:0] F        // Flags: [Z, N, C, V]
);

    logic [3:0] pp0, pp1, pp2, pp3;  // Productos parciales
    logic [7:0] temp1, temp2, temp3;
    logic [7:0] shifted_pp1, shifted_pp2, shifted_pp3;

    // Flags
    logic Z, N, C, V;  // Zero, Negative, Carry, Overflow

    // Fila 0: sin desplazamiento
    and (pp0[0], A[0], B[0]);
    and (pp0[1], A[1], B[0]);
    and (pp0[2], A[2], B[0]);
    and (pp0[3], A[3], B[0]);

    assign temp1[3:0] = pp0;
    assign temp1[7:4] = 4'b0000;

    // Fila 1: desplazamiento 1 (<<1)
    and (pp1[0], A[0], B[1]);
    and (pp1[1], A[1], B[1]);
    and (pp1[2], A[2], B[1]);
    and (pp1[3], A[3], B[1]);

    assign shifted_pp1 = {3'b000, pp1, 1'b0};

    ripple_adder add1 (
        .A(temp1),
        .B(shifted_pp1),
        .S(temp2)
    );

    // Fila 2: desplazamiento 2 (<<2)
    and (pp2[0], A[0], B[2]);
    and (pp2[1], A[1], B[2]);
    and (pp2[2], A[2], B[2]);
    and (pp2[3], A[3], B[2]);

    assign shifted_pp2 = {2'b00, pp2, 2'b00};

    ripple_adder add2 (
        .A(temp2),
        .B(shifted_pp2),
        .S(temp3)
    );

    // Fila 3: desplazamiento 3 (<<3)
    and (pp3[0], A[0], B[3]);
    and (pp3[1], A[1], B[3]);
    and (pp3[2], A[2], B[3]);
    and (pp3[3], A[3], B[3]);

    assign shifted_pp3 = {1'b0, pp3, 3'b000};

    ripple_adder add3 (
        .A(temp3),
        .B(shifted_pp3),
        .S(P)
    );

    // Cálculo de las flags

        
        assign F[3] = ~P[3] & ~P[2] & ~P[1] & ~P[0]; // Flag Zero (Z)
		  
        assign F[2] = P[3];  // Flag Negative (N)
		  
        assign F[1] = P[4] | P[5] | P[6] | P[7];  // Flag Carry (C)
		  
        assign F[0] = (A[3] ^ B[3]) & (P[7] ^ (A[3] ^ B[3])); // Flag Overflow (V)

   

endmodule
