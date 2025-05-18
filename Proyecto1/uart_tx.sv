/**
 * @module uart_tx
 * @brief UART transmitter module for serial communication at a specified baud rate.
 *
 * This module implements a UART transmitter using a finite state machine. It serially transmits
 * an 8-bit data byte over the `tx` line, using standard UART protocol (1 start bit, 8 data bits, 1 stop bit).
 *
 * @param CLOCK_FREQ Clock frequency of the FPGA system in Hz (default: 50 MHz)
 * @param BAUD_RATE  Desired baud rate for UART communication (default: 9600)
 *
 * @input clk        System clock signal
 * @input reset      Active-high synchronous reset signal
 * @input data       8-bit data to transmit
 * @input send       Signal to initiate transmission of `data`
 * @output tx        UART transmit output line
 * @output ready     High when transmitter is ready for the next byte
 */
module uart_tx #(
    parameter CLOCK_FREQ = 50_000_000, ///< Clock frequency in Hz
    parameter BAUD_RATE = 9600         ///< UART baud rate
)(
    input  logic clk,                  ///< System clock input
    input  logic reset,                ///< Active-high reset
    input  logic [7:0] data,           ///< 8-bit data to transmit
    input  logic send,                 ///< Trigger to start transmission
    output logic tx,                   ///< UART transmit output
    output logic ready                 ///< Ready signal (high when idle)
);

    /// Number of clock cycles per bit, derived from baud rate
    localparam integer CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    /**
     * @enum state_t
     * @brief FSM states for UART transmission
     */
    typedef enum logic [2:0] {
        IDLE,        ///< Waiting for send signal
        START_BIT,   ///< Sending start bit (0)
        DATA_BITS,   ///< Sending 8 data bits (LSB first)
        STOP_BIT,    ///< Sending stop bit (1)
        CLEANUP      ///< Returning to IDLE and setting ready
    } state_t;

    // FSM state register
    state_t state = IDLE;

    // Clock cycle counter for baud timing
    logic [12:0] clk_count = 0;

    // Bit index tracker for transmission
    logic [2:0] bit_index = 0;

    // Internal register holding data being transmitted
    logic [7:0] tx_data;

    /**
     * @brief FSM logic to transmit UART data serially.
     * 
     * Transmits 1 start bit, 8 data bits, and 1 stop bit using precise clock cycles
     * based on the configured baud rate. The `ready` signal indicates when the module
     * is ready to send new data.
     */
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx <= 1;             // Idle state for UART line is high
            clk_count <= 0;
            bit_index <= 0;
            ready <= 1;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1;
                    ready <= 1;
                    if (send) begin
                        tx_data <= data;
                        state <= START_BIT;
                        clk_count <= 0;
                        ready <= 0;
                    end
                end

                START_BIT: begin
                    tx <= 0; // Start bit (low)
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        state <= DATA_BITS;
                        bit_index <= 0;
                    end
                end

                DATA_BITS: begin
                    tx <= tx_data[bit_index]; // Send current bit
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else
                            state <= STOP_BIT;
                    end
                end

                STOP_BIT: begin
                    tx <= 1; // Stop bit (high)
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        state <= CLEANUP;
                    end
                end

                CLEANUP: begin
                    state <= IDLE;
                    ready <= 1;
                end
            endcase
        end
    end

endmodule
