// ============================================================================
//  AUTHOR: Mohamed Maged Elkholy.
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: DataPath.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: datapath, pipeline, forwarding, hazard, branch, jump.
//  PURPOSE: Implements the full 5-stage pipelined datapath with pipeline registers,
//  PURPOSE: forwarding, hazard handling, and branch/jump control integration.
// ============================================================================

module DataPath (
    input  logic        reset_n_synch,
    input  logic        clock,

    // --- Instruction Memory Interface ---
    output logic [31:0] pc_out,
    input  logic [31:0] instruction,

    // --- Control Unit Interface (Decode) ---
    output logic [31:0] instr_D_out,

    // Control Signals Inputs
    input  logic        reg_write_in,
    input  logic        mem_to_reg_in,
    input  logic        mem_write_in,
    input  logic [2:0]  alu_control_in,
    input  logic        alu_src_in,
    input  logic        reg_dest_in,
    input  logic        jump_in,
    input  logic        branch_in,

    // --- Data Memory Interface ---
    output logic [31:0] alu_out_M,
    output logic [31:0] write_data_M,
    output logic        mem_write_out,
    input  logic [31:0] read_data_M,

    // --- Forwarding Unit Interface ---
    input  logic [1:0]  forward_a_in,
    input  logic [1:0]  forward_b_in,

    // --- Hazard Unit Interface (Stalls & Flushes) ---
    input  logic        stall_F_in,
    input  logic        stall_D_in,
    input  logic        flush_E_in,

    // Outputs to Hazard/Forwarding Units
    output logic [4:0]  rs_D_out,
    output logic [4:0]  rt_D_out,
    output logic [4:0]  rs_E_out,
    output logic [4:0]  rt_E_out,
    output logic        mem_to_reg_E_out,

    output logic [4:0]  write_reg_M_out,
    output logic [4:0]  write_reg_W_out,
    output logic        reg_write_M_out,
    output logic        reg_write_W_out,

    // Debug Output
    output logic [31:0] result_W_out
);

    // =========================================================================
    // 1. FETCH STAGE (F)
    // =========================================================================
    logic [31:0] pc_current_F;
    logic [31:0] pc_next_F;
    logic [31:0] pc_plus4_F;

    // Used for branch/jump control
    logic        flush_D;
    logic [31:0] pc_jump_D;

    // Branch decision from EX stage
    logic [31:0] pc_branch_E;
    logic        pc_src_E;

    // PC Register
    PipelineReg #(.WIDTH(32)) pc_reg (
        .clock(clock),
        .reset_n(reset_n_synch),
        .clear(1'b0),
        .en(~stall_F_in),
        .d(pc_next_F),
        .q(pc_current_F)
    );

    assign pc_out = pc_current_F;

    Adder #(.BUS(32)) add_pc (
        .reset_n(reset_n_synch), .data_a(pc_current_F), .data_b(32'd4), .data_res(pc_plus4_F)
    );

    // PC Next selection: Branch (EX) has priority, then Jump (D), else +4
    always_comb begin
        if (pc_src_E)
            pc_next_F = pc_branch_E;
        else if (jump_in)
            pc_next_F = pc_jump_D;
        else
            pc_next_F = pc_plus4_F;
    end

    // =========================================================================
    // IF/ID PIPELINE REGISTERS
    // =========================================================================
    logic [31:0] instr_D;
    logic [31:0] pc_plus4_D;

    PipelineReg #(.WIDTH(32)) if_id_instr (
        .clock(clock), .reset_n(reset_n_synch),
        .clear(flush_D),
        .en(~stall_D_in),
        .d(instruction), .q(instr_D)
    );

    PipelineReg #(.WIDTH(32)) if_id_pc (
        .clock(clock), .reset_n(reset_n_synch),
        .clear(flush_D),
        .en(~stall_D_in),
        .d(pc_plus4_F), .q(pc_plus4_D)
    );

    assign instr_D_out = instr_D;

    // Jump target (Decode stage)
    assign pc_jump_D = { pc_plus4_D[31:28], instr_D[25:0], 2'b00 };

    // Flush IF/ID when Jump happens or Branch taken in EX
    assign flush_D = pc_src_E | jump_in;

    // =========================================================================
    // 2. DECODE STAGE (D)
    // =========================================================================
    logic [31:0] rd1_D, rd2_D;
    logic [31:0] sign_imm_D;
    logic [4:0]  rs_D, rt_D, rd_D;

    // Coming from Writeback
    logic [31:0] result_W;
    logic [4:0]  write_reg_W;
    logic        reg_write_W;

    assign rs_D = instr_D[25:21];
    assign rt_D = instr_D[20:16];
    assign rd_D = instr_D[15:11];

    assign rs_D_out = rs_D;
    assign rt_D_out = rt_D;

    RegFile rf (
        .clock(clock),
        .write_enable(reg_write_W),
        .addr1(rs_D),
        .addr2(rt_D),
        .addr3(write_reg_W),
        .write_data(result_W),
        .rd1(rd1_D),
        .rd2(rd2_D)
    );

    SignExtn #(.BEFORE(16),.AFTER(32)) se (
        .data_in(instr_D[15:0]), .data_signed(sign_imm_D)
    );

    // =========================================================================
    // ID/EX PIPELINE REGISTERS
    // =========================================================================
    logic       reg_write_E, mem_to_reg_E, mem_write_E, alu_src_E, reg_dest_E;
    logic [2:0] alu_control_E;
    logic [31:0] rd1_E, rd2_E, sign_imm_E;
    logic [4:0]  rs_E, rt_E, rd_E;

    // Add pc_plus4 and branch to EX
    logic [31:0] pc_plus4_E;
    logic        branch_E;

    // CRITICAL: bubble ID/EX not only on load-use, also on control hazards
    logic flush_E_effective;
    assign flush_E_effective = flush_E_in | pc_src_E | jump_in;

    // Control Signals (cleared on flush_E_effective)
    PipelineReg #(.WIDTH(1)) reg_wr_E_r   (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(reg_write_in),   .q(reg_write_E));
    PipelineReg #(.WIDTH(1)) mem2reg_E_r  (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(mem_to_reg_in),  .q(mem_to_reg_E));
    PipelineReg #(.WIDTH(1)) mem_wr_E_r   (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(mem_write_in),   .q(mem_write_E));
    PipelineReg #(.WIDTH(3)) alu_ctl_E_r  (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(alu_control_in), .q(alu_control_E));
    PipelineReg #(.WIDTH(1)) alu_src_E_r  (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(alu_src_in),     .q(alu_src_E));
    PipelineReg #(.WIDTH(1)) reg_dst_E_r  (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(reg_dest_in),    .q(reg_dest_E));

    // Branch control to EX (cleared on bubble)
    PipelineReg #(.WIDTH(1)) branch_E_r   (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(branch_in),      .q(branch_E));

    // Data Pipeline (ALSO cleared on flush_E_effective)
    PipelineReg #(.WIDTH(32)) rd1_reg_E   (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(rd1_D),        .q(rd1_E));
    PipelineReg #(.WIDTH(32)) rd2_reg_E   (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(rd2_D),        .q(rd2_E));
    PipelineReg #(.WIDTH(32)) imm_reg_E   (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(sign_imm_D),   .q(sign_imm_E));
    PipelineReg #(.WIDTH(32)) pc4_reg_E   (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(pc_plus4_D),   .q(pc_plus4_E));

    PipelineReg #(.WIDTH(5))  rt_reg_E    (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(rt_D),         .q(rt_E));
    PipelineReg #(.WIDTH(5))  rd_reg_E    (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(rd_D),         .q(rd_E));
    PipelineReg #(.WIDTH(5))  rs_reg_E    (.clock(clock), .reset_n(reset_n_synch), .clear(flush_E_effective), .en(1'b1), .d(rs_D),         .q(rs_E));

    // Outputs to Hazard Unit
    assign rs_E_out = rs_E;
    assign rt_E_out = rt_E;
    assign mem_to_reg_E_out = mem_to_reg_E;

    // =========================================================================
    // 3. EXECUTE STAGE (E) - WITH FORWARDING LOGIC
    // =========================================================================
    logic [31:0] src_a_E_final;
    logic [31:0] src_b_E_intermediate;
    logic [31:0] src_b_E_final;
    logic [31:0] alu_res_E;
    logic [4:0]  write_reg_E;
    logic        zero_E;
    logic [31:0] result_M_fwd;

    // Forwarding MUX A
    always_comb begin
        case (forward_a_in)
            2'b00: src_a_E_final = rd1_E;
            2'b01: src_a_E_final = result_W;
            2'b10: src_a_E_final = result_M_fwd;
            default: src_a_E_final = rd1_E;
        endcase
    end

    // Forwarding MUX B
    always_comb begin
        case (forward_b_in)
            2'b00: src_b_E_intermediate = rd2_E;
            2'b01: src_b_E_intermediate = result_W;
            2'b10: src_b_E_intermediate = result_M_fwd;
            default: src_b_E_intermediate = rd2_E;
        endcase
    end

    // ALU src mux (imm vs reg)
    MUX #(.BUS(32)) mux_alu_src (
        .data_true(sign_imm_E),
        .data_false(src_b_E_intermediate),
        .sel(alu_src_E),
        .data_out(src_b_E_final)
    );

    ALU #(.WIDTH(32)) alu_inst (
        .reset_n(reset_n_synch),
        .src_a(src_a_E_final),
        .src_b(src_b_E_final),
        .alu_control(alu_control_E),
        .alu_result(alu_res_E),
        .zero_flag(zero_E)
    );

    // Branch decision and target in EX
    assign pc_branch_E = pc_plus4_E + (sign_imm_E << 2);
    assign pc_src_E    = branch_E & zero_E;

    // Destination reg mux
    MUX #(.BUS(5)) mux_reg_dst (
        .data_true(rd_E),
        .data_false(rt_E),
        .sel(reg_dest_E),
        .data_out(write_reg_E)
    );

    // =========================================================================
    // EX/MEM PIPELINE REGISTERS
    // =========================================================================
    logic       reg_write_M, mem_to_reg_M, mem_write_M_internal;
    logic [31:0] alu_res_M;
    logic [31:0] write_data_M_internal;
    logic [4:0]  write_reg_M;

    assign result_M_fwd = mem_to_reg_M ? read_data_M : alu_out_M;

    PipelineReg #(.WIDTH(1)) reg_wr_M_r   (.clock(clock), .reset_n(reset_n_synch), .clear(1'b0), .en(1'b1), .d(reg_write_E),  .q(reg_write_M));
    PipelineReg #(.WIDTH(1)) mem2reg_M_r  (.clock(clock), .reset_n(reset_n_synch), .clear(1'b0), .en(1'b1), .d(mem_to_reg_E), .q(mem_to_reg_M));
    PipelineReg #(.WIDTH(1)) mem_wr_M_r   (.clock(clock), .reset_n(reset_n_synch), .clear(1'b0), .en(1'b1), .d(mem_write_E),  .q(mem_write_M_internal));

    PipelineReg #(.WIDTH(32)) alu_M_r     (.clock(clock), .reset_n(reset_n_synch), .clear(1'b0), .en(1'b1), .d(alu_res_E),    .q(alu_res_M));

    // Store data must be forwarded data
    PipelineReg #(.WIDTH(32)) wdata_M_r   (.clock(clock), .reset_n(reset_n_synch), .clear(1'b0), .en(1'b1), .d(src_b_E_intermediate), .q(write_data_M_internal));

    PipelineReg #(.WIDTH(5))  wreg_M_r    (.clock(clock), .reset_n(reset_n_synch), .clear(1'b0), .en(1'b1), .d(write_reg_E),  .q(write_reg_M));

    assign alu_out_M        = alu_res_M;
    assign write_data_M     = write_data_M_internal;
    assign mem_write_out    = mem_write_M_internal;
    assign write_reg_M_out  = write_reg_M;
    assign reg_write_M_out  = reg_write_M;

    // =========================================================================
    // MEM/WB PIPELINE REGISTERS
    // =========================================================================
    logic       mem_to_reg_W;
    logic [31:0] read_data_W, alu_res_W;

    PipelineReg #(.WIDTH(1)) reg_wr_W_r   (.clock(clock), .reset_n(reset_n_synch), .clear(1'b0), .en(1'b1), .d(reg_write_M), .q(reg_write_W));
    PipelineReg #(.WIDTH(1)) mem2reg_W_r  (.clock(clock), .reset_n(reset_n_synch), .clear(1'b0), .en(1'b1), .d(mem_to_reg_M), .q(mem_to_reg_W));

    PipelineReg #(.WIDTH(32)) rdata_W_r   (.clock(clock), .reset_n(reset_n_synch), .clear(1'b0), .en(1'b1), .d(read_data_M), .q(read_data_W));
    PipelineReg #(.WIDTH(32)) alu_W_r     (.clock(clock), .reset_n(reset_n_synch), .clear(1'b0), .en(1'b1), .d(alu_res_M),   .q(alu_res_W));
    PipelineReg #(.WIDTH(5))  wreg_W_r    (.clock(clock), .reset_n(reset_n_synch), .clear(1'b0), .en(1'b1), .d(write_reg_M), .q(write_reg_W));

    // =========================================================================
    // 5. WRITEBACK STAGE (W)
    // =========================================================================
    MUX #(.BUS(32)) mux_res (
        .data_true(read_data_W),
        .data_false(alu_res_W),
        .sel(mem_to_reg_W),
        .data_out(result_W)
    );

    assign result_W_out     = result_W;
    assign write_reg_W_out  = write_reg_W;
    assign reg_write_W_out  = reg_write_W;

`ifdef DEBUG
    // Debug: print only when PC is in the loop window
    always_ff @(posedge clock) begin
        if (reset_n_synch) begin
            if (pc_current_F >= 32'h00000010 && pc_current_F <= 32'h0000002C) begin
                $display("PC=%h | instrD=%h | pc_src_E=%b branch_E=%b zero_E=%b alu_ctl_E=%b | rsE=%0d rtE=%0d wregE=%0d | regW E/M/W=%b/%b/%b mem2reg E/M/W=%b/%b/%b | fwdA=%b fwdB=%b | stallF=%b stallD=%b flushE=%b",
                    pc_current_F, instr_D, pc_src_E, branch_E, zero_E, alu_control_E,
                    rs_E, rt_E, write_reg_E,
                    reg_write_E, reg_write_M, reg_write_W,
                    mem_to_reg_E, mem_to_reg_M, mem_to_reg_W,
                    forward_a_in, forward_b_in,
                    stall_F_in, stall_D_in, flush_E_in
                );
                $display("   rd1E=%h rd2E=%h srcA=%h srcBint=%h srcB=%h aluRes=%h | s0=%h s1=%h s2=%h",
                    rd1_E, rd2_E, src_a_E_final, src_b_E_intermediate, src_b_E_final, alu_res_E,
                    rf.registers[16], rf.registers[17], rf.registers[18]
                );
            end
        end
    end
`endif

endmodule
