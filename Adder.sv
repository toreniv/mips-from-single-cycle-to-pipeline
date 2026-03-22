// ============================================================================
//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: Adder.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: Adder, parameterized, combinational, datapath.
//  PURPOSE: Combinational parameterized adder used for PC increment and address calculations.
// ============================================================================

module Adder 
//-----------------Parameters-----------------\\
#(
    parameter  BUS  = 32
)
//-----------------Ports-----------------\\
(
    input  logic             reset_n,
    input  logic [(BUS-1):0] data_a,
    input  logic [(BUS-1):0] data_b,

    output logic [(BUS-1):0] data_res
);

//-----------------Logic-----------------\\
assign data_res = reset_n? (data_a + data_b) : {BUS{1'b0}};

endmodule
