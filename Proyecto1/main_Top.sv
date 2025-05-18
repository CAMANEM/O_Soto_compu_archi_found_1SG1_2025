module main_Top (
	input logic clk,
	input logic rst,
	input  logic rx_pin,           // Pin conectado al TX del Arduino
	output logic tx_pin,
    output logic [3:0] leds 
);

uartController uart_controller (
		.clk(clk),
		.rst(rst),
		.rx_pin(rx_pin),
		.tx_pin(tx_pin),
        .data_in(leds)
	);

endmodule