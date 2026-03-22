// ============================================================================
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: Top.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: top, integration, instruction memory, data memory.
//  PURPOSE: Top-level integration of the pipelined MIPS core with instruction/data memories.
// ============================================================================

module Top
#(
    parameter string PROGRAM_FILE = "prog1.txt"
)
(
    input  logic        reset_n,
    input  logic        clock,
    output logic [15:0] test_value
);

    logic        reset_n_synch_w;
    logic        mem_write_w;
    logic [31:0] pc_w;
    logic [31:0] instr_w;
    logic [31:0] alu_out_w;
    logic [31:0] write_data_w;
    logic [31:0] read_data_w;

    ResetSynchronizer rs(
        .reset_n       (reset_n),
        .clock         (clock),
        .reset_n_synch (reset_n_synch_w)
    );

    MIPS mips(
        .reset_n     (reset_n_synch_w),
        .clock       (clock),
        .instruction (instr_w),
        .read_data   (read_data_w),

        .pc          (pc_w),
        .alu_out     (alu_out_w),
        .write_data  (write_data_w),
        .mem_write   (mem_write_w)
    );

    DataMem dm(
        .reset_n      (reset_n_synch_w),
        .clock        (clock),
        .write_enable (mem_write_w),
        .address      (alu_out_w),
        .write_data   (write_data_w),

        .read_data    (read_data_w),
        .test_value   (test_value)
    );

    // If you want InstrMem clocked debug prints:
    // - define INSTRMEM_DEBUG_CLOCKED in compilation (vlog +define+INSTRMEM_DEBUG_CLOCKED)
    // Otherwise, it compiles with just pc/instr ports.

`ifdef INSTRMEM_DEBUG_CLOCKED
    InstrMem #(
        .myPROGRAM   (PROGRAM_FILE),
        .DEPTH_WORDS (128),
        .WRAP_ON_OOR (0),
        .DEBUG       (1),
        .PRINT_EVERY (50)
    ) im (
        .pc      (pc_w),
        .instr   (instr_w),
        .clock   (clock),
        .reset_n (reset_n_synch_w)
    );
`else
    InstrMem #(
        .myPROGRAM   (PROGRAM_FILE),
        .DEPTH_WORDS (128),
        .WRAP_ON_OOR (0),
        .DEBUG       (1),
        .PRINT_EVERY (50)
    ) im (
        .pc    (pc_w),
        .instr (instr_w)
    );
`endif

endmodule
// ============================================================================ 
