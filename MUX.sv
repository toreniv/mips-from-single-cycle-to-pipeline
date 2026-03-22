// ============================================================================
//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: MUX.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: multiplexer, combinational, parameterized.
//  PURPOSE: Parameterized 2:1 multiplexer used throughout the pipelined datapath.
// ============================================================================

module MUX 
//-----------------Parameters-----------------\\
#(
    parameter BUS = 32  
)
//-----------------Ports-----------------\\
(
    input  logic [(BUS-1):0] data_true,
    input  logic [(BUS-1):0] data_false,
    input  logic             sel,

    output logic [(BUS-1):0] data_out
);

//-----------------Output logic-----------------\\
assign data_out = sel? data_true : data_false;
    
endmodule
