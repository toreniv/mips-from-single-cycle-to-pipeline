// ============================================================================
//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: Shifter.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: shifter, logical shift, combinational.
//  PURPOSE: Parameterized left/right shifter used in address and immediate operations.
// ============================================================================

module Shifter
//-----------------Parameters-----------------\\ 
#(
    parameter SHAMT = 2,
              DIRC  = 1,
              BUS   = 32
)
//-----------------Ports-----------------\\
(
    input  logic [(BUS-1):0] data_in,

    output logic [(BUS-1):0] data_out
);

//-----------------Output logic-----------------\\
assign data_out = DIRC? (data_in << SHAMT) : (data_in >> SHAMT);
    
endmodule
