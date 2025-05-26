module hex7seg_tb;

    logic [3:0] value;
    logic [6:0] segments;

    hex7seg dut (
        .value(value),
        .segments(segments)
    );

    logic [6:0] expected_segments [0:15] = {
        7'b0000001, // 0
        7'b1001111, // 1
        7'b0010010, // 2
        7'b0000110, // 3
        7'b1001100, // 4
        7'b0100100, // 5
        7'b0100000, // 6
        7'b0001111, // 7
        7'b0000000, // 8
        7'b0000100, // 9
        7'b0001000, // A
        7'b1100000, // b
        7'b0110001, // C
        7'b1000010, // d
        7'b0110000, // E
        7'b0111000  // F
    };

    initial begin
        int errors = 0;
        $display("Starting testbench for hex7seg.sv...");
        for (int i = 0; i < 16; i++) begin
            value = i;
            #1;
            if (segments !== expected_segments[i]) begin
                $display("ERROR: value = %0h, expected = %b, got = %b", i, expected_segments[i], segments);
                errors++;
            end else begin
                $display("OK: value = %0h, segments = %b", i, segments);
            end
        end

        if (errors == 0) begin
            $display("All tests finished succesfully.");
        end else begin
            $display("Found %0d errors.", errors);
        end

        $finish;
    end

endmodule
