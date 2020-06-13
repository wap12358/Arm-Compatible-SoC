module decoder_code_arm(
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
    dp_opcode,
    dp_op2,
    dp_s,
    mrs_sel,
    mul_a,
    mull_u,
    ldr_offset,
    ldr_p,
    ldr_u,
    ldr_b,
    ldr_w,
    ldr_l

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
output  [ 3: 0] dp_opcode;
output  [12: 0] dp_op2;
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





assign  cond        = code[31:28];

assign  cmd_bx      = ( code[27: 4] == 24'h12fff1 );
assign  cmd_b       = ( code[27:24] ==  4'b1010 );
assign  cmd_bl      = ( code[27:24] ==  4'b1011 );
assign  cmd_dp      = ( code[27:26] ==  2'b00 );
assign  cmd_mrs     = ( ( code[27:23] ==  5'b00010 ) & ( code[21:16] ==  6'b001111 ) & ( code[11:0] ==  12'h000 ) );
assign  cmd_msr     = ( ( code[27:23] ==  5'b00010 ) & ( code[21:4] ==  18'h29f00 ) );
assign  cmd_msr_flag_only = ( ( ( code[27:26] ==  2'b00 ) & ( code[24:23] ==  2'b10 ) & ( code[21:12] ==  10'h28f ) ) & ( code[25] | ( code[11:4] == 8'h00 ) ) );
assign  cmd_mul     = ( ( code[27:22] ==  6'h00 ) & ( code[7:4] ==  4'h9 ) );
assign  cmd_mull    = ( ( code[27:23] ==  5'h01 ) & ( code[7:4] ==  4'h9 ) );
assign  cmd_ldr     = ( code[27:26] ==  2'b01 );
assign  cmd_ldrh    = ( ( code[27:25] == 3'h0 ) & ( code[7:4] == 4'hb ) & ( code[22] | ( code[11:8] == 4'h0 ) ) );
assign  cmd_ldrsb   = ( ( code[27:25] == 3'h0 ) & ( code[7:4] == 4'hd ) & ( code[22] | ( code[11:8] == 4'h0 ) ) );
assign  cmd_ldrsh   = ( ( code[27:25] == 3'h0 ) & ( code[7:4] == 4'hf ) & ( code[22] | ( code[11:8] == 4'h0 ) ) );
assign  cmd_ldm     = ( code[27:25] == 3'h4 );
assign  cmd_swp     = ( ( code[27:23] == 5'h2 ) & ( code[21:20] == 2'h0 ) & ( code[11:4] == 8'h09 ) );
assign  cmd_swi     = ( code[27:24] == 4'hf );
assign  cmd_cdp     = ( ( code[27:24] == 4'he ) & ( ~code[4] ) );
assign  cmd_ldc     = ( code[27:25] == 3'h6 );
assign  cmd_mrc     = ( ( code[27:24] == 4'he ) & code[4] );
assign  cmd_undefine= ( ( code[27:25] == 3'h3 ) & code[4] );


assign  rd  = code[15:12];
assign  rn  = code[19:16];
assign  rm  = code[ 3: 0];
assign  rs  = code[11: 8];

assign  b_offset    = code[23: 0];
assign  dp_opcode   = code[24:21];
assign  dp_op2      = { code[25], code[11: 0] };
assign  dp_s        = code[20];
assign  mrs_sel     = code[22];
assign  mul_a       = code[21];
assign  mull_u      = code[22];
assign  ldr_offset  = code[11:0];
assign  ldr_p       = code[24];
assign  ldr_u       = code[23];
assign  ldr_b       = code[22];
assign  ldr_w       = code[21];
assign  ldr_l       = code[20];




endmodule