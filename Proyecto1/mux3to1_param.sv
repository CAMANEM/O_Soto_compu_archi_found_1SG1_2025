module mux3to1_param #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [WIDTH-1:0] c,
    input  logic [1:0]       sel,
    output logic [WIDTH-1:0] y
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : mux_gen
            mux3to1_1bit mux_inst (
                .a(a[i]),
                .b(b[i]),
                .c(c[i]),
                .sel(sel),
                .y(y[i])
            );
        end
    endgenerate
endmodule