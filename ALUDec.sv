// ============================================================================
//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: ALUDec.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: ALU decode, funct, alu_op, control.
//  PURPOSE: Decodes opcode/funct ALU control for the pipelined MIPS execute stage.
// ============================================================================

module ALUDec 
//-----------------Ports-----------------\\
(
    input  logic [5:0] funct,
    input  logic [1:0] alu_op,

    output logic  [2:0] alu_control
);

//-----------------ALUOp encoding-----------------\\
localparam  ADDOP    = 2'b00,
            SUBOP    = 2'b01,
            FUNCTOP  = 2'b10;

//-----------------Funct encoding-----------------\\
localparam  ADDFUN  = 6'b100000, // 0x20
            SUBFUN  = 6'b100010, // 0x22
            ANDFUN  = 6'b100100, // 0x24
            ORFUN   = 6'b100101, // 0x25
            SLTFUN  = 6'b101010, // 0x2A
            MULFUN  = 6'b011100; // 0x1C (mul)

//-----------------Output encoding-----------------\\
localparam  AND     = 3'b000,
            OR      = 3'b001,
            ADD     = 3'b010,
            SUB     = 3'b110,
            MUL     = 3'b101,
            SLT     = 3'b111;

//-----------------ALU Decoder logic-----------------\\
always_comb
begin
    // Priority to the alu_op first, then check the funct field.
    if (alu_op == ADDOP)
    begin
        alu_control = ADD;
    end
    else if (alu_op == SUBOP)
    begin
        alu_control = SUB;
    end
    else // FUNCTOP (R-type)
    begin
        case (funct)
            ADDFUN: alu_control = ADD;
            SUBFUN: alu_control = SUB;
            ANDFUN: alu_control = AND;
            ORFUN : alu_control = OR;
            SLTFUN: alu_control = SLT;
            MULFUN: alu_control = MUL;

            default: alu_control = ADD;
        endcase
    end
end

endmodule
