// ============================================================================
//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: CLA_Adder.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: CLA, adder, fast adder, parameterized.
//  PURPOSE: Carry look-ahead adder implementation for fast combinational addition needs.
// ============================================================================
`timescale 1ns/1ps
module CLA_Adder 
#(
    parameter integer SIZE = 4
)
(
    input  logic [(SIZE-1):0] in_1,
    input  logic [(SIZE-1):0] in_2,
    input  logic       carry_in,

    output logic [(SIZE-1):0] sum,
    output logic       carry_out
);
logic [(SIZE-1):0] p;
logic [(SIZE-1):0] g;
logic [SIZE:0] cmid;

always_comb 
begin
    p         = (in_1 ^ in_2);
    g         = (in_1 & in_2);
    cmid      = cla(p, g, carry_in);
    sum       = (p ^ cmid[(SIZE-1):0]);
    carry_out = cmid[SIZE];
end

function [SIZE:0] cla;
    input [(SIZE-1):0] p_arg;
    input [(SIZE-1):0] g_arg;
    input       c_arg;
    logic [(SIZE-1):0] pnc;
    integer i;

    cla[0] = c_arg;

    for ( i=0 ; i<SIZE ; i++ )
    begin
        pnc[i]   = p_arg[i] & cla[i];
        // Carry-out is generate OR propagate&carry
        cla[i+1] = g_arg[i] | pnc[i];
    end
endfunction

endmodule
