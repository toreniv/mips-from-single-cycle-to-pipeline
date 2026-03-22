# waves.do
delete wave *
configure wave -signalnamewidth 1

add wave -divider "GLOBAL"
add wave -radix binary /Top_tb/clock_tb
add wave -radix binary /Top_tb/reset_n_tb
add wave -radix hex    /Top_tb/test_value_tb

add wave -divider "TOP LEVEL"
add wave -radix hex    /Top_tb/dut/pc_w
add wave -radix hex    /Top_tb/dut/instr_w
add wave -radix hex    /Top_tb/dut/alu_out_w
add wave -radix hex    /Top_tb/dut/write_data_w
add wave -radix binary /Top_tb/dut/mem_write_w

add wave -divider "HAZARDS"
add wave -radix binary /Top_tb/dut/mips/hu/stall_F
add wave -radix binary /Top_tb/dut/mips/hu/stall_D
add wave -radix binary /Top_tb/dut/mips/hu/flush_E
add wave -radix binary /Top_tb/dut/mips/hu/flush_D

add wave -divider "FORWARDING"
add wave -radix binary /Top_tb/dut/mips/fu/forward_a
add wave -radix binary /Top_tb/dut/mips/fu/forward_b

add wave -divider "DATAPATH"
add wave -radix hex /Top_tb/dut/mips/dp/alu_out_M
add wave -radix hex /Top_tb/dut/mips/dp/write_data_M
add wave -radix hex /Top_tb/dut/mips/dp/result_W

wave zoom full