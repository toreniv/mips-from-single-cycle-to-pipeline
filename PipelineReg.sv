// ============================================================================
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: PipelineReg.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: pipeline register, stall, flush, enable.
//  PURPOSE: Generic pipeline register with stall/enable and flush/clear support.
// ============================================================================
module PipelineReg #(parameter WIDTH = 32) (
    input  logic             clock,
    input  logic             reset_n,
    input  logic             clear, // עבור Flush (ניקוי הצינור בקפיצות)
    input  logic             en,    // עבור Stall (עצירת הצינור)
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) 
            q <= '0;
        else if (clear)
            q <= '0;
        else if (en)
            q <= d;
    end
endmodule
