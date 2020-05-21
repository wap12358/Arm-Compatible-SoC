module decoder_arm(
    // input
    code,
    c_in,
    r0, r1, r2, r3,
    r4, r5, r6, r7,
    r8, r9, r10, r11,
    r12, r13, r14, r15,
    cpsr, spsr, 
    // output
    instruction_valid,
    ALU_en, mul_en,
    ALU_operation,
    mul_mode,
    rd_en, rd2_en,
    rd_id, rd2_id,
    psr_wr_cond_en,
    op1, op2, ops_l, ops_h, c_out,
    iset_switch,
    AHB_wr_en, AHB_rd_en,
    AHB_size,
    AHB_ldr_p, AHB_ldrs_s,
    swi, undefined_command
);

input   [31: 0] code;

input           c_in;
input   [31: 0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, cpsr, spsr;


output          instruction_valid;
output          ALU_en, mul_en;
output  [ 3: 0] ALU_operation;
output  [ 2: 0] mul_mode;
output          rd_en, rd2_en;
output  [ 4: 0] rd_id, rd2_id;
output          psr_wr_cond_en;
output  [31: 0] op1, op2, ops_l, ops_h;
output          c_out;
output          iset_switch;
output          AHB_wr_en, AHB_rd_en;
output  [ 1: 0] AHB_size;
output          AHB_ldr_p, AHB_ldrs_s;
output          swi, undefined_command;

wire    [ 3: 0] cond;
wire            cmd_bx;
wire            cmd_b;
wire            cmd_bl;
wire            cmd_dp;
wire            cmd_mrs;
wire            cmd_msr;
wire            cmd_msr_flag_only;
wire            cmd_mul;
wire            cmd_mull;
wire            cmd_ldr;
wire            cmd_ldrh;
wire            cmd_ldrsb;
wire            cmd_ldrsh;
wire            cmd_ldm;
wire            cmd_swp;
wire            cmd_swi;
wire            cmd_cdp;
wire            cmd_ldc;
wire            cmd_mrc;
wire            cmd_undefine;
wire    [ 3: 0] rd, rn, rm, rs;
wire    [ 3: 0] b_offset;
wire    [ 3: 0] dp_opcode;
wire    [12: 0] op2_before;
wire            dp_s;
wire            mrs_sel;
wire            mul_a;
wire            mull_u;
wire    [11: 0] ldr_offset;
wire            ldr_p;
wire            ldr_u;
wire            ldr_b;
wire            ldr_w;
wire            ldr_l;

wire    [31: 0] op2_after;


decoder_cmd_arm decoder_cmd_arm(
    .code(code),
    .cond(cond),
    .cmd_bx(cmd_bx),
    .cmd_b(cmd_b),
    .cmd_bl(cmd_bl),
    .cmd_dp(cmd_dp),
    .cmd_mrs(cmd_mrs),
    .cmd_msr(cmd_msr),
    .cmd_msr_flag_only(cmd_msr_flag_only),
    .cmd_mul(cmd_mul),
    .cmd_mull(cmd_mull),
    .cmd_ldr(cmd_ldr),
    .cmd_ldrh(cmd_ldrh),
    .cmd_ldrsb(cmd_ldrsb),
    .cmd_ldrsh(cmd_ldrsh),
    .cmd_ldm(cmd_ldm),
    .cmd_swp(cmd_swp),
    .cmd_swi(cmd_swi),
    .cmd_cdp(cmd_cdp),
    .cmd_ldc(cmd_ldc),
    .cmd_mrc(cmd_mrc),
    .cmd_undefine(cmd_undefine),
    .rd(rd),
    .rn(rn),
    .rm(rm),
    .rs(rs),
    .b_offset(b_offset),
    .dp_opcode(dp_opcode),
    .dp_op2(op2_before),
    .dp_s(dp_s),
    .mrs_sel(mrs_sel),
    .mul_a(mul_a),
    .mull_u(mull_u),
    .ldr_offset(ldr_offset),
    .ldr_p(ldr_p),
    .ldr_u(ldr_u),
    .ldr_b(ldr_b),
    .ldr_w(ldr_w),
    .ldr_l(ldr_l)

);


op2_shifter op2_shifter(
    .op2_before(op2_before),
    .op2_after(op2_after),
    .c_in(c_in),
    .c_out(c_out),
    .r0(r0), .r1(r1), .r2(r2), .r3(r3),
    .r4(r4), .r5(r5), .r6(r6), .r7(r7),
    .r8(r8), .r9(r9), .ra(r10), .rb(r11),
    .rc(r12), .rd(r13), .re(r14), .rf(r15)
);

decoder_arm_std decoder_arm_std(
    // 输入接口 来自arm译码
    .cond(cond),
    .cmd_bx(cmd_bx),
    .cmd_b(cmd_b),
    .cmd_bl(cmd_bl),
    .cmd_dp(cmd_dp),
    .cmd_mrs(cmd_mrs),
    .cmd_msr(cmd_msr),
    .cmd_msr_flag_only(cmd_msr_flag_only),
    .cmd_mul(cmd_mul),
    .cmd_mull(cmd_mull),
    .cmd_ldr(cmd_ldr),
    .cmd_ldrh(cmd_ldrh),
    .cmd_ldrsb(cmd_ldrsb),
    .cmd_ldrsh(cmd_ldrsh),
    .cmd_ldm(cmd_ldm),
    .cmd_swp(cmd_swp),
    .cmd_swi(cmd_swi),
    .cmd_cdp(cmd_cdp),
    .cmd_ldc(cmd_ldc),
    .cmd_mrc(cmd_mrc),
    .cmd_undefine(cmd_undefine),
    .rd_in(rd),
    .rn(rn),
    .rm(rm),
    .rs(rs),
    .b_offset(b_offset),
    .dp_opcode(dp_opcode),
    .dp_s(dp_s),
    .mrs_sel(mrs_sel),
    .mul_a(mul_a),
    .mull_u(mull_u),
    .ldr_offset(ldr_offset),
    .ldr_p(ldr_p),
    .ldr_u(ldr_u),
    .ldr_b(ldr_b),
    .ldr_w(ldr_w),
    .ldr_l(ldr_l), 

    // 来自op2_shifter
    .op2_in(op2_before),

    // 寄存器接口
    .r0(r0), .r1(r1), .r2(r2), .r3(r3),
    .r4(r4), .r5(r5), .r6(r6), .r7(r7),
    .r8(r8), .r9(r9), .ra(r10), .rb(r11),
    .rc(r12), .rd(r13), .re(r14), .rf(r15),
    .cpsr(cpsr), .spsr(spsr),


    // 输出接口，标准内核操作
    .instruction_valid(instruction_valid),
    .ALU_en(ALU_en),
    .ALU_operation(ALU_operation),
    .mul_en(mul_en),
    .mul_mode(mul_mode),
    .rd_en(rd_en),
    .rd_id(rd_id),
    .rd2_en(rd2_en),
    .rd2_id(rd2_id),
    .psr_wr_cond_en(psr_wr_cond_en),
    .op1(op1),
    .op2(op2),
    .ops_l(ops_l),
    .ops_h(ops_h),
    .iset_switch(iset_switch),
    .AHB_wr_en(AHB_wr_en),
    .AHB_rd_en(AHB_rd_en),
    .AHB_size(AHB_size),
    .AHB_ldr_p(AHB_ldr_p),
    .AHB_ldrs_s(AHB_ldrs_s),
    .swi(swi),
    .undefined_command(undefined_command)

);





endmodule