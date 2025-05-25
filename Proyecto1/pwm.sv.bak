module pwm (
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] duty,    // velocudades
    output logic       pwm_out
);

    logic [3:0] counter;
    logic [3:0] counter_next;
    logic [3:0] diff;
    logic       borrow;
    logic [3:0] mux_out;

    // Comparador counter < duty ... borrow = 1
    assign {borrow, diff} = {1'b0, counter} - {1'b0, duty};
    assign pwm_out = borrow;

    // Contador secuencial
    assign counter_next = counter + 4'd1;
    assign mux_out = ({4{rst}} & 4'd0) | ({4{~rst}} & counter_next);

    always_ff @(posedge clk) begin
        counter <= mux_out;
    end

endmodule
