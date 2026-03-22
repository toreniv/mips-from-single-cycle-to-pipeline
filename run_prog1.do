# ============================================================================
# ModelSim DO File - Run prog1 (Comprehensive Test)
# ============================================================================

echo ""
echo "=========================================="
echo "Testing prog1 (Comprehensive Test)"
echo "Expected: Value 0x07 at address 0x54"
echo "=========================================="

vsim -voptargs=+acc -wlf prog1.wlf -quiet work.Top_tb -GPROGRAM_FILE="prog1.txt"

# Add waves for prog1
catch {delete wave *}
add wave -noupdate -divider "Clock & Reset"
add wave -noupdate /Top_tb/clock_tb
add wave -noupdate /Top_tb/reset_n_tb

add wave -noupdate -divider "PC & Instruction"
add wave -noupdate -radix hex /Top_tb/dut/pc_w
add wave -noupdate -radix hex /Top_tb/dut/instr_w

add wave -noupdate -divider "IF/ID + Decode"
catch {add wave -noupdate -radix hex /Top_tb/dut/mips/dp/instr_D}
catch {add wave -noupdate -radix hex /Top_tb/dut/mips/dp/pc_plus4_D}
catch {add wave -noupdate -radix hex /Top_tb/dut/mips/dp/if_id_instr/q}
catch {add wave -noupdate -radix hex /Top_tb/dut/mips/dp/if_id_pc/q}

add wave -noupdate -divider "Hazards"
catch {add wave -noupdate /Top_tb/dut/mips/stall_F}
catch {add wave -noupdate /Top_tb/dut/mips/stall_D}
catch {add wave -noupdate /Top_tb/dut/mips/flush_E}
catch {add wave -noupdate /Top_tb/dut/mips/dp/flush_D}
catch {add wave -noupdate /Top_tb/dut/mips/dp/flush_E_effective}

add wave -noupdate -divider "Forwarding"
catch {add wave -noupdate /Top_tb/dut/mips/fwd_a}
catch {add wave -noupdate /Top_tb/dut/mips/fwd_b}

add wave -noupdate -divider "Memory Interface"
add wave -noupdate /Top_tb/dut/mem_write_w
add wave -noupdate -radix hex /Top_tb/dut/alu_out_w
add wave -noupdate -radix hex /Top_tb/dut/write_data_w

add wave -noupdate -divider "Test Value"
add wave -noupdate -radix hex /Top_tb/test_value_tb

run -all

echo ""
echo "Checking prog1 result..."
echo "Value at address 0x54 (word index 21):"
examine -radix hex /Top_tb/dut/dm/data_mem(21)

catch {write format wave -window .main_pane.wave -file waves_prog1.do}
catch {wave zoom full}

echo ""
echo "=========================================="
echo "Prog1 finished. Waves are preserved for inspection."
echo "=========================================="
