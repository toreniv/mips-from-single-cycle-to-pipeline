# ============================================================================
# ModelSim DO File - Compile and Run prog1-prog4 via run_prog*.do scripts
# ============================================================================

# Clean previous compilation
catch {quit -sim}

if {[file exists work]} {
    vdel -lib work -all
}

if {[file exists transcript]} {
    file delete -force transcript
}

# Create work library
vlib work

# Compile all files with smart DataMem handling
echo "Compiling all SystemVerilog files..."

# Build list of *.sv files
set sv_files [glob -nocomplain *.sv]

# Detect DataMem variants
set has_dm   [expr {[lsearch -exact $sv_files "DataMem.sv"] >= 0}]
set has_dmc  [expr {[lsearch -exact $sv_files "DataMem_corrected.sv"] >= 0}]

# Remove BOTH from the main list so they won't be compiled twice
set sv_files [lsearch -all -inline -not -exact $sv_files "DataMem.sv"]
set sv_files [lsearch -all -inline -not -exact $sv_files "DataMem_corrected.sv"]

# Compile everything except DataMem*
vlog -sv +acc=rn -quiet {*}$sv_files

# Compile exactly one DataMem
if {$has_dmc} {
    echo "Using DataMem_corrected.sv (only)"
    vlog -sv +acc=rn -quiet DataMem_corrected.sv
} elseif {$has_dm} {
    echo "Using DataMem.sv"
    vlog -sv +acc=rn -quiet DataMem.sv
} else {
    echo "ERROR: No DataMem.sv found"
    quit -f
}

# Run individual program scripts
do run_prog1.do
do run_prog2.do
do run_prog3.do
do run_prog4.do

# Final summary
echo "\n=========================================="
echo "All program scripts completed."
echo "=========================================="
