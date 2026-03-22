// ============================================================================
//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: DFF.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: DFF, flip-flop, asynchronous reset.
//  PURPOSE: Single-bit D flip-flop with active-low async reset used in support logic.
// ============================================================================

module DFF
//-----------------Ports-----------------\\
(
    input  logic reset_n,
    input  logic clock,
    input  logic d,

    output logic q
);

//-----------------Logic-----------------\\
always_ff @(posedge clock, negedge reset_n)
begin
    if(!reset_n)
    begin
        q <= 1'b0;
    end
    else
    begin
        q <= d;
    end
end

endmodule
