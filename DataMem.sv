// ============================================================================
//  AUTHOR: Mohamed Maged Elkholy.
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: DataMem.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: data memory, MEM stage, load/store, simulation.
//  PURPOSE: Word-addressed data memory model for the MEM stage and testbench checks.
// ============================================================================

module DataMem
(
    input  logic         reset_n,
    input  logic         clock,
    input  logic         write_enable,
    input  logic [31:0]  write_data,
    input  logic [31:0]  address,
    output logic [31:0]  read_data,
    output logic [15:0]  test_value
);

    parameter int DEPTH = 4096;
    localparam int ADDR_W = (DEPTH <= 1) ? 1 : $clog2(DEPTH);

    logic [31:0] data_mem [0:DEPTH-1];
    logic [15:0] monitor_val;

    logic [31:0] full_word_index;
    logic [ADDR_W-1:0] word_addr;

    integer i;

    always_comb begin
        full_word_index = address >> 2;
        word_addr       = full_word_index[ADDR_W-1:0];
    end

    always_comb begin
        read_data = data_mem[word_addr];
    end

    // One legal always_ff writer for monitor_val and data_mem
    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            monitor_val <= 16'b0;

            // Optional: clear memory on reset (simulation-friendly, synth may hate this)
            for (i = 0; i < DEPTH; i = i + 1) begin
                data_mem[i] <= 32'b0;
            end
        end
        else begin
            if (write_enable) begin
                data_mem[word_addr] <= write_data;
                monitor_val         <= write_data[15:0];
                $display(">>> WRITE: Addr=0x%08h Data=0x%08h (%0d) Time=%0t",
                         address, write_data, write_data, $time);
            end
        end
    end

    assign test_value = monitor_val;

`ifndef SYNTHESIS
    always @(posedge clock) begin
        if (write_enable && (address[1:0] != 2'b00)) begin
            $warning("DataMem: UNALIGNED addr=0x%08h time=%0t", address, $time);
        end
        if (write_enable && ((address >> 2) >= DEPTH)) begin
            $warning("DataMem: out-of-range access addr=0x%08h DEPTH=%0d time=%0t",
                     address, DEPTH, $time);
        end
    end
`endif

endmodule
