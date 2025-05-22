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
    logic [7:0] tx_data_next;       ///< Next state for tx_data
    logic tx_ready;                 ///< High when ready to send
    logic tx_send;                  ///< Trigger signal to send a byte
    logic tx_send_next;           ///< Next state for tx_send
    logic [1:0] state_next;           ///< Next state for the FSM
    logic [1:0] state;               ///< Current state of the FSM

    // compare
    logic rx_dataCMP15;
    logic reset;
    logic [7:0] isReady_rx_tx;

        /**
     * @enum state_t
     * @brief Finite State Machine (FSM) states for UART control logic
     */
    typedef enum logic [1:0] {
        IDLE,                   ///< Waits for 'H' (handshake start)
        HANDSHAKE_SEND,         ///< Sends 'K' to confirm handshake
        WAIT_HANDSHAKE_DONE,    ///< Waits until TX is no longer ready (transmit done)
        WAIT_COMMAND           ///< Waits for a command after handshake
    } state_t;

    //state_t state = IDLE;
    //state_t  state_next;

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

    assign rx_dataCMP15 = ~| (rx_data ^ 8'd15);

/*
    assign state_next = (state == IDLE && rx_ready && rx_data == 8'd15)                ? HANDSHAKE_SEND :
                     (state == HANDSHAKE_SEND && tx_ready)                         ? WAIT_HANDSHAKE_DONE :
                     (state == WAIT_HANDSHAKE_DONE && !tx_ready)                   ? WAIT_COMMAND :
                     state;
*/
    assign state_next[1] = (~state[1]&state[0]&tx_ready)|(state[1]&~state[0]&~tx_ready)|(state[1]&~state[0]&tx_ready)|(state[1]&state[0]);
    assign state_next[0] = (~state[1]&~state[0]&tx_ready&rx_ready&rx_dataCMP15)|(~state[1]&state[0]&~tx_ready)|(state[1]&~state[0]&~tx_ready)|(state[1]&state[0]);

    assign isReady_rx_tx = ({8{(~|(state ^ WAIT_COMMAND)) & rx_ready & tx_ready}});

    assign tx_data_next = (isReady_rx_tx & rx_data) | (~isReady_rx_tx & tx_data);
    
    //assign data_next = ((~|(state ^ DONE)) & data) | (~(~|(state ^ DONE)) & rx_data);

    assign tx_send_next = (~state[1] & state[0] & tx_ready) | 
                          (state[1] & state[0] & rx_ready & tx_ready);
    
    always_ff @(posedge clk) begin
        reset <= rst;
    end

    /**
     * Main FSM logic for UART handshake and command reception
     */
    always_ff @(posedge clk or posedge rst) begin
        //state <= (~rst & state_next) | (rst & IDLE);
        if (rst) begin
            state   <= IDLE;
            tx_send <= 0;
            tx_data <= 8'd14; // ASCII 'K'
            // display_data <= 8'h00;
        end else begin
            // Default assignments
            tx_data <= tx_data_next;
            tx_send <= tx_send_next;
            state <= state_next;
        end
    end

    // Assign the last received command to the output
    assign data_in = rx_data[4:0];

endmodule
