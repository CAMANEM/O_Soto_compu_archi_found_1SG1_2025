module pwm (
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] duty,
    output logic       pwm_out
);
    logic [3:0] counter;
    logic [3:0] counter_next;
    logic [3:0] diff;
    logic       borrow;
    logic [3:0] mux_out;
    logic [3:0] duty_eff;
    logic       duty_is_1;

    // Comparador estructural para duty == 1
    assign duty_is_1 = ~duty[3] & ~duty[2] & ~duty[1] & duty[0];

    // Selector estructural
    assign duty_eff = ({4{duty_is_1}} & 4'd4) | ({4{~duty_is_1}} & duty);

    // Restador estructural: diff = counter - duty_eff
    subtractor_4bit u_sub (
        .a(counter),
        .b(duty_eff),
        .diff(diff),
        .borrow(borrow)
    );

    assign pwm_out = borrow;

    // Sumador estructural: counter_next = counter + 1
    adder_4bit u_add (
        .a(counter),
        .b(4'b0001),
        .sum(counter_next)
    );

    // Mux estructural para reset
    assign mux_out = ({4{rst}} & 4'b0000) | ({4{~rst}} & counter_next);

    // Flip-flop estructural
    always_ff @(posedge clk) begin
        counter <= mux_out;
    end
endmodule