module uart_rx #(
    parameter CLOCK_FREQ = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  logic clk,
    input  logic reset,
    input  logic rx,
    output logic [7:0] data,
    output logic ready
);

    localparam integer CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;
    localparam integer MID_SAMPLE = CLKS_PER_BIT / 2;

    typedef enum logic [2:0] {
        IDLE, START_BIT, DATA_BITS, STOP_BIT, DONE
    } state_t;

    logic [$clog2(CLKS_PER_BIT)-1:0] clk_count, clk_count_next;
    logic [2:0] bit_index, bit_index_next;
    logic [7:0] rx_data, rx_data_next;
    logic [2:0] state, state_next;
    logic rx_sync, rx_sync_next;
    logic ready_next;
    logic [7:0] data_next;
    logic clk_countCMPclks_per_bit, clk_countCMPmid_sample, bit_indexCMP7;

    // Sincronizador

    // Comparadores
    assign clk_countCMPclks_per_bit = ~| (clk_count ^ (CLKS_PER_BIT - 1));
    assign clk_countCMPmid_sample   = ~|(clk_count ^ (MID_SAMPLE-1));
    assign bit_indexCMP7 = ~| (bit_index ^ 3'd7);


        // Defaults
        /*
        state_next = state;
        clk_count_next = clk_count;
        bit_index_next = bit_index;
        rx_data_next = rx_data;
        data_next = data;
        ready_next = 1'b0;
        ready_next = 1'b0;
        */




/*
        assign state_next = (stateCMPIDLE && ~rx_sync) ? START_BIT :
                     (stateCMPSTART_BIT && clk_countCMPmid_sample) ? DATA_BITS :
                     (stateCMPDATA_BITS && clk_countCMPclks_per_bit && bit_indexCMP7) ? STOP_BIT :
                     (stateCMPDATA_BITS && clk_countCMPclks_per_bit && ~bit_indexCMP7) ? DATA_BITS :
                     (stateCMPSTOP_BIT && clk_countCMPclks_per_bit) ? DONE :
                     (stateCMPDONE) ? IDLE : state;
*/      
 
        assign state_next[2] = ~state[2] & state[1] & state[0] & clk_countCMPclks_per_bit;

        assign state_next[1] = (~state[2]&~state[1]&state[0]&clk_countCMPmid_sample)|
                               (~state[2]&state[1]&~state[0]&clk_countCMPclks_per_bit&bit_indexCMP7)|
                               (~state[2]&state[1]&~state[0]&clk_countCMPclks_per_bit&~bit_indexCMP7)|
                               (~state[2]&state[1]&~state[0]&~clk_countCMPclks_per_bit)|
                               (~state[2]&state[1]&state[0]&~clk_countCMPclks_per_bit);

        assign state_next[0] = (~state[2]&~state[1]&~state[0]&~rx_sync)|
                               (~state[2]&~state[1]&state[0]&~clk_countCMPmid_sample)|
                               (~state[2]&state[1]&~state[0]&clk_countCMPclks_per_bit&bit_indexCMP7)|
                               (~state[2]&state[1]&state[0]&~clk_countCMPclks_per_bit);


/*
        // clk_count_next
        assign clk_count_next = (reset) ? 0 :
                         ((state == IDLE && ~rx_sync) ? 0 :
                         (state == START_BIT && clk_countCMPmid_sample) ? 0 :
                         (state == DATA_BITS && clk_countCMPclks_per_bit) ? 0 :
                         (state == STOP_BIT && clk_countCMPclks_per_bit) ? 0 :
                         (state == IDLE) ? clk_count :
                         clk_count + 1);
*/
        assign clk_count_next = ({$clog2(CLKS_PER_BIT){reset}} & '0) |
                        ({$clog2(CLKS_PER_BIT){~reset & (~|(state ^ IDLE)) & ~rx_sync}} & '0) |
                        ({$clog2(CLKS_PER_BIT){~reset & (~|(state ^ START_BIT)) & clk_countCMPmid_sample}} & '0) |
                        ({$clog2(CLKS_PER_BIT){~reset & (~|(state ^ DATA_BITS)) & clk_countCMPclks_per_bit}} & '0) |
                        ({$clog2(CLKS_PER_BIT){~reset & (~|(state ^ STOP_BIT)) & clk_countCMPclks_per_bit}} & '0) |
                        ({$clog2(CLKS_PER_BIT){~reset & (~|(state ^ IDLE))  & ~(~rx_sync)}} & clk_count) |
                        ({$clog2(CLKS_PER_BIT){~reset & ~( (~|(state ^ IDLE)) | 
                                                           ((~|(state ^ START_BIT)) & clk_countCMPmid_sample) | 
                                                           ((~|(state ^ DATA_BITS)) & clk_countCMPclks_per_bit) | 
                                                           ((~|(state ^ STOP_BIT)) & clk_countCMPclks_per_bit) | 
                                                           ((~|(state ^ IDLE)) & ~rx_sync) )}} & (clk_count + 1));

/*
        // bit_index_next
        assign bit_index_next = (reset) ? 0 :
                         (state == START_BIT && clk_countCMPmid_sample) ? 0 :
                         (state == DATA_BITS && clk_countCMPclks_per_bit && bit_index != 3'd7) ? bit_index + 1 :
                         (state == DATA_BITS && clk_countCMPclks_per_bit && bit_index == 3'd7) ? bit_index :
                         (state == STOP_BIT && clk_countCMPclks_per_bit) ? 0 :
                         bit_index;
*/

        assign bit_index_next = ({3{reset}} & 3'b000) |
                                ({3{~reset & (~|(state ^ START_BIT)) & clk_countCMPmid_sample}} & 3'b000) |
                                ({3{~reset & (~|(state ^ DATA_BITS)) & clk_countCMPclks_per_bit & (~(~|(bit_index ^ 3'd7)))}} & (bit_index + 1)) |
                                ({3{~reset & (~|(state ^ DATA_BITS)) & clk_countCMPclks_per_bit & (~|(bit_index ^ 3'd7))}} & bit_index) |
                                ({3{~reset & (~|(state ^ STOP_BIT)) & clk_countCMPclks_per_bit}} & 3'b000) |
                                ({3{~reset & ~(((~|(state ^ START_BIT)) & clk_countCMPmid_sample) |
                                    ((~|(state ^ DATA_BITS)) & clk_countCMPclks_per_bit) |
                                    ((~|(state ^ STOP_BIT)) & clk_countCMPclks_per_bit))}} & bit_index);

        // rx_data_next
        //assign rx_data_next = (reset) ? 0 :
        //               (state == DATA_BITS && clk_countCMPclks_per_bit) ? {rx_sync, rx_data[7:1]} : rx_data;
        // mux 3to1 
        assign rx_data_next = ({8{reset}} & 8'b0) | 
                              ({8{~reset & ((~|(state ^ DATA_BITS)) && clk_countCMPclks_per_bit)}} & {rx_sync, rx_data[7:1]}) | 
                              ({8{~reset & ~((~|(state ^ DATA_BITS)) && clk_countCMPclks_per_bit)}} & rx_data);
        // mux 3to1
        assign data_next = ((~|(state ^ DONE)) & data) | (~(~|(state ^ DONE)) & rx_data);

        //(state == DONE);
        assign ready_next = ~|(state ^ DONE);


    always_ff @(posedge clk) begin
        rx_sync <= rx;
        state <= (~reset & state_next) | (reset & IDLE);
        clk_count <= (~reset & clk_count_next) | (reset & 0);
        bit_index <= (~reset & bit_index_next) | (reset & 3'b000);
        rx_data <= (~reset & rx_data_next) | (reset & 8'b0);
        data <= (~reset & data_next) | (reset & 8'b0);
        ready <= (~reset & ready_next) | (reset & 1'b0);
    end

endmodule
