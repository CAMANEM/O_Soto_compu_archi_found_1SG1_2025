/**
 * @module uartController
 * @brief Handles UART communication between an Arduino and the FPGA, including a handshake mechanism and command reception.
 *
 * This module performs a UART handshake with an Arduino and receives commands that control
 * gameplay actions (e.g., moving a selector). It sends and receives ASCII characters and 
 * updates an output value for display.
 *
 * UART RX expects:
 * - 'H' for initiating the handshake
 * - 'C' for column change
 * - 'S' for column selection
 *
 * UART TX responds:
 * - 'K' to acknowledge the handshake
 *
 * @param clk 50 MHz FPGA system clock
 * @param rst Active-high synchronous reset
 * @param rx_pin UART RX line connected to Arduino TX
 * @param tx_pin UART TX line connected to Arduino RX
 * @param display_data 8-bit output representing the last received command (useful for display)
 */

module uartController (
    input logic clk,                ///< 50 MHz FPGA clock
    input logic rst,                ///< Active-high reset signal
    input  logic rx_pin,            ///< UART RX line (connected to Arduino TX)
    output logic tx_pin,
    output logic [4:0] data_in
);

    // Internal UART communication signals
    logic [7:0] rx_data;            ///< Data received from UART
    logic rx_ready;                 ///< High when a new byte has been received
    logic [7:0] tx_data;            ///< Data to transmit over UART
    logic tx_ready;                 ///< High when ready to send
    logic tx_send;                  ///< Trigger signal to send a byte

    /**
     * UART receiver instance
     * Receives data from Arduino at 9600 baud
     */
    uart_rx #(
        .CLOCK_FREQ(50_000_000),
        .BAUD_RATE(9600)
    ) uart_rx_inst (
        .clk(clk),
        .reset(rst),
        .rx(rx_pin),
        .data(rx_data),
        .ready(rx_ready)
    );

    /**
     * UART transmitter instance
     * Sends data to Arduino at 9600 baud
     */
    uart_tx #(
        .CLOCK_FREQ(50_000_000),
        .BAUD_RATE(9600)
    ) uart_tx_inst (
        .clk(clk),
        .reset(rst),
        .tx(tx_pin),
        .data(tx_data),
        .send(tx_send),
        .ready(tx_ready)
    );

    /**
     * @enum state_t
     * @brief Finite State Machine (FSM) states for UART control logic
     */
    typedef enum logic [2:0] {
        IDLE,                   ///< Waits for 'H' (handshake start)
        HANDSHAKE_SEND,         ///< Sends 'K' to confirm handshake
        WAIT_HANDSHAKE_DONE,    ///< Waits until TX is no longer ready (transmit done)
        WAIT_COMMAND,           ///< Waits for a command after handshake
        PROCESS_COMMAND         ///< Handles incoming 'C' or 'S' commands
    } state_t;

    state_t state = IDLE;

    /**
     * Main FSM logic for UART handshake and command reception
     */
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx_send <= 0;
            tx_data <= 8'd14; // ASCII 'K'
            // display_data <= 8'h00;
        end else begin
            tx_send <= 0;

            case (state)
                IDLE: begin
                    // Wait for handshake byte 'H' (0x48)
                    if (rx_ready && rx_data == 8'd15) begin
                        // display_data <= rx_data;
                        state <= HANDSHAKE_SEND;
                    end
                end

                HANDSHAKE_SEND: begin
                    // Send back 'K' (0x4B) if TX is ready
                    if (tx_ready) begin
                        tx_send <= 1;
                        state <= WAIT_HANDSHAKE_DONE;
                    end
                end

                WAIT_HANDSHAKE_DONE: begin
                    // Wait for TX to finish before moving to command state
                    if (!tx_ready)
                        state <= WAIT_COMMAND;
                end

               WAIT_COMMAND: begin
                    if (rx_ready && tx_ready) begin
                        tx_data <= rx_data;  // Echo back received data
                        tx_send <= 1;
                    end
                end
            endcase
        end
    end

    // Assign the last received command to the output
    assign data_in = rx_data[4:0];

endmodule
