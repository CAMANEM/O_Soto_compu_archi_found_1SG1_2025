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


    assign duty_eff = ({4{(~|(duty ^ 4'd1))}} & 4'd4) | ({4{~(~|(duty ^ 4'd1))}} & duty);

    assign {borrow, diff} = {1'b0, counter} - {1'b0, duty_eff};
    assign pwm_out = borrow;

 
    assign counter_next = counter + 4'd1;
    assign mux_out = ({4{rst}} & 4'd0) | ({4{~rst}} & counter_next);

    always_ff @(posedge clk) begin
        counter <= mux_out;
    end

endmodule