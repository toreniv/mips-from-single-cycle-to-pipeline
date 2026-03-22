# Project Agents Instructions

## Project Overview
This project implements a 5-stage pipelined MIPS processor in SystemVerilog.
The design includes:
- Full pipeline (IF, ID, EX, MEM, WB)
- Forwarding unit
- Hazard detection unit (load-use + branch hazards)
- Branch decision in EX stage
- Jump handling in ID stage
- Pipeline flush and stall support

The goal is to pass all provided test programs using the supplied Top_tb.

## How to Run
- Simulator: ModelSim Intel FPGA Edition (GUI) running locally on my machine
- Run script (from ModelSim console):
  do run_all.do
- Top-level testbench:
  Top_tb

## Important Notes
- Running `vsim` from CLI may fail due to license limitations.
- Do NOT attempt to run the simulator yourself if licensing fails.
- Instead:
  - Analyze the ModelSim output logs that I provide.
  - Reason about pipeline behavior and bugs logically.
  - Propose concrete code fixes.

I will run the simulation locally and send you:
- Full terminal output from ModelSim
- Warnings and errors
- Behavioral symptoms (wrong register values, infinite loops, wrong memory writes)

## What You Are Allowed To Do
- Analyze logs and wave behavior logically
- Modify RTL code to fix functional bugs
- Propose minimal, targeted changes
- Return FULL updated versions of modified files
- Add temporary debug signals if clearly explained

## What You Must NOT Do
- Do not change module interfaces unless explicitly required
- Do not modify Top_tb
- Do not remove pipeline stages or simplify architecture
- Do not assume single-cycle behavior
- Do not change instruction semantics (MIPS ISA must be preserved)

## Files of Interest
Primary focus files:
- MIPS.sv
- DataPath.sv
- HazardUnit.sv
- ForwardingUnit.sv
- PipelineReg.sv
- RegFile.sv

Secondary (only if required):
- ControlUnit.sv
- MainDec.sv
- ALU.sv
- ALUDec.sv

## Debugging Strategy
When a test fails:
1. Identify which instruction types are used in the failing program.
2. Check:
   - ALU operation correctness
   - Signed vs unsigned behavior (especially SLT, SUB, MUL)
   - Branch comparison timing
   - Hazard detection completeness
   - Forwarding correctness
3. Propose the smallest possible fix that preserves the pipeline design.

## Communication Protocol
- I will send ModelSim terminal outputs after each run.
- You should:
  - Explain what the output indicates
  - Identify the root cause
  - Suggest a fix
  - Provide updated RTL code if needed


## Test Programs (prog1 / prog2 / prog3) - What Must Work

The provided run_all.do runs three programs using Top_tb:
- prog1.txt (Comprehensive Test)
- prog2.txt (GCD of 120 and 180)
- prog3.txt (Factorial of 7)

Your task is to help me make the CPU pass ALL three tests.

### prog1 (Comprehensive Test)
Expected behavior:
- The testbench checks DataMem at address 0x54
- PASS condition:
  - Memory[0x54] must equal 0x00000007

What prog1 validates (high level):
- Basic arithmetic and logic
- Correct SW/LW functionality
- Correct PC flow and instruction sequencing
- Correct register writeback for simple cases

If prog1 fails:
- First suspect: store/load address calc, mem_write, mem_to_reg, writeback mux

### prog2 (GCD of 120 and 180)
Expected behavior:
- Program computes gcd(120,180) = 60 (0x3C)
- The testbench checks DataMem at address 0x00
- PASS condition:
  - Memory[0x00] must equal 0x0000003C

What prog2 validates (high level):
- Correct branches and loops (beq/bne style flow)
- Correct subtraction and signed behavior when relevant
- Correct hazard + forwarding behavior inside loops
- Correct branch decision timing (branch depends on recent ALU results)

Common failure symptoms:
- Stuck in loop
- Registers diverge instead of converging (e.g., s0 becomes negative/huge)
Root suspects:
- Branch compare uses wrong values (no forwarding into branch path)
- Branch resolved in wrong stage vs hazard logic
- SUB or SLT signedness wrong
- Missing stall for branch dependency

### prog3 (Factorial of 7)
Expected behavior:
- Program computes 7! = 5040 (0x13B0)
- The testbench checks DataMem at address 0x00
- PASS condition:
  - Memory[0x00] must equal 0x000013B0

What prog3 validates (high level):
- Repeated multiply/accumulate loop correctness
- Forwarding of results across iterations
- Correct register writeback every iteration
- Proper handling of dependent instructions without losing updates

Common failure symptoms:
- Writes 1 to memory and stays there
Root suspects:
- MUL not implemented or wrong (signed/width)
- reg_write suppressed by flush/stall incorrectly
- Forwarding for operands in EX stage broken
- mem_to_reg/reg_dest control not pipelined/cleared properly
