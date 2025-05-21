module mux2to1_1bit(
    input  logic a,
    input  logic b,
    input  logic sel,
    output logic y
);
    assign y = (sel & a) | (~sel & b);
endmodule