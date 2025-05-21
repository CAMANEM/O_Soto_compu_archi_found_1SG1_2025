module mux2x1_16bit (
    input  logic [15:0] a,    // Entrada 0
    input  logic [15:0] b,    // Entrada 1
    input  logic        sel,  // Selector
    output logic [15:0] y     // Salida
);

    logic [15:0] not_sel;
    logic [15:0] a_and;
    logic [15:0] b_and;

    // NOT del selector para cada bit
    assign not_sel = {16{~sel}};

    // AND de cada entrada con el selector correspondiente
    assign a_and = a & not_sel;
    assign b_and = b & {16{sel}};

    // OR de los resultados
    assign y = a_and | b_and;
	 // `y = (cond & a) | (~cond & b);`


endmodule