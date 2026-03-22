// ============================================================================
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: InstrMem.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: instruction memory, fetch, $readmemh, program load.
//  PURPOSE: Word-addressed instruction memory for the IF stage with program loading
//  PURPOSE: and safe out-of-range behavior for simulation.
// ============================================================================

module InstrMem
#(
    parameter string myPROGRAM      = "prog1.txt",
    parameter int    DEPTH_WORDS    = 1024,
    parameter logic [31:0] NOP_INSTR= 32'h0000_0000,

    // If 0: out-of-range => output NOP
    // If 1: out-of-range => wrap to address 0 (pc_word = 0)
    parameter bit    WRAP_ON_OOR    = 0,

    // Debug printing
    parameter bit    DEBUG          = 1,
    parameter int    PRINT_EVERY    = 50
)
(
    input  logic [31:0] pc,
    output logic [31:0] instr

`ifdef INSTRMEM_DEBUG_CLOCKED
  , input  logic        clock
  , input  logic        reset_n
`endif
);

    logic [31:0] ram [0:DEPTH_WORDS-1];
    logic [31:0] pc_word;

`ifdef INSTRMEM_DEBUG_CLOCKED
    int fetch_count;
    bit oor_reported;
`endif

    // Init RAM + load program
    initial begin
        integer i;

`ifdef INSTRMEM_DEBUG_CLOCKED
        fetch_count  = 0;
        oor_reported = 0;
`endif

        if (DEBUG) $display("InstrMem: Loading program file = %s", myPROGRAM);

        for (i = 0; i < DEPTH_WORDS; i = i + 1)
            ram[i] = NOP_INSTR;

        $readmemh(myPROGRAM, ram);

        if (DEBUG) begin
            $display("InstrMem: ram[0]=%h ram[1]=%h ram[2]=%h ram[3]=%h",
                     ram[0], ram[1], ram[2], ram[3]);
        end
    end

    // Combinational read
    always_comb begin
        pc_word = pc >> 2;

        if (pc_word < DEPTH_WORDS) begin
            instr = ram[pc_word];
        end
        else begin
            if (WRAP_ON_OOR)
                instr = ram[0];
            else
                instr = NOP_INSTR;
        end
    end

`ifdef INSTRMEM_DEBUG_CLOCKED
    // Clocked debug prints: clean, deterministic
    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            fetch_count  <= 0;
            oor_reported <= 0;
        end
        else if (DEBUG) begin
            fetch_count <= fetch_count + 1;

            if ((fetch_count % PRINT_EVERY) == 0) begin
                $display("InstrMem: PC=%h (word=%0d) -> instr=%h", pc, pc_word, instr);
            end

            if ((pc_word >= DEPTH_WORDS) && (!oor_reported)) begin
                oor_reported <= 1;
                $display("InstrMem WARNING: PC out of range! PC=%h (word=%0d) DEPTH=%0d Behavior=%s",
                         pc, pc_word, DEPTH_WORDS,
                         (WRAP_ON_OOR ? "WRAP_TO_0" : "NOP"));
            end
        end
    end
`endif

endmodule
// ============================================================================
