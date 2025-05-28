module mux3to1_1bit(
    input  logic a,      // Entrada 0
    input  logic b,      // Entrada 1
    input  logic c,      // Entrada 2
    input  logic [1:0] sel, // Selector de 2 bits
    output logic y
);
    assign y = (~sel[1] & ~sel[0] & a) |    // sel = 00 → a
               (~sel[1] &  sel[0] & b) |    // sel = 01 → b
               ( sel[1]           & c);     // sel = 1x → c
endmodule