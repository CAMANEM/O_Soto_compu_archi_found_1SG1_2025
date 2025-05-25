module tb_pwm;

    logic clk;
    logic rst;
    logic [3:0] duty;
    logic pwm_out;

    // Instancia del PWM
    pwm uut (
        .clk(clk),
        .rst(rst),
        .duty(duty),
        .pwm_out(pwm_out)
    );

    // Generador de reloj (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;  // 10 ns periodo

    initial begin
        rst = 1;
        duty = 4'd0;

        // Espera 2 ciclos de reloj con reset
        #20;
        rst = 0;

        // Prueba duty = 0
        duty = 4'd0; #320;
		  
		  duty = 4'd1; #320;

        // Prueba duty = 4 (25%)
        duty = 4'd4; #320;

        // Prueba duty = 8 (50%)
        duty = 4'd8; #320;

        // Prueba duty = 12 (75%)
        duty = 4'd12; #320;

        // Prueba duty = 15 (100%)
        duty = 4'd15; #320;

       
    end

endmodule