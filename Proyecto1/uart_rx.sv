/**
 * @module uart_rx
 * @brief UART receiver module for asynchronous serial communication.
 *
 * This module implements a UART receiver that listens to the `rx` line
 * and receives an 8-bit data frame using standard UART format (1 start bit, 
 * 8 data bits, 1 stop bit).
 *
 * @param CLOCK_FREQ Clock frequency of the system in Hz (default: 50 MHz)
 * @param BAUD_RATE  UART communication baud rate (default: 9600)
 *
 * @input clk     System clock input
 * @input reset   Active-high synchronous reset
 * @input rx      UART receive line
 * @output data   8-bit data received
 * @output ready  High for one clock cycle when a full byte is received
 */
module uart_rx #(
    parameter CLOCK_FREQ = 50_000_000, ///< Clock frequency in Hz
    parameter BAUD_RATE = 9600         ///< UART baud rate
)(
    input  logic clk,                  ///< System clock
    input  logic reset,                ///< Synchronous reset
    input  logic rx,                   ///< UART receive input
    output logic [7:0] data,           ///< Output received 8-bit data
    output logic ready                 ///< High when data is valid
);

    /// Clock cycles per UART bit
    localparam integer CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    /// Midpoint of a bit for start bit sampling
    localparam integer MID_SAMPLE = CLKS_PER_BIT / 2;

    /**
     * @enum state_t
     * @brief State machine for UART reception
     */
    typedef enum logic [2:0] {
        IDLE,        ///< Waiting for start bit
        START_BIT,   ///< Sampling the start bit
        DATA_BITS,   ///< Receiving the 8 data bits
        STOP_BIT,    ///< Receiving the stop bit
        DONE         ///< Reception complete
    } state_t;

    state_t state = IDLE; ///< FSM current state
    logic [$clog2(CLKS_PER_BIT)-1:0] clk_count = 0; ///< Baud timing counter
    logic [2:0] bit_index = 0;                      ///< Index of current bit being received
    logic [7:0] rx_data = 0;                        ///< Register to store incoming data
    logic rx_sync = 1;                              ///< Synchronized rx signal

    /**
     * @brief Simple 1-stage synchronizer for asynchronous `rx` input
     */
    always_ff @(posedge clk) begin
        rx_sync <= rx;
    end

    /**
     * @brief UART receiver FSM for decoding incoming serial data.
     *
     * Waits for a falling edge on `rx_sync`, samples the bits at the correct intervals,
     * and outputs the complete byte when reception is complete.
     */
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            data <= 0;
            ready <= 0;
        end else begin
            ready <= 0;

            case (state)
                IDLE: begin
                    if (rx_sync == 0) begin // Detected start bit
                        state <= START_BIT;
                        clk_count <= 0;
                    end
                end

                START_BIT: begin
                    if (clk_count == MID_SAMPLE) begin
                        clk_count <= 0;
                        state <= DATA_BITS;
                        bit_index <= 0;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DATA_BITS: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        rx_data[bit_index] <= rx_sync;

                        if (bit_index == 7) begin
                            state <= STOP_BIT;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                STOP_BIT: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        state <= DONE;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DONE: begin
                    data <= rx_data;
                    ready <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
