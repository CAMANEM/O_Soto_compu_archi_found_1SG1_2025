module mux4_1 (
    input  logic [3:0] in0,
    input  logic [3:0] in1,
    input  logic [3:0] in2,
    input  logic [3:0] in3,
    input  logic [1:0] sel,
    output logic [3:0] out
);
    logic [3:0] s0, s1, s2, s3;
    logic nsel0, nsel1;

    not (nsel0, sel[0]);
    not (nsel1, sel[1]);

    // out[0]
    and (s0[0], in0[0], nsel1, nsel0);
    and (s1[0], in1[0], nsel1, sel[0]);
    and (s2[0], in2[0], sel[1],  nsel0);
    and (s3[0], in3[0], sel[1],  sel[0]);
    or  (out[0], s0[0], s1[0], s2[0], s3[0]);

    // out[1]
    and (s0[1], in0[1], nsel1, nsel0);
    and (s1[1], in1[1], nsel1, sel[0]);
    and (s2[1], in2[1], sel[1],  nsel0);
    and (s3[1], in3[1], sel[1],  sel[0]);
    or  (out[1], s0[1], s1[1], s2[1], s3[1]);

    // out[2]
    and (s0[2], in0[2], nsel1, nsel0);
    and (s1[2], in1[2], nsel1, sel[0]);
    and (s2[2], in2[2], sel[1],  nsel0);
    and (s3[2], in3[2], sel[1],  sel[0]);
    or  (out[2], s0[2], s1[2], s2[2], s3[2]);

    // out[3]
    and (s0[3], in0[3], nsel1, nsel0);
    and (s1[3], in1[3], nsel1, sel[0]);
    and (s2[3], in2[3], sel[1],  nsel0);
    and (s3[3], in3[3], sel[1],  sel[0]);
    or  (out[3], s0[3], s1[3], s2[3], s3[3]);
endmodule