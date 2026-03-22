// ============================================================================
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: MIPS.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: MIPS, pipeline, core, control, datapath.
//  PURPOSE: Top-level MIPS core that connects control and datapath for the 5-stage pipeline.
// ============================================================================

module MIPS (
    input  wire        reset_n,
    input  wire        clock,
    input  wire [31:0] instruction,
    input  wire [31:0] read_data,

    output wire [31:0] pc,
    output wire [31:0] alu_out,
    output wire [31:0] write_data,
    output wire        mem_write
);

    // --- Control Unit wires ---
    logic        reg_write_ctrl, mem_to_reg_ctrl, mem_write_ctrl, alu_src_ctrl, reg_dest_ctrl, jump_ctrl;
    logic [2:0]  alu_control_ctrl;
    logic        pc_src_ctrl;       // not used (branch decision in EX in DataPath)
    logic        branch_ctrl;
    logic [31:0] instr_from_dp;

    // --- Forwarding wires ---
    logic [1:0]  fwd_a, fwd_b;
    logic [4:0]  rs_E, rt_E, write_reg_M, write_reg_W;
    logic        reg_write_M, reg_write_W;

    // --- Hazard wires ---
    logic        stall_F, stall_D, flush_E;
    logic [4:0]  rs_D, rt_D;
    logic        mem_to_reg_E;

    // --- Control Unit ---
    ControlUnit Cu(
        .opcode(instr_from_dp[31:26]),
        .funct(instr_from_dp[5:0]),
        .zero_flag(1'b0),

        .alu_control(alu_control_ctrl),
        .mem_to_reg(mem_to_reg_ctrl),
        .alu_src(alu_src_ctrl),
        .reg_dest(reg_dest_ctrl),
        .reg_write(reg_write_ctrl),
        .jump(jump_ctrl),
        .pc_src(pc_src_ctrl),
        .branch(branch_ctrl),
        .mem_write(mem_write_ctrl)
    );

    // --- Hazard Unit (FIXED: matches the updated module ports) ---
    HazardUnit hu (
        .rs_D(rs_D),
        .rt_D(rt_D),
        .mem_to_reg_E(mem_to_reg_E),
        .rt_E(rt_E),

        .stall_F(stall_F),
        .stall_D(stall_D),
        .flush_E(flush_E)
    );

    // --- Forwarding Unit ---
    ForwardingUnit fu (
        .reg_write_M(reg_write_M),
        .write_reg_M(write_reg_M),
        .reg_write_W(reg_write_W),
        .write_reg_W(write_reg_W),
        .rs_E(rs_E),
        .rt_E(rt_E),

        .forward_a(fwd_a),
        .forward_b(fwd_b)
    );

    // --- Data Path ---
    DataPath dp(
        .reset_n_synch(reset_n),
        .clock(clock),
        .instruction(instruction),
        .read_data_M(read_data),

        .pc_out(pc),
        .alu_out_M(alu_out),
        .write_data_M(write_data),
        .mem_write_out(mem_write),

        .instr_D_out(instr_from_dp),

        .alu_control_in(alu_control_ctrl),
        .mem_to_reg_in(mem_to_reg_ctrl),
        .alu_src_in(alu_src_ctrl),
        .reg_dest_in(reg_dest_ctrl),
        .reg_write_in(reg_write_ctrl),
        .jump_in(jump_ctrl),
        .branch_in(branch_ctrl),
        .mem_write_in(mem_write_ctrl),

        .forward_a_in(fwd_a),
        .forward_b_in(fwd_b),

        .stall_F_in(stall_F),
        .stall_D_in(stall_D),
        .flush_E_in(flush_E),

        .rs_D_out(rs_D),
        .rt_D_out(rt_D),
        .rs_E_out(rs_E),
        .rt_E_out(rt_E),
        .mem_to_reg_E_out(mem_to_reg_E),

        .write_reg_M_out(write_reg_M),
        .write_reg_W_out(write_reg_W),
        .reg_write_M_out(reg_write_M),
        .reg_write_W_out(reg_write_W),

        .result_W_out()
    );

endmodule
