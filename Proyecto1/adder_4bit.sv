module adder_4bit (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [3:0] sum
);
    logic c1, c2, c3;

    assign sum[0] = a[0] ^ b[0];
    assign c1 = a[0] & b[0];

    assign sum[1] = a[1] ^ b[1] ^ c1;
    assign c2 = (a[1] & b[1]) | (a[1] & c1) | (b[1] & c1);

    assign sum[2] = a[2] ^ b[2] ^ c2;
    assign c3 = (a[2] & b[2]) | (a[2] & c2) | (b[2] & c2);

    assign sum[3] = a[3] ^ b[3] ^ c3;
endmodule