// ============================================================================
//  AUTHOR: Mohamed Maged Elkholy.
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: RegFile.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: register file, writeback, decode, MIPS.
//  PURPOSE: 32x32 register file with two read ports and one write port for the pipeline.
// ============================================================================

module RegFile 
//-----------------Ports-----------------\\
(
    input logic        clock,         //  System clock.
    input logic        write_enable,  //  Write enable.
    input logic [4:0]  addr1,         //  src_a address.
    input logic [4:0]  addr2,         //  src_b address.
    input logic [4:0]  addr3,         //  destination address.
    input logic [31:0] write_data,    //  data to be written.

    output logic [31:0] rd1,           //  src_a data.
    output logic [31:0] rd2            //  src_b data.
);
    //-----------------Register-----------------\\
    reg [31:0] registers [31:0];         //  32 registers, 32-bit wide.

`ifndef SYNTHESIS
    // Simulation-only init to avoid Xs in debug prints.
    initial begin : init_regs
        integer i;
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end
`endif

    //-----------------Write logic-----------------\\
    always @(posedge clock) 
    begin
        // FIX: Added check (addr3 != 0).
        // We never write to register $0, it must remain hardwired to 0.
        if(write_enable && (addr3 != 5'b0))
        begin
            registers[addr3] <= write_data;
        end
        // Removed the redundant "else registers <= registers"
    end

    //-----------------Output-----------------\\
    // Asynchronous Read with simple write-first bypass
    always_comb begin
        if (addr1 == 5'b0)
            rd1 = 32'b0;
        else if (write_enable && (addr3 != 5'b0) && (addr3 == addr1))
            rd1 = write_data;
        else
            rd1 = registers[addr1];

        if (addr2 == 5'b0)
            rd2 = 32'b0;
        else if (write_enable && (addr3 != 5'b0) && (addr3 == addr2))
            rd2 = write_data;
        else
            rd2 = registers[addr2];
    end

endmodule
