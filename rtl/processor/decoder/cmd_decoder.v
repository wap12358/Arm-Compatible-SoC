module cmd_decoder(
    code,
    cond,
    cmd_bx,
    cmd_b,
    cmd_bl,
    cmd_dp,
    cmd_mrs,
    cmd_msr,
    cmd_msr_flag_only,
    cmd_mul,
    cmd_mull,
    cmd_ldr,
    cmd_ldrh,
    cmd_ldrsb,
    cmd_ldrsh,
    cmd_ldm,
    cmd_swp,
    cmd_swi,
    cmd_cdp,
    cmd_ldc,
    cmd_mrc,
    cmd_undefine,

    rd, rn, rm, rs,

    b_offset,
    b_l,
    dp_opcode,
    dp_s,
    mrs_sel,
    mul_a,
    mull_u,
    ldr_offset,
    ldr_p,
    ldr_u,
    ldr_b,
    ldr_w,
    ldr_l,
    ldrh_offset_sel,
    ldrh_offset
    
    op2_after,
    c_in,
    c_out,
    r0, r1, r2, r3,
    r4, r5, r6, r7,
    r8, r9, ra, rb,
    rc, rd, re, rf
);

input   [31: 0] code;

output  [ 3: 0] cond;

output  cmd_bx;
output  cmd_b;
output  cmd_bl;
output  cmd_dp;
output  cmd_mrs;
output  cmd_msr;
output  cmd_msr_flag_only;
output  cmd_mul;
output  cmd_mull;
output  cmd_ldr;
output  cmd_ldrh;
output  cmd_ldrsb;
output  cmd_ldrsh;
output  cmd_ldm;
output  cmd_swp;
output  cmd_swi;
output  cmd_cdp;
output  cmd_ldc;
output  cmd_mrc;
output  cmd_undefine;


output  [ 3: 0] rd, rn, rm, rs;



output  [ 3: 0] b_offset;
output          b_l;
output  [ 3: 0] dp_opcode;
output          dp_s;
output          mrs_sel;
output          mul_a;
output          mull_u;
output  [11: 0] ldr_offset;
output          ldr_p;
output          ldr_u;
output          ldr_b;
output          ldr_w;
output          ldr_l;
output          ldrh_offset_sel;
output  [ 7: 0] ldrh_offset;


wire        [12: 0] op2_before;
output reg  [31: 0] op2_after;

input           c_in;
output reg      c_out;

input   [31:0]  r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, ra, rb, rc, rd, re, rf;



cmd_decoder_arm cmd_decoder_arm(
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
    .b_l(b_l),
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
    .ldr_l(ldr_l),
    .ldrh_offset_sel(ldrh_offset_sel),
    .ldrh_offset(ldrh_offset)
);


op2_shifter op2_shifter(
    .op2_before(op2_before),
    op2_after,
    c_in,
    c_out,
    r0, r1, r2, r3,
    r4, r5, r6, r7,
    r8, r9, ra, rb,
    rc, rd, re, rf
);




endmodule