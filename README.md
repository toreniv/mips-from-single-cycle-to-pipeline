# Pipelined MIPS Processor - From Single-Cycle to 5-Stage Pipeline

A SystemVerilog implementation of a MIPS processor that was extended from a single-cycle baseline into a full 5-stage pipelined architecture.

This project demonstrates the transition from a basic non-pipelined CPU into a more realistic pipelined design with hazard handling, forwarding, flushing, and automated verification in ModelSim.

## Project Overview

The original baseline started as a single-cycle MIPS implementation.  
In this project, it was redesigned into a 5-stage pipelined processor with the classic stages:

- IF - Instruction Fetch
- ID - Instruction Decode / Register Read
- EX - Execute / ALU
- MEM - Data Memory Access
- WB - Write Back

The pipelined version includes:

- Hazard Unit for load-use hazard detection
- Forwarding Unit for resolving RAW dependencies
- Branch handling with flush logic
- Reset synchronization for stable startup behavior
- Automated ModelSim scripts for running and validating multiple programs

## Architecture

### 5-Stage Pipeline Structure

[Pipeline Overview](docs/images/pipeline_overview.png)

The design separates instruction execution into five stages, allowing overlap between consecutive instructions and improving throughput compared to the original single-cycle architecture.

### Main Verification Goals

The project was verified around the most important pipeline behaviors:

- Correct instruction flow across IF/ID/EX/MEM/WB
- Correct forwarding from later stages back into EX
- Correct load-use hazard detection with stall and flush
- Correct branch taken behavior with pipeline flushing
- Correct memory writeback behavior
- Stable reset behavior using a reset synchronizer

## Key Features

### 1. Hazard Detection
The Hazard Unit detects load-use hazards and stalls the pipeline when forwarding alone is not enough.

### 2. Forwarding
The Forwarding Unit resolves common data hazards by forwarding values from later pipeline stages instead of waiting for register writeback.

### 3. Branch Flush Handling
Branch decisions are resolved in the EX stage.  
When a branch is taken, the relevant pipeline stage is flushed so incorrect instructions do not continue execution.

### 4. Automated Verification
The repository includes ModelSim `.do` scripts that compile the design and run multiple verification programs automatically.

## Repository Structure

```text
Code/
├── Top.sv
├── Top_tb.sv
├── MIPS.sv
├── DataPath.sv
├── HazardUnit.sv
├── ForwardingUnit.sv
├── PipelineReg.sv
├── ControlUnit.sv
├── DataMem.sv
├── RegFile.sv
├── InstrMem.sv
├── ResetSynchronizer.sv
├── prog1
├── prog2
├── prog3
├── prog4
├── run_all.do
├── run_prog1.do
├── run_prog2.do
├── run_prog3.do
├── run_prog4.do
└── README.md
````

## Test Programs

The design was verified using four separate programs:

### Prog1 - Basic Program

A general functional test used to verify the basic pipelined flow and correct final memory write.

Expected result:

* `mem[0x54] = 0x07`

### Prog2 - GCD

Computes the greatest common divisor of 120 and 180.

Expected result:

* `mem[0x00] = 0x3C`
* decimal result: `60`

### Prog3 - Factorial

Computes factorial of 7.

Expected result:

* `mem[0x00] = 0x13B0`
* decimal result: `5040`

### Prog4 - Store-Data Forwarding Test

A dedicated verification program added specifically to validate store-data forwarding.

It performs:

* two `addi` instructions
* one `add`
* one immediate `sw`

Expected result:

* `mem[0x00] = 0x08`

This test is important because it checks that a value produced by the ALU can be correctly forwarded in time for a following store instruction.

## Verification Results

The following performance counters were collected from simulation:

| Program | Cycles | Stalls | Flushes | Final Result         |
| ------- | -----: | -----: | ------: | -------------------- |
| Prog1   |     21 |      0 |       2 | `mem[0x54] = 0x07`   |
| Prog2   |     26 |      0 |       4 | `mem[0x00] = 0x3C`   |
| Prog3   |     45 |      0 |       8 | `mem[0x00] = 0x13B0` |
| Prog4   |      6 |      0 |       0 | `mem[0x00] = 0x08`   |

These results show that:

* the pipeline operates correctly across all test programs
* flush activity appears where branch behavior is expected
* the dedicated forwarding test passes
* the design reaches the expected final memory values in all cases

## ModelSim Waveforms

### Example Waveform - Prog3

![Prog3 Waveform](docs/images/prog3_wave.png)

This waveform demonstrates correct pipeline progression during the factorial program, including instruction flow, memory write, and correct final result.

### Example Waveform - Prog4 Store-Data Forwarding

![Prog4 Waveform](docs/images/prog4_wave.png)

This waveform demonstrates the dedicated store-data forwarding scenario:

* ALU result is produced
* the following store writes the forwarded value
* final memory result is `0x00000008`

### Example Waveform - GCD Branch Behavior

![Prog2 Waveform](docs/images/prog2_wave.png)

This waveform highlights branch activity and loop execution in the GCD program, showing the correct final convergence to the expected GCD value.

## Reset and Testbench Notes

`Top_tb.sv` was updated so that:

* assertions and counters run only after `dut.reset_n_synch_w` is active
* false events during reset synchronizer settling are avoided
* final memory reporting uses `expected_addr` instead of always showing `mem[0]`
* the testbench checks both expected address and expected data before declaring completion

This makes the simulation output more robust and prevents misleading PASS indications.

## How to Run

### Run all programs

Open ModelSim in the project folder and run:

```tcl
do run_all.do
```

### Run individual programs

You can also run each program separately:

```tcl
do run_prog1.do
do run_prog2.do
do run_prog3.do
do run_prog4.do
```

## What PASS Looks Like

A successful run should show:

* a `PERF:` line
* a memory write detection message
* the correct final value in memory
* no assertion failures

Example for `prog4`:

```text
PERF: cycles=6 stalls=0 flushes=0
Memory[0x00000000] = 0x00000008 (8 decimal)
```

## Authors

* Niv Toren
* Ryan Lifshitz

## Credits

Original single-cycle baseline reference:

* Mohamed Maged Elkholy
  Alexandria University, Egypt

The pipelined architecture, hazard handling, forwarding behavior, verification flow, and testing extensions were independently developed and extended in this project.

## Notes

This repository is focused on architectural extension and verification of a pipelined MIPS processor in SystemVerilog.
The emphasis is on correctness, hazard handling, forwarding behavior, and clear simulation-based validation.

