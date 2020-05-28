module cmd_decoder(

    // input
    code,

    // registers
    r0,r1,r2,r3,
    r4,r5,r6,r7,
    r8,r9,ra,rb,
    rc,rd,re,rf,
    cpsr,spsr,

    // output
    instruction_valid,
    ALU_en,mul_en,
    ALU_operation,mul_mode,
    rd_en,rd2_en,
    rd_id,rd2_id,
    psr_wr_cond_en,
    op1,op2,ops_l,ops_h,c_out,
    iset_switch,
    AHB_wr_en,AHB_rd_en,
    AHB_size,AHB_ldr_p,AHB_ldrs_s,
    swi,undefined_command,
    branch

);

input   [31: 0] code;

input   [31: 0] r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,ra,rb,rc,rd,re,rf,cpsr,spsr;

output          instruction_valid;
output          ALU_en,mul_en;
output  [ 3: 0] ALU_operation;
output  [ 1: 0] mul_mode;
output          rd_en,rd2_en;
output  [ 4: 0] rd_id,rd2_id;
output  [ 3: 0] psr_wr_cond_en;
output  [31: 0] op1,op2,ops_l,ops_h,c_out;
output          iset_switch;
output          AHB_wr_en,AHB_rd_en;
output  [ 1: 0] AHB_size;
output          AHB_ldr_p,AHB_ldrs_s;
output          swi,undefined_command;
output          branch;

wire    [31: 0] code_arm    =   cpsr[5] ? 31'h0 : code;
wire    [31: 0] r0_arm      =   cpsr[5] ? 31'h0 : r0;
wire    [31: 0] r1_arm      =   cpsr[5] ? 31'h0 : r1;
wire    [31: 0] r2_arm      =   cpsr[5] ? 31'h0 : r2;
wire    [31: 0] r3_arm      =   cpsr[5] ? 31'h0 : r3;
wire    [31: 0] r4_arm      =   cpsr[5] ? 31'h0 : r4;
wire    [31: 0] r5_arm      =   cpsr[5] ? 31'h0 : r5;
wire    [31: 0] r6_arm      =   cpsr[5] ? 31'h0 : r6;
wire    [31: 0] r7_arm      =   cpsr[5] ? 31'h0 : r7;
wire    [31: 0] r8_arm      =   cpsr[5] ? 31'h0 : r8;
wire    [31: 0] r9_arm      =   cpsr[5] ? 31'h0 : r9;
wire    [31: 0] r10_arm     =   cpsr[5] ? 31'h0 : r10;
wire    [31: 0] r11_arm     =   cpsr[5] ? 31'h0 : r11;
wire    [31: 0] r12_arm     =   cpsr[5] ? 31'h0 : r12;
wire    [31: 0] r13_arm     =   cpsr[5] ? 31'h0 : r13;
wire    [31: 0] r14_arm     =   cpsr[5] ? 31'h0 : r14;
wire    [31: 0] r15_arm     =   cpsr[5] ? 31'h0 : r15;
wire    [31: 0] cpsr_arm    =   cpsr[5] ? 31'h0 : cpsr;
wire    [31: 0] spsr_arm    =   cpsr[5] ? 31'h0 : spsr;

wire    [31: 0] code_thumb  =   cpsr[5] ? code  : 31'h0 ;
wire    [31: 0] r0_thumb    =   cpsr[5] ? r0    : 31'h0 ;
wire    [31: 0] r1_thumb    =   cpsr[5] ? r1    : 31'h0 ;
wire    [31: 0] r2_thumb    =   cpsr[5] ? r2    : 31'h0 ;
wire    [31: 0] r3_thumb    =   cpsr[5] ? r3    : 31'h0 ;
wire    [31: 0] r4_thumb    =   cpsr[5] ? r4    : 31'h0 ;
wire    [31: 0] r5_thumb    =   cpsr[5] ? r5    : 31'h0 ;
wire    [31: 0] r6_thumb    =   cpsr[5] ? r6    : 31'h0 ;
wire    [31: 0] r7_thumb    =   cpsr[5] ? r7    : 31'h0 ;
wire    [31: 0] r8_thumb    =   cpsr[5] ? r8    : 31'h0 ;
wire    [31: 0] r9_thumb    =   cpsr[5] ? r9    : 31'h0 ;
wire    [31: 0] r10_thumb   =   cpsr[5] ? r10   : 31'h0 ;
wire    [31: 0] r11_thumb   =   cpsr[5] ? r11   : 31'h0 ;
wire    [31: 0] r12_thumb   =   cpsr[5] ? r12   : 31'h0 ;
wire    [31: 0] r13_thumb   =   cpsr[5] ? r13   : 31'h0 ;
wire    [31: 0] r14_thumb   =   cpsr[5] ? r14   : 31'h0 ;
wire    [31: 0] r15_thumb   =   cpsr[5] ? r15   : 31'h0 ;
wire    [31: 0] cpsr_thumb  =   cpsr[5] ? cpsr  : 31'h0 ;
wire    [31: 0] spsr_thumb  =   cpsr[5] ? spsr  : 31'h0 ;

wire            instruction_valid_arm;
wire            ALU_en_arm,mul_en_arm;
wire    [ 3: 0] ALU_operation_arm;
wire    [ 1: 0] mul_mode_arm;
wire            rd_en_arm,rd2_en_arm;
wire    [ 4: 0] rd_id_arm,rd2_id_arm;
wire    [ 3: 0] psr_wr_cond_en_arm;
wire    [31: 0] op1_arm,op2_arm,ops_l_arm,ops_h_arm,c_out_arm;
wire            iset_switch_arm;
wire            AHB_wr_en_arm,AHB_rd_en_arm;
wire    [ 1: 0] AHB_size_arm;
wire            AHB_ldr_p_arm,AHB_ldrs_s_arm;
wire            swi_arm,undefined_command_arm;
wire            branch_arm;

wire            instruction_valid_thumb;
wire            ALU_en_thumb, mul_en_thumb;
wire    [ 3: 0] ALU_operation_thumb;
wire    [ 1: 0] mul_mode_thumb;
wire            rd_en_thumb, rd2_en_thumb;
wire    [ 4: 0] rd_id_thumb, rd2_id_thumb;
wire    [ 3: 0] psr_wr_cond_en_thumb;
wire    [31: 0] op1_thumb, op2_thumb, c_out_thumb;
wire            iset_switch_thumb;
wire            AHB_wr_en_thumb,AHB_rd_en_thumb;
wire    [ 1: 0] AHB_size_thumb;
wire            AHB_ldr_p_thumb,AHB_ldrs_s_thumb;
wire            swi_thumb,undefined_command_thumb;
wire            branch_thumb;

 decoder_arm decoder_arm(
    // input
    .code(code_arm),
    .c_in(c_in_arm),
    .r0(r0_arm),
    .r1(r1_arm),
    .r2(r2_arm),
    .r3(r3_arm),
    .r4(r4_arm),
    .r5(r5_arm),
    .r6(r6_arm),
    .r7(r7_arm),
    .r8(r8_arm),
    .r9(r9_arm),
    .r10(r10_arm),
    .r11(r11_arm),
    .r12(r12_arm),
    .r13(r13_arm),
    .r14(r14_arm),
    .r15(r15_arm),
    .cpsr(cpsr_arm),
    .spsr(spsr_arm),
    // output
    .instruction_valid(instruction_valid_arm),
    .ALU_en(ALU_en_arm),
    .mul_en(mul_en_arm),
    .ALU_operation(ALU_operation_arm),
    .mul_mode(mul_mode_arm),
    .rd_en(rd_en_arm),
    .rd2_en(rd2_en_arm),
    .rd_id(rd_id_arm),
    .rd2_id(rd2_id_arm),
    .psr_wr_cond_en(psr_wr_cond_en_arm),
    .op1(op1_arm),
    .op2(op2_arm),
    .ops_l(ops_l_arm),
    .ops_h(ops_h_arm),
    .c_out(c_out_arm),
    .iset_switch(iset_switch_arm),
    .AHB_wr_en(AHB_wr_en_arm),
    .AHB_rd_en(AHB_rd_en_arm),
    .AHB_size(AHB_size_arm),
    .AHB_ldr_p(AHB_ldr_p_arm),
    .AHB_ldrs_s(AHB_ldrs_s_arm),
    .swi(swi_arm),
    .undefined_command(undefined_command_arm),
    .branch(branch_arm)
);




// MUX of output
always @* begin
if (cpsr[5]) begin
    instruction_valid   =   instruction_valid_thumb;
    ALU_en              =   ALU_en_thumb;
    mul_en              =   mul_en_thumb;
    ALU_operation       =   ALU_operation_thumb;
    mul_mode            =   2'b00;
    rd_en               =   rd_en_thumb;
    rd2_en              =   rd2_en_thumb;
    rd_id               =   rd_id_thumb;
    rd2_id              =   rd2_id_thumb;
    psr_wr_cond_en      =   psr_wr_cond_en_thumb;
    op1                 =   op1_thumb;
    op2                 =   op2_thumb;
    ops_l               =   32'h0;
    ops_h               =   32'h0;
    c_out               =   c_out_thumb;
    iset_switch         =   iset_switch_thumb;
    AHB_wr_en           =   AHB_wr_en_thumb;
    AHB_rd_en           =   AHB_rd_en_thumb;
    AHB_size            =   AHB_size_thumb;
    AHB_ldr_p           =   AHB_ldr_p_thumb;
    AHB_ldrs_s          =   AHB_ldrs_s_thumb;
    swi                 =   swi_thumb;
    undefined_command   =   undefined_command_thumb;
    branch              =   branch_thumb;
end else begin
    instruction_valid   =   instruction_valid_arm;
    ALU_en              =   ALU_en_arm;
    mul_en              =   mul_en_arm;
    ALU_operation       =   ALU_operation_arm;
    mul_mode            =   mul_mode_arm;
    rd_en               =   rd_en_arm;
    rd2_en              =   rd2_en_arm;
    rd_id               =   rd_id_arm;
    rd2_id              =   rd2_id_arm;
    psr_wr_cond_en      =   psr_wr_cond_en_arm;
    op1                 =   op1_arm;
    op2                 =   op2_arm;
    ops_l               =   ops_l_arm;
    ops_h               =   ops_h_arm;
    c_out               =   c_out_arm;
    iset_switch         =   iset_switch_arm;
    AHB_wr_en           =   AHB_wr_en_arm;
    AHB_rd_en           =   AHB_rd_en_arm;
    AHB_size            =   AHB_size_arm;
    AHB_ldr_p           =   AHB_ldr_p_arm;
    AHB_ldrs_s          =   AHB_ldrs_s_arm;
    swi                 =   swi_arm;
    undefined_command   =   undefined_command_arm;
    branch              =   branch_arm;
end
end



endmodule