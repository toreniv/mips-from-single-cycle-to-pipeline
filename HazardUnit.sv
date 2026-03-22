// ============================================================================
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: HazardUnit.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: hazard detection, stall, flush, load-use.
//  PURPOSE: Detects load-use hazards and generates stall/flush controls for the pipeline.
// ============================================================================

module HazardUnit (
    // D stage info (instruction in Decode)
    input  logic [4:0] rs_D,
    input  logic [4:0] rt_D,

    // E stage info (instruction in Execute)
    input  logic        mem_to_reg_E,   // EX is a load
    input  logic [4:0]  rt_E,           // load destination is rt in MIPS for lw

    // outputs
    output logic        stall_F,
    output logic        stall_D,
    output logic        flush_E
);

    logic load_use_stall;

    always_comb begin
        stall_F = 1'b0;
        stall_D = 1'b0;
        flush_E = 1'b0;

        // Classic load-use:
        // if EX is LW, and D uses the loaded register, stall one cycle and bubble EX.
        load_use_stall =
            mem_to_reg_E &&
            (rt_E != 5'd0) &&
            ((rt_E == rs_D) || (rt_E == rt_D));

        if (load_use_stall) begin
            stall_F = 1'b1;
            stall_D = 1'b1;
            flush_E = 1'b1;
        end
    end

endmodule
