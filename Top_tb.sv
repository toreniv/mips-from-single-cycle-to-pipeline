// ============================================================================
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: Top_tb.sv
//  TYPE: tb.
//  DATE: 05/02/2026
//  KEYWORDS: testbench, Top, program loader, verification.
//  PURPOSE: Testbench for Top that runs program images and checks memory results.
// ============================================================================
`timescale 1ns/1ps

// ============================================================================
// Enhanced Debug Testbench for prog2
// Shows register values to debug the infinite loop
// ============================================================================

module Top_tb #(parameter PROGRAM_FILE = "prog1.txt",
                parameter int VERBOSITY = 0);

    reg         reset_n_tb;
    reg         clock_tb;
    wire [15:0] test_value_tb;

    Top #(.PROGRAM_FILE(PROGRAM_FILE)) dut(
        .reset_n    (reset_n_tb),
        .clock      (clock_tb),
        .test_value (test_value_tb)
    );

    parameter int CLKPERIOD   = 10;
    parameter int RUN_CYCLES  = 300;
    parameter int PRINT_EVERY = 5;


    // Clock
    initial begin
        clock_tb = 1'b0;
        forever #(CLKPERIOD/2) clock_tb = ~clock_tb;
    end

    // Enhanced monitoring with register values
    localparam int VERBOSITY_LOW  = 0;
    localparam int VERBOSITY_HIGH = 1;

    int cyc;
    int warmup_cnt;
    bit cycle_print_en = 1'b1;
    bit done_print_suppression = 1'b0;
    bit verbose_cycles = 1'b0;
    bit final_instr_printed = 1'b0;
    logic [31:0] expected_addr;
    logic [31:0] expected_value;
    logic        done;
    bit          done_latched;
    bit          perf_printed;
    bit          timeout_latched;
    int          cycle_count;
    int          stall_count;
    int          flush_count;
    int          run_cycle_count;
    initial begin
        cyc = 0;
        warmup_cnt = 0;
        cycle_print_en = 1'b0;
        done_print_suppression = 1'b0;
        verbose_cycles = (VERBOSITY == VERBOSITY_HIGH);
        final_instr_printed = 1'b0;
        expected_addr = 32'h00000000;
        expected_value = 32'h00000000;
        done_latched = 1'b0;
        perf_printed = 1'b0;
        timeout_latched = 1'b0;
        cycle_count = 0;
        stall_count = 0;
        flush_count = 0;
        run_cycle_count = 0;

        if (PROGRAM_FILE == "prog1.txt") begin
            expected_addr = 32'h00000054;
            expected_value = 32'h00000007;
        end
        else if (PROGRAM_FILE == "prog2.txt") begin
            expected_addr = 32'h00000000;
            expected_value = 32'h0000003C;
        end
        else if (PROGRAM_FILE == "prog3.txt") begin
            expected_addr = 32'h00000000;
            expected_value = 32'h000013B0;
        end
        else if (PROGRAM_FILE == "prog4.txt") begin
            expected_addr = 32'h00000000;
            expected_value = 32'h00000008;
        end
    end

    assign done = (dut.mem_write_w && (dut.alu_out_w == expected_addr) && (dut.write_data_w == expected_value));

    // Reset + run
    integer i;
    initial begin
        reset_n_tb = 1'b1;
        #(CLKPERIOD)     reset_n_tb = 1'b0;
        #(2*CLKPERIOD)   reset_n_tb = 1'b1;

        repeat (5) @(posedge clock_tb);
        // Main stop conditions handled by done/timeout logic
        wait (done_latched || timeout_latched);

        $display("--------------------------------------------------");
        $display("TB Finished. Final test_value = %h", test_value_tb);
        $display("Memory[0x%08h] = 0x%08h (%0d decimal)", 
                 expected_addr, dut.dm.data_mem[expected_addr>>2], dut.dm.data_mem[expected_addr>>2]);
        $display("--------------------------------------------------");
    end

    always @(posedge clock_tb) begin
        if (!reset_n_tb) begin
            warmup_cnt <= 0;
            cycle_print_en <= 1'b0;
            done_print_suppression <= 1'b0;
            cyc <= 0;
            final_instr_printed <= 1'b0;
            done_latched <= 1'b0;
            perf_printed <= 1'b0;
            timeout_latched <= 1'b0;
            cycle_count <= 0;
            stall_count <= 0;
            flush_count <= 0;
            run_cycle_count <= 0;
        end else if (dut.reset_n_synch_w) begin
            // ========== ASSERTIONS (guarded by reset_n_synch_w) ==========

            // ASSERTION 1: $zero must remain zero
            if (dut.mips.dp.rf.registers[0] !== 32'h0) begin
                $fatal(1, "ASSERTION FAILED at %0t: $zero (reg[0]) = 0x%h, expected 0x00000000",
                       $time, dut.mips.dp.rf.registers[0]);
            end

            // ASSERTION 2: Load-use hazard must trigger stall + flush
            if (dut.mips.mem_to_reg_E && (dut.mips.rt_E != 5'd0) &&
                ((dut.mips.rt_E == dut.mips.rs_D) || (dut.mips.rt_E == dut.mips.rt_D))) begin
                if (!(dut.mips.stall_F && dut.mips.stall_D && dut.mips.flush_E)) begin
                    $fatal(1, "ASSERTION FAILED at %0t: load-use hazard NOT stalled. " ,
                           "mem_to_reg_E=%b rt_E=%0d rs_D=%0d rt_D=%0d stall_F=%b stall_D=%b flush_E=%b",
                           $time, dut.mips.mem_to_reg_E, dut.mips.rt_E, 
                           dut.mips.rs_D, dut.mips.rt_D, dut.mips.stall_F, dut.mips.stall_D, dut.mips.flush_E);
                end
            end

            // ASSERTION 3: Forwarding selects must be valid (00/01/10)
            if (!(dut.mips.fwd_a inside {2'b00, 2'b01, 2'b10})) begin
                $fatal(1, "ASSERTION FAILED at %0t: forward_a = %b (invalid)", 
                       $time, dut.mips.fwd_a);
            end
            if (!(dut.mips.fwd_b inside {2'b00, 2'b01, 2'b10})) begin
                $fatal(1, "ASSERTION FAILED at %0t: forward_b = %b (invalid)", 
                       $time, dut.mips.fwd_b);
            end

            // ASSERTION 4: Memory writes must be word-aligned
            if (dut.mem_write_w && (dut.alu_out_w[1:0] !== 2'b00)) begin
                $warning("WARNING at %0t: Unaligned memory write at addr 0x%h", 
                         $time, dut.alu_out_w);
            end

            // ========== END ASSERTIONS ==========
            cyc <= cyc + 1;
            if (warmup_cnt < 5)
                warmup_cnt <= warmup_cnt + 1;
            if (warmup_cnt >= 5)
                cycle_print_en <= 1'b1;

            if (!done_latched && !timeout_latched) begin
                run_cycle_count <= run_cycle_count + 1;
                if (run_cycle_count >= RUN_CYCLES) begin
                    $display("");
                    $display("ERROR: Timeout waiting for done (>%0d cycles)", RUN_CYCLES);
                    $display("PC=0x%08h | Instr=0x%08h | test_value=%h",
                             dut.pc_w, dut.instr_w, test_value_tb);
                    $display("");
                    timeout_latched <= 1'b1;
                    #1 $stop;
                end
            end

            if (done && !done_latched) begin
                done_latched <= 1'b1;
                cycle_print_en <= 1'b0;
                done_print_suppression <= 1'b1;
                $display("PERF: cycles=%0d stalls=%0d flushes=%0d",
                         cycle_count, stall_count, flush_count);
                perf_printed <= 1'b1;
                #1 $stop;
            end

            if (!done && !done_latched && !timeout_latched) begin
                cycle_count <= cycle_count + 1;
                if (dut.mips.stall_F || dut.mips.stall_D)
                    stall_count <= stall_count + 1;
                if (dut.mips.flush_E || dut.mips.dp.flush_D || dut.mips.dp.flush_E_effective)
                    flush_count <= flush_count + 1;
            end

            if (verbose_cycles && !done_print_suppression && cycle_print_en && ((cyc % PRINT_EVERY) == 0)) begin
                $display("Cycle %3d | PC=0x%08h | Instr=0x%08h | $s0=%3d | $s1=%3d | $s2=%3d | $t1=%d",
                         cyc,
                         dut.pc_w,
                         dut.instr_w,
                         dut.mips.dp.rf.registers[16],  // $s0
                         dut.mips.dp.rf.registers[17],  // $s1
                         dut.mips.dp.rf.registers[18],  // $s2
                         dut.mips.dp.rf.registers[9]);  // $t1
            end
        end
    end

    // Detect when we reach the final instructions
    always @(posedge clock_tb) begin
        if (dut.reset_n_synch_w && (dut.pc_w == 32'h00000030) && !final_instr_printed) begin
            $display("");
            $display(">>> REACHED FINAL INSTRUCTION! PC=0x30");
            $display(">>> $s0=%d, $s1=%d, $s2=%d", 
                     dut.mips.dp.rf.registers[16],
                     dut.mips.dp.rf.registers[17],
                     dut.mips.dp.rf.registers[18]);
            $display("");
            final_instr_printed <= 1'b1;
        end
    end

    // Detect memory write
    always @(posedge clock_tb) begin
        if (dut.reset_n_synch_w && dut.mem_write_w) begin
            $display("");
            $display(">>> MEMORY WRITE DETECTED!");
            $display(">>> Address=0x%08h, Data=0x%08h (%0d)", 
                     dut.alu_out_w, dut.write_data_w, dut.write_data_w);
            $display("");
            if (dut.alu_out_w == expected_addr && dut.write_data_w == expected_value) begin
                done_print_suppression <= 1'b1;
                cycle_print_en <= 1'b0;
            end
        end
    end

    // Watchdog for infinite loop
    logic [31:0] prev_pc;
    int same_region_count;
    
    initial begin
        prev_pc = 0;
        same_region_count = 0;
    end

    always @(posedge clock_tb) begin
        if (dut.reset_n_synch_w) begin
            // Check if PC is stuck in loop region (0x14-0x2C)
            if (dut.pc_w >= 32'h14 && dut.pc_w <= 32'h2C) begin
                same_region_count++;
                if (same_region_count > 50) begin
                    $display("");
                    $display("ERROR: Stuck in loop for %0d cycles!", same_region_count);
                    $display("PC is between 0x14-0x2C (the GCD loop)");
                    $display("$s0=%d, $s1=%d - they should become equal!", 
                             dut.mips.dp.rf.registers[16],
                             dut.mips.dp.rf.registers[17]);
                    $display("");
                    $display("Possible issues:");
                    $display("1. Branch comparison not working (beq)");
                    $display("2. Subtraction producing wrong results");
                    $display("3. Register writeback not happening");
                    $display("");
                    $stop;
                end
            end else begin
                same_region_count = 0;
            end
        end
    end

endmodule
