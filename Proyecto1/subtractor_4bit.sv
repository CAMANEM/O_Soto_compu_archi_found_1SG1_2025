module subtractor_4bit (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [3:0] diff,
    output logic       borrow
);
    logic b1, b2, b3;

    // Bit 0
    assign diff[0] = a[0] ^ b[0];
    assign b1 = ~a[0] & b[0];

    // Bit 1
    assign diff[1] = a[1] ^ b[1] ^ b1;
    assign b2 = (~a[1] & b[1]) | ((~a[1] | b[1]) & b1);

    // Bit 2
    assign diff[2] = a[2] ^ b[2] ^ b2;
    assign b3 = (~a[2] & b[2]) | ((~a[2] | b[2]) & b2);

    // Bit 3
    assign diff[3] = a[3] ^ b[3] ^ b3;
    assign borrow = (~a[3] & b[3]) | ((~a[3] | b[3]) & b3);
endmodule