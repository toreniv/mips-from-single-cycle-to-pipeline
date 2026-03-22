# ============================================================================
# ModelSim DO File - Setup + Compile (Shared)
# ============================================================================

# Clean previous compilation
quit -sim
file delete -force work
file delete -force transcript

# Create work library
vlib work

# Compile all files (make sure DataMem is the corrected version!)
echo "Compiling all SystemVerilog files..."
vlog -sv +acc=rn *.sv

if {[file exists "DataMem_corrected.sv"]} {
    echo "Using corrected DataMem.sv"
    vlog -sv +acc=rn DataMem_corrected.sv
}
