# Pipelined MIPS 5-stage (SystemVerilog)

## Run all programs (prog1-prog4) in ModelSim
1. Open ModelSim in this folder
2. Run:
   do run_all.do

### run_all.do details
- Compiles all SystemVerilog files (smart DataMem handling)
- Calls run_prog1.do, run_prog2.do, run_prog3.do
- If run_prog4.do exists, also calls it
- Each program runs separately with its own waves and checks

## What PASS looks like
Each program prints a PERF line and then the expected memory value.

- prog1: expects mem[0x54] = 0x07
- prog2: expects mem[0x00] = 0x3C (60)
- prog3: expects mem[0x00] = 0x13B0 (5040)
- prog4: expects mem[0x00] = 0x08 (8)  (store-data forwarding test)

## Notes
- Top_tb.sv gates assertions and counters using dut.reset_n_synch_w to avoid false events during reset synchronizer settling.
- run_all.do compiles all *.sv but ensures only one DataMem is compiled:
  - If DataMem_corrected.sv exists: compile only that
  - Else: compile DataMem.sv