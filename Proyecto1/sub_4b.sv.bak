module sub_4b (
    input  logic [3:0] A,
    input  logic [3:0] B,
    output logic [3:0] Y,
    output logic Cout,
    output logic [3:0] F
);

    logic [3:0] B_inv;
    logic [3:0] S;
    logic c1, c2, c3, c4;

    // Complemento a uno de B (NOT bit a bit)
    not (B_inv[0], B[0]);
    not (B_inv[1], B[1]);
    not (B_inv[2], B[2]);
    not (B_inv[3], B[3]);

    // Suma A + (~B + 1)
    full_adder FA0 (A[0], B_inv[0], 1'b1,  S[0], c1);
    full_adder FA1 (A[1], B_inv[1], c1,    S[1], c2);
    full_adder FA2 (A[2], B_inv[2], c2,    S[2], c3);
    full_adder FA3 (A[3], B_inv[3], c3,    S[3], Cout);

    assign Y = S;

    // Flags:
    assign F[3] = (S == 4'b0000);         // Zero flag
    assign F[2] = S[3];                   // Negative flag (MSB del resultado)
    assign F[1] = Cout;                   // Carry flag (borrow en resta)
    assign F[0] = (A[3] != B[3]) && (S[3] != A[3]); // Overflow flag

endmodule
