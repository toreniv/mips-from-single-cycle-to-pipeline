# ============================================================================
# ModelSim DO File - Run prog3 (Factorial)
# ============================================================================

echo ""
echo "=========================================="
echo "Testing prog3 (Factorial of 7)"
echo "Expected: 0x13B0 (5040 decimal) at address 0x00"
echo "=========================================="

vsim -voptargs=+acc -wlf prog3.wlf -quiet work.Top_tb -GPROGRAM_FILE="prog3.txt"

# Add waves for prog3
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

# Add register file to see factorial calculation
add wave -noupdate -divider "Registers"
add wave -noupdate -radix unsigned /Top_tb/dut/mips/dp/rf/registers(16)
add wave -noupdate -radix unsigned /Top_tb/dut/mips/dp/rf/registers(17)

run -all

echo ""
echo "Checking prog3 result..."
echo "Value at address 0x00:"
examine -radix hex /Top_tb/dut/dm/data_mem(0)
examine -radix unsigned /Top_tb/dut/dm/data_mem(0)
echo "Expected: 0x000013B0 (5040 decimal)"
echo "test_value should be: 13B0"

catch {write format wave -window .main_pane.wave -file waves_prog3.do}
catch {wave zoom full}

echo ""
echo "=========================================="
echo "Prog3 finished. Waves are preserved for inspection."
echo "=========================================="
