module main_Top (
	input logic clk,
	input logic rst,
	input logic [3:0] aluNumA,
	input logic [1:0] aluSel,
	input  logic rx_pin,           // Pin conectado al TX del Arduino
	output  logic [3:0] aluResult,
	output logic tx_pin,
   output logic [3:0] aluNumB,
	output logic pwm_out, 	  	   // Motor
	output logic [3:0] aluFlags,
	output logic [6:0] resultDisplay
);

uartController uart_controller (
		.clk(clk),
		.rst(rst),
		.rx_pin(rx_pin),
		.tx_pin(tx_pin),
      .data_in(aluNumB)
	);
	
Alu_4b alu_4bits (
	.A(aluNumA),
	.B(aluNumB),
	.sel(aluSel),
	.result(aluResult),
	.flags(aluFlags)
);

hex7seg result_display(
	.value(aluResult),
	.segments(resultDisplay)
);

pwm pwm_inst  (
    .clk(clk),
    .rst(rst),
    .duty(aluResult),        
    .pwm_out(pwm_out)
);

endmodule