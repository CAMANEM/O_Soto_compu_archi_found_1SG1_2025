module full_adder (
    input  logic A,
    input  logic B,
    input  logic Cin,
    output logic Sum,
    output logic Cout
);

    logic w1, w2, w3;

    xor (w1, A, B);
    xor (Sum, w1, Cin);

    and (w2, A, B);
    and (w3, w1, Cin);
    or  (Cout, w2, w3);

endmodule
