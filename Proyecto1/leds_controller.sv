module leds_controller (
	input logic [3:0] data_in,
	output logic [3:0] leds
);

	assign leds = data_in;

endmodule 