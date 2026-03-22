# ============================================================================
# ModelSim DO File - Run prog4 (Store-Data Forwarding)
# ============================================================================

echo ""
echo "=========================================="
echo "Testing prog4 (Store-Data Forwarding)"
echo "Expected: 0x08 (8 decimal) at address 0x00"
echo "=========================================="

vsim -voptargs=+acc -wlf prog4.wlf -quiet work.Top_tb -GPROGRAM_FILE="prog4.txt"

# Add waves for prog4
catch {delete wave *}
add wave -noupdate -divider "Clock & Reset"
add wave -noupdate /Top_tb/clock_tb
add wave -noupdate /Top_tb/reset_n_tb

add wave -noupdate -divider "PC & Instruction"
add wave -noupdate -radix hex /Top_tb/dut/pc_w
add wave -noupdate -radix hex /Top_tb/dut/instr_w

add wave -noupdate -divider "EX/MEM/WB stages"
catch {add wave -noupdate /Top_tb/dut/mips/dp/reg_write_E}
catch {add wave -noupdate -radix hex /Top_tb/dut/mips/dp/write_reg_E}
catch {add wave -noupdate -radix hex /Top_tb/dut/mips/dp/alu_res_E}
catch {add wave -noupdate /Top_tb/dut/mips/fwd_b}

add wave -noupdate -divider "Memory Interface"
add wave -noupdate /Top_tb/dut/mem_write_w
add wave -noupdate -radix hex /Top_tb/dut/alu_out_w
add wave -noupdate -radix hex /Top_tb/dut/write_data_w

add wave -noupdate -divider "Test Value"
add wave -noupdate -radix hex /Top_tb/test_value_tb

run -all

echo ""
echo "Checking prog4 result..."
echo "Value at address 0x00:"
examine -radix hex /Top_tb/dut/dm/data_mem(0)
examine -radix unsigned /Top_tb/dut/dm/data_mem(0)
echo "Expected: 0x00000008 (8 decimal)"
echo "test_value should be: 0008"

catch {write format wave -window .main_pane.wave -file waves_prog4.do}
catch {wave zoom full}

echo ""
echo "=========================================="
echo "Prog4 finished. Waves are preserved for inspection."
echo "=========================================="
