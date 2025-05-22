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

    logic [2:0] state;               ///< Current state of the FSM
    logic [2:0] state_next;           ///< Clock cycle counter

    // comparators
    logic clk_countCMPCLKS_PER_BIT_M_1;
    logic clk_countCMPMID_SAMPLE;
    logic bit_indexCMP7;
    assign clk_countCMPCLKS_PER_BIT_M_1 = (clk_count < CLKS_PER_BIT - 1);
    assign bit_indexCMP7 = (bit_index < 7);


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
            state     <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            ready     <= 1;
            tx_data   <= 0;
        end else begin
            state     <= state_next;

            clk_count <= (state == IDLE)      ? 0 :
                         (state == START_BIT) ? ((clk_count < CLKS_PER_BIT - 1) ? clk_count + 1 : 0) :
                         (state == DATA_BITS) ? ((clk_count < CLKS_PER_BIT - 1) ? clk_count + 1 : 0) :
                         (state == STOP_BIT)  ? ((clk_count < CLKS_PER_BIT - 1) ? clk_count + 1 : 0) :
                         /* CLEANUP */           0;

            bit_index <= (state == IDLE)      ? 0 :
                         (state == START_BIT) ? 0 :
                         (state == DATA_BITS) ? ((clk_count < CLKS_PER_BIT - 1) ? bit_index :
                                                (bit_index < 7) ? bit_index + 1 : bit_index) :
                         (state == STOP_BIT)  ? bit_index :
                         /* CLEANUP */           0;

            ready     <= (state == IDLE)      ? (send ? 0 : 1) :
                         (state == CLEANUP)   ? 1 : 0;

            tx_data   <= (state == IDLE && send) ? data : tx_data;
        end
    end
/*
    assign state_next = (state == IDLE)      ? (send ? START_BIT : IDLE) :
                         (state == START_BIT) ? (clk_countCMPCLKS_PER_BIT_M_1 ? START_BIT : DATA_BITS) :
                         (state == DATA_BITS) ? (clk_countCMPCLKS_PER_BIT_M_1 ? DATA_BITS :
                                                bit_indexCMP7 ? DATA_BITS : STOP_BIT) :
                         (state == STOP_BIT)  ? (clk_countCMPCLKS_PER_BIT_M_1 ? STOP_BIT : CLEANUP) :
                                 IDLE;

                                 
*/
    assign state_next[2] = (~state[2]&state[1]&state[0]&~clk_countCMPCLKS_PER_BIT_M_1);

    assign state_next[1] =  (~state[2]&~state[1]&state[0]&~clk_countCMPCLKS_PER_BIT_M_1)|(~state[2]&state[1]&~state[0]&~clk_countCMPCLKS_PER_BIT_M_1&~bit_indexCMP7)|(~state[2]&state[1]&~state[0]&clk_countCMPCLKS_PER_BIT_M_1)|(~state[2]&state[1]&~state[0]&bit_indexCMP7)|(~state[2]&state[1]&state[0]&clk_countCMPCLKS_PER_BIT_M_1);

    assign state_next[0] = (~state[2]&~state[1]&~state[0]&send)|(~state[2]&~state[1]&state[0]&clk_countCMPCLKS_PER_BIT_M_1)|(~state[2]&state[1]&~state[0]&~clk_countCMPCLKS_PER_BIT_M_1&~bit_indexCMP7)|(~state[2]&state[1]&state[0]&clk_countCMPCLKS_PER_BIT_M_1);



    assign tx = (state == START_BIT)  ? 1'b0 :
         (state == DATA_BITS)  ? tx_data[bit_index] :
                    1'b1;


endmodule
