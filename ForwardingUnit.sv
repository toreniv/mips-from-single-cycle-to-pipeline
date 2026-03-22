// ============================================================================
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: ForwardingUnit.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: forwarding, hazard, pipeline, EX stage.
//  PURPOSE: Generates forwarding selects for EX stage operands to resolve data hazards.
// ============================================================================

module ForwardingUnit (
    input  logic        reg_write_M,
    input  logic        reg_write_W,

    input  logic [4:0]  write_reg_M,
    input  logic [4:0]  write_reg_W,

    input  logic [4:0]  rs_E,
    input  logic [4:0]  rt_E,

    output logic [1:0]  forward_a,
    output logic [1:0]  forward_b
);

always_comb begin
    // default: take from ID/EX
    forward_a = 2'b00;
    forward_b = 2'b00;

    // EX hazard on rs
    if (reg_write_M && (write_reg_M != 5'd0) && (write_reg_M == rs_E))
        forward_a = 2'b10;
    else if (reg_write_W && (write_reg_W != 5'd0) && (write_reg_W == rs_E))
        forward_a = 2'b01;

    // EX hazard on rt
    if (reg_write_M && (write_reg_M != 5'd0) && (write_reg_M == rt_E))
        forward_b = 2'b10;
    else if (reg_write_W && (write_reg_W != 5'd0) && (write_reg_W == rt_E))
        forward_b = 2'b01;
end

endmodule
