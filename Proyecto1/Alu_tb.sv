module Alu_tb;

    // Entradas
    logic [3:0] A;
    logic [3:0] B;
    logic [1:0] sel;

    // Salidas
    logic [3:0] result;
    logic [3:0] flags; // 3=Z, 2=N, 1=C, 0=OF

    // Flags individuales para visualización clara
    logic Z, N, C, OF;

    // Instancia de la ALU
    Alu_4b uut (
        .A(A),
        .B(B),
        .sel(sel),
        .result(result),
        .flags(flags)
    );

    // Asignación continua para extraer cada flag
    assign Z  = flags[3];
    assign N  = flags[2];
    assign C  = flags[1];
    assign OF = flags[0];

    initial begin
        // Encabezado
        $display("Time |   A   |   B   | sel | result | Z | N | C | OF");

        // Monitor
        $monitor("%4t | %b | %b |  %b  |  %b   | %b | %b | %b | %b",
                  $time, A, B, sel, result,
                  Z, N, C, OF);

        // Estímulos
        A = 4'b0011; B = 4'b0101;

        sel = 2'b00; #10; // Multiplicación
        sel = 2'b01; #10; // Resta
        sel = 2'b10; #10; // AND
        sel = 2'b11; #10; // XOR

        // Otro conjunto de pruebas
        A = 4'b1111; B = 4'b1010;

        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b10; #10;
        sel = 2'b11; #10;

        $finish;
    end

endmodule



/*
    // Entradas
    logic [3:0] A;
    logic [3:0] B;
    logic [1:0] sel;

    // Salidas
    logic [3:0] result;
    logic [3:0] flags; // 3=Z 2=N 1=C 0=o_f

    // Instancia de la ALU
    Alu_4b uut (
        .A(A),
        .B(B),
        .sel(sel),
        .result(result),
        .flags(flags)
    );

    initial begin
        // Mostrar encabezado
        $display("Time |   A   |   B   | sel | result | Z N C o_f");

        // Mostrar cambios
        $monitor("%4t | %b | %b |  %b  |  %b   | %b %b %b %b",
                  $time, A, B, sel, result,
                  flags[3], flags[2], flags[1], flags[0]);

        // Estímulos
        A = 4'b0011; B = 4'b0101;

        sel = 2'b00; #10; // Multiplicación
        sel = 2'b01; #10; // Resta
        sel = 2'b10; #10; // AND
        sel = 2'b11; #10; // XOR

        // Otro conjunto de pruebas
        A = 4'b1111; B = 4'b1010;

        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b10; #10;
        sel = 2'b11; #10;

        $finish;
    end

endmodule



  // Entradas
    logic [3:0] A;
    logic [3:0] B;
    logic [1:0] sel;

    // Salida
    logic [3:0] result;

    // Instancia de la ALU
    Alu_4b uut (
        .A(A),
        .B(B),
        .sel(sel),
        .result(result)
    );

    initial begin
        // Mostrar cambios
        $monitor("Time = %0t | A = %b | B = %b | sel = %b | result = %b", 
                  $time, A, B, sel, result);

        // Estímulos
        A = 4'b0011; B = 4'b0101;

        // Multiplicación: 3 * 5 = 15
        sel = 2'b00; #10;

        // Resta: 3 - 5 = (2's complement) = 1110 (–2)
        sel = 2'b01; #10;

        // AND: 0011 & 0101 = 0001
        sel = 2'b10; #10;

        // XOR: 0011 ^ 0101 = 0110
        sel = 2'b11; #10;

        // Otro conjunto de pruebas
        A = 4'b1111; B = 4'b1010;

        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b10; #10;
        sel = 2'b11; #10;

        $finish;
    end

endmodule





 logic [3:0] A;
    logic [3:0] B;
    logic [1:0] sel;
    logic [3:0] result;
    logic [3:0] flags;

    // Instancia del módulo ALU
    Alu_4b dut (
        .A(A),
        .B(B),
        .sel(sel),
        .result(result),
        .flags(flags)
    );

    // Procedimiento de prueba
    initial begin
        $display("Tiempo\tSel\tA\tB\tResult\tFlags");
        $monitor("%0t\t%b\t%h\t%h\t%h\t%b", $time, sel, A, B, result, flags);

        // Operación 00: Multiplicación
        sel = 2'b00;
        A = 4'd3; B = 4'd2; #10;
        A = 4'd4; B = 4'd4; #10;
        A = 4'd0; B = 4'd9; #10;

        // Operación 01: Resta
        sel = 2'b01;
        A = 4'd7; B = 4'd2; #10;
        A = 4'd2; B = 4'd7; #10;
        A = 4'd8; B = 4'd8; #10;

        // Operación 10: AND
        sel = 2'b10;
        A = 4'b1010; B = 4'b1100; #10;
        A = 4'b0000; B = 4'b1111; #10;

        // Operación 11: XOR
        sel = 2'b11;
        A = 4'b1010; B = 4'b0101; #10;
        A = 4'b1111; B = 4'b1111; #10;

        $finish;
    end

endmodule

  

    logic [3:0] A, B;
    logic [3:0] Y;

    // Instancia del módulo and4
    mult_4b uut (
        .A(A),
        .B(B),
        .P(Y)
    );

    initial begin
        $display("Tiempo |   A    B   |  Y (A AND B)");
        $display("---------------------------------");

        A = 4'b0000; B = 4'b0000; #10;
        $display("%4t   | %b  %b | %b", $time, A, B, Y);

        A = 4'b0011; B = 4'b0001; #10;
        $display("%4t   | %b  %b | %b", $time, A, B, Y);

        A = 4'b1110; B = 4'b1100; #10;
        $display("%4t   | %b  %b | %b", $time, A, B, Y);

        A = 4'b1111; B = 4'b1111; #10;
        $display("%4t   | %b  %b | %b", $time, A, B, Y);

        A = 4'b1010; B = 4'b0101; #10;
        $display("%4t   | %b  %b | %b", $time, A, B, Y);

        $finish;
    end

endmodule
*/