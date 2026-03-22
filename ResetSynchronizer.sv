// ============================================================================
//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: ResetSynchronizer.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: reset synchronizer, asynchronous reset, CDC.
//  PURPOSE: Synchronizes the active-low async reset deassertion to the system clock.
// ============================================================================

module ResetSynchronizer 
(
    input  logic reset_n,       //  Active low asynchronous reset.
    input  logic clock,         //  System's clock.

    output logic reset_n_synch  //  The Synchronized Reset-deassertion.
);

//  The Synchronizer logic
always_ff @(posedge clock or negedge reset_n) begin
    if(!reset_n)
    begin
        reset_n_synch  <= 1'b0;
    end
    else 
    begin
        reset_n_synch  <= 1'b1;
    end
end

endmodule
