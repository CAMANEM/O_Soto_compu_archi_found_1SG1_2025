module mux2to1_param #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             sel,
    output logic [WIDTH-1:0] y
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : mux_gen
            mux2to1_1bit mux_inst (
                .a(a[i]),
                .b(b[i]),
                .sel(sel),
                .y(y[i])
            );
        end
    endgenerate
endmodule