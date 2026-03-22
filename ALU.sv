// ============================================================================
//  AUTHOR: Mohamed Maged Elkholy.
//  INFO.: Undergraduate ECE student, Alexandria university, Egypt.
//  AUTHOR'S EMAIL: majiidd17@icloud.com
//  ORIGINAL BASELINE CREDIT: Mohamed Maged Elkholy (Alexandria University, Egypt)
//  NOTE: Initial single-cycle MIPS baseline was used only as a starting reference.
//  MODIFICATION CREDIT: This version was independently extended and transformed into a 5-stage pipelined MIPS by Niv Toren and Ryan Lifshitz.
//  MODIFIED BY: Niv Toren and Ryan Lifshitz
//  FILE NAME: ALU.sv
//  TYPE: module.
//  DATE: 05/02/2026
//  KEYWORDS: ALU, execute stage, arithmetic, logic.
//  PURPOSE: Arithmetic/logic unit used in the EX stage of the pipelined MIPS datapath.
// ============================================================================

module ALU
#(
    parameter WIDTH = 32
)
(
    input  logic                 reset_n,
    input  logic [(WIDTH-1) : 0] src_a,
    input  logic [(WIDTH-1) : 0] src_b,
    input  logic [2:0]           alu_control,

    output logic [(WIDTH-1) : 0] alu_result,
    output logic                 zero_flag
);

//-----------------Registers-----------------\\
logic [2:0]              state;
logic [(WIDTH-1) : 0]    cla_out;
logic                    carry_out_unused;

//-----------------Encodings-----------------\\
localparam  AND      = 3'b000,
            OR       = 3'b001,
            ADD      = 3'b010,
            NOTUSED1 = 3'b011,
            NOTUSED2 = 3'b100,
            SUB      = 3'b110,
            SLT      = 3'b111,
            MUL      = 3'b101;

//-----------------ALU Logic-----------------\\
always_comb
begin
    if(!reset_n)
    begin
        alu_result = {WIDTH{1'b0}};
        state      = NOTUSED1;
    end
    else
    begin
        state = alu_control;
        case (state)
            AND:
            begin
                alu_result = src_a & src_b;
            end

            OR:
            begin
                alu_result = src_a | src_b;
            end

            ADD:
            begin
                alu_result = cla_out;
            end

            NOTUSED1:
            begin
                alu_result = {WIDTH{1'b0}};
            end

            SUB:
            begin
                alu_result = src_a - src_b;
            end

            MUL:
            begin
                // mul (low 32 bits) - signed is safer/consistent
                alu_result = $signed(src_a) * $signed(src_b);
            end

            SLT:
            begin
                // CRITICAL FIX: slt is SIGNED comparison in MIPS
                alu_result = ($signed(src_a) < $signed(src_b)) ? {{(WIDTH-1){1'b0}}, 1'b1}
                                                               : {WIDTH{1'b0}};
            end

            NOTUSED2:
            begin
                alu_result = {WIDTH{1'b0}};
            end

            default:
            begin
                alu_result = {WIDTH{1'b0}};
                state      = NOTUSED1;
            end
        endcase
    end
end

//-----------------Zero Flag Logic-----------------\\
assign zero_flag = (alu_result == {WIDTH{1'b0}});

//-----------------Instances-----------------\\
CLA_Adder #(WIDTH) claComp(
    .in_1(src_a),
    .in_2(src_b),
    .carry_in(1'b0),
    .sum(cla_out),
    .carry_out(carry_out_unused)
);

endmodule
