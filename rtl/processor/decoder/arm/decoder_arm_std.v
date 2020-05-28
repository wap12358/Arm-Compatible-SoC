module decoder_arm_std(
    // 输入接口 来自arm译码
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

    rd_in, rn, rm, rs,

    b_offset,
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

    // 来自op2_shifter
    op2_in,

    // 寄存器接口
    r0, r1, r2, r3,
    r4, r5, r6, r7,
    r8, r9, ra, rb,
    rc, rd, re, rf,
    cpsr, spsr,


    // 输出接口，标准内核操作
    instruction_valid,
    ALU_en, ALU_operation,
    mul_en, mul_mode,
    rd_en, rd_id, 
    rd2_en, rd2_id,
    psr_wr_cond_en,
    op1, op2, ops_l, ops_h,
    iset_switch, 
    AHB_wr_en, AHB_rd_en, AHB_size,
    AHB_ldr_p, AHB_ldrs_s,
    swi, undefined_command,
    branch

);

// 来自指令译码
input   [ 3: 0] cond;

input           cmd_bx;
input           cmd_b;
input           cmd_bl;
input           cmd_dp;
input           cmd_mrs;
input           cmd_msr;
input           cmd_msr_flag_only;
input           cmd_mul;
input           cmd_mull;
input           cmd_ldr;
input           cmd_ldrh;
input           cmd_ldrsb;
input           cmd_ldrsh;
input           cmd_ldm;
input           cmd_swp;
input           cmd_swi;
input           cmd_cdp;
input           cmd_ldc;
input           cmd_mrc;
input           cmd_undefine;

input   [ 3: 0] rd_in, rn, rm, rs;

input   [ 3: 0] b_offset;
input   [ 3: 0] dp_opcode;
input           dp_s;
input           mrs_sel;
input           mul_a;
input           mull_u;
input   [11: 0] ldr_offset;
input           ldr_p;
input           ldr_u;
input           ldr_b;
input           ldr_w;
input           ldr_l;

// 来自op2_shifter
input   [31: 0]  op2_in;

// 寄存器接口
input   [31: 0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, ra, rb, rc, rd, re, rf, cpsr, spsr;

// 输出标准内核操作
output reg              instruction_valid;
output reg              ALU_en, mul_en;
output reg   [ 3: 0]    ALU_operation;
output reg   [ 1: 0]    mul_mode;
output reg              rd_en, rd2_en;
output reg   [ 4: 0]    rd_id, rd2_id;
output reg   [ 3: 0]    psr_wr_cond_en;
output reg   [31: 0]    op1, op2, ops_l, ops_h;
output                  iset_switch;
output reg              AHB_wr_en, AHB_rd_en;
output reg   [ 1: 0]    AHB_size;
output                  AHB_ldr_p, AHB_ldrs_s;
output reg              swi, undefined_command;
output reg              branch;

// ALU_operation
parameter   OP1 = 4'h0;
parameter   OP2 = 4'h1;
parameter   AND = 4'h2;
parameter   ORR = 4'h3;
parameter   EOR = 4'h4;
parameter   BIC = 4'h5;
parameter   MVN = 4'h6;
parameter   ADD = 4'h8;
parameter   ADC = 4'h9;
parameter   SUB = 4'hc;
parameter   RSB = 4'ha;
parameter   SBC = 4'hd;
parameter   RSC = 4'hb;

parameter   SU  = 2'b00;   // short unsigned 
parameter   LU  = 2'b10;
parameter   LS  = 2'b11;   // long signed

// rd_id
parameter   RD_CPSR     = 5'h10;
parameter   RD_SPSR     = 5'h11;
parameter   RD_CPSR_FO  = 5'h12;  // flag only
parameter   RD_SPSR_FO  = 5'h13;  // flag only
//parameter   RD_AHB_ADDR = 5'h18;


// CPSR condition flag
wire    N = cpsr[31];
wire    Z = cpsr[30];
wire    C = cpsr[29];
wire    V = cpsr[28];


// 操作译码 ********************************************************************************************

// ALU_en
always @* begin
if ( cmd_bx | cmd_b | cmd_bl | cmd_dp | cmd_mrs | cmd_msr | cmd_msr_flag_only | 
    cmd_ldr | cmd_ldrh | cmd_ldrsb | cmd_ldrsh | cmd_swp ) 
    ALU_en = 1'b1;
else
    ALU_en = 1'b0;
end

// mul_en
always @* begin
if ( cmd_mul | cmd_mull ) 
    mul_en = 1'b1;
else
    mul_en = 1'b0;
end

// ALU_operation
always @* begin
if ( cmd_swp ) 
    ALU_operation = OP1;
else if ( (cmd_dp&(dp_opcode==4'h0|dp_opcode==4'h8)) )
    ALU_operation = AND;
else if ( (cmd_dp&(dp_opcode==4'hc)) )
    ALU_operation = ORR;
else if ( (cmd_dp&(dp_opcode==4'h1|dp_opcode==4'h9)) )
    ALU_operation = EOR;
else if ( (cmd_dp&(dp_opcode==4'he)) )
    ALU_operation = BIC;
else if ( (cmd_dp&(dp_opcode==4'hf)) )
    ALU_operation = MVN;
else if ( (cmd_dp&(dp_opcode==4'h4|dp_opcode==4'hb)) | ((cmd_ldr|cmd_ldrh|cmd_ldrsb|cmd_ldrsh)&ldr_u) )
    ALU_operation = ADD;
else if ( (cmd_dp&(dp_opcode==4'h5)) )
    ALU_operation = ADC;
else if ( (cmd_dp&(dp_opcode==4'h2|dp_opcode==4'ha)) | ((cmd_ldr|cmd_ldrh|cmd_ldrsb|cmd_ldrsh)&(~ldr_u)) )
    ALU_operation = SUB;
else if ( (cmd_dp&(dp_opcode==4'h3)) )
    ALU_operation = RSB;
else if ( (cmd_dp&(dp_opcode==4'h6)) )
    ALU_operation = SBC;
else if ( (cmd_dp&(dp_opcode==4'h7)) )
    ALU_operation = RSC;
else
    ALU_operation = OP2;
end

// mul_mode
always @* begin
if ( cmd_mull & (~mull_u) )
    mul_mode = LU;
else if ( cmd_mull & mull_u )
    mul_mode = LS;
else // if ( cmd_mul )
    mul_mode = SU;
end


// rd_en & rd_id
always @* begin
if ( cmd_bx | cmd_b | cmd_bl | ( cmd_dp & ( dp_opcode[3:2] != 2'b10 ) ) | cmd_mrs | cmd_msr | cmd_msr_flag_only | cmd_mul | cmd_mull | 
    ((cmd_ldr | cmd_ldrh | cmd_ldrsb | cmd_ldrsh)&ldr_b) | cmd_swp )
    rd_en = 1'b1;
else 
    rd_en = 1'b0;
end
always @* begin
if ( cmd_dp | cmd_mrs | cmd_mull | cmd_swp )
    rd_id = { 1'b0, rd_in };
else if ( cmd_mul | ((cmd_ldr | cmd_ldrh | cmd_ldrsb | cmd_ldrsh)&ldr_b) )
    rd_id = { 1'b0, rn }; 
else if ( cmd_bx | cmd_b | cmd_bl )
    rd_id = 5'h0f;
else if ( cmd_msr )
    rd_id = mrs_sel ? RD_SPSR : RD_CPSR;
else if ( cmd_msr_flag_only )
    rd_id = mrs_sel ? RD_SPSR_FO : RD_CPSR_FO;
else
    rd_id = 5'h0;
end


// rd2_en & rd2_id
always @* begin
if ( cmd_mull | cmd_ldr | cmd_ldrh | cmd_ldrsb | cmd_ldrsh | cmd_swp )
    rd2_en = 1'b1;
else 
    rd2_en = 1'b0;
end
always @* begin
if ( cmd_mull )
    rd2_id = { 1'b0, rn };
else if ( cmd_ldr | cmd_ldrh | cmd_ldrsb | cmd_ldrsh )
    rd2_id = { 1'b0, rd_in };
else if ( cmd_swp )
    rd2_id = { 1'b0, rm };
else
    rd2_id = 5'h0;
end


// psr_wr_cond_en
always @* begin
if ( cmd_dp & dp_s )
    psr_wr_cond_en = 4'b1111;
else if ( (cmd_mul|cmd_mull) & dp_s )
    psr_wr_cond_en = 4'b1100;
else 
    psr_wr_cond_en = 4'b0000;
end


// op1
always @* begin
if ( cmd_dp | cmd_mul | cmd_mull | cmd_ldr | cmd_ldrh | cmd_ldrsb | cmd_ldrsh | cmd_swp )
    case ((cmd_mull|cmd_mul)?rs:rn)
    4'h0: op1 = r0;
    4'h1: op1 = r1;
    4'h2: op1 = r2;
    4'h3: op1 = r3;
    4'h4: op1 = r4;
    4'h5: op1 = r5;
    4'h6: op1 = r6;
    4'h7: op1 = r7;
    4'h8: op1 = r8;
    4'h9: op1 = r9;
    4'ha: op1 = ra;
    4'hb: op1 = rb;
    4'hc: op1 = rc;
    4'hd: op1 = rd;
    4'he: op1 = re;
    4'hf: op1 = rf;
    default: op1 = 32'h0;
    endcase
else 
    op1 = 32'h0;
end


// op2
always @* begin
if ( cmd_bx | cmd_msr | cmd_mul | cmd_mull | cmd_ldrh | cmd_ldrsb | cmd_ldrsh )
    case (rm)
    4'h0: op2 = r0;
    4'h1: op2 = r1;
    4'h2: op2 = r2;
    4'h3: op2 = r3;
    4'h4: op2 = r4;
    4'h5: op2 = r5;
    4'h6: op2 = r6;
    4'h7: op2 = r7;
    4'h8: op2 = r8;
    4'h9: op2 = r9;
    4'ha: op2 = ra;
    4'hb: op2 = rb;
    4'hc: op2 = rc;
    4'hd: op2 = rd;
    4'he: op2 = re;
    4'hf: op2 = rf;
    default: op2 = 32'h0;
    endcase
else if ( cmd_b | cmd_bl )
    op2 = { 8'h00, b_offset };
else if ( cmd_dp | cmd_msr_flag_only | cmd_ldr )
    op2 = op2_in;
else if ( cmd_mrs )
    op2 = mrs_sel ? spsr : cpsr;
else 
    op2 = 32'h0;
end


// ops
always @* begin
if ( (cmd_mul|cmd_mull) & mul_a )
    case (rd_in)
    4'h0: ops_l = r0;
    4'h1: ops_l = r1;
    4'h2: ops_l = r2;
    4'h3: ops_l = r3;
    4'h4: ops_l = r4;
    4'h5: ops_l = r5;
    4'h6: ops_l = r6;
    4'h7: ops_l = r7;
    4'h8: ops_l = r8;
    4'h9: ops_l = r9;
    4'ha: ops_l = ra;
    4'hb: ops_l = rb;
    4'hc: ops_l = rc;
    4'hd: ops_l = rd;
    4'he: ops_l = re;
    4'hf: ops_l = rf;
    default: ops_l = 32'h0;
    endcase
else 
    ops_l = 32'h0;
end
always @* begin
if ( cmd_mull & mul_a )
    case (rn)
    4'h0: ops_h = r0;
    4'h1: ops_h = r1;
    4'h2: ops_h = r2;
    4'h3: ops_h = r3;
    4'h4: ops_h = r4;
    4'h5: ops_h = r5;
    4'h6: ops_h = r6;
    4'h7: ops_h = r7;
    4'h8: ops_h = r8;
    4'h9: ops_h = r9;
    4'ha: ops_h = ra;
    4'hb: ops_h = rb;
    4'hc: ops_h = rc;
    4'hd: ops_h = rd;
    4'he: ops_h = re;
    4'hf: ops_h = rf;
    default: ops_h = 32'h0;
    endcase
else 
    ops_h = 32'h0;
end

assign  iset_switch = cmd_bx;

// AHB
always @* begin
if ( ((cmd_ldr|cmd_ldrh|cmd_ldrsb|cmd_ldrsh)&(~ldr_l)) | cmd_swp )
    AHB_wr_en = 1'b1;
else 
    AHB_wr_en = 1'b0;
end
always @* begin
if ( ((cmd_ldr|cmd_ldrh|cmd_ldrsb|cmd_ldrsh)&ldr_l) | cmd_swp )
    AHB_rd_en = 1'b1;
else 
    AHB_rd_en = 1'b0;
end
always @* begin
if ( ((cmd_ldr|cmd_swp)&ldr_b) | cmd_ldrsb  )
    AHB_size = 2'b11;
else if ( cmd_ldrh | cmd_ldrsh )
    AHB_size = 2'b10;
else
    AHB_size = 2'b00;
end
assign AHB_ldr_p    = ( cmd_ldr | cmd_ldrh | cmd_ldrsh | cmd_ldrsb ) & ldr_p;
assign AHB_ldrs_s   = cmd_ldrsh | cmd_ldrsb;

// interrupt
always @* begin
if ( cmd_swi )
    swi = 1'b1;
else 
    swi = 1'b0;
end
always @* begin
if ( ( cond == 4'hf ) | cmd_bx | cmd_b | cmd_bl | cmd_dp | cmd_mrs | cmd_msr | cmd_msr_flag_only | cmd_mul | cmd_mull | cmd_ldr | cmd_ldrh | cmd_ldrsb | cmd_ldrsh | cmd_swp | cmd_swi )
    undefined_command = 1'b0;
else 
    undefined_command = 1'b1;
end

// branch ( 放弃流水线上的指令 )
always @* begin
if ( instruction_valid & ( cmd_bx | cmd_b | cmd_bl ) ) begin
    branch = 1'b1;
end else begin
    branch = 1'b0;
end
end

// conditions & instruction_valid
always @* begin
case ( cond )
4'h0: instruction_valid = Z;
4'h1: instruction_valid = ~Z;
4'h2: instruction_valid = C;
4'h3: instruction_valid = ~C;
4'h4: instruction_valid = N;
4'h5: instruction_valid = ~N;
4'h6: instruction_valid = V;
4'h7: instruction_valid = ~V;
4'h8: instruction_valid = C & (~Z);
4'h9: instruction_valid = (~C) | Z;
4'ha: instruction_valid = N == V;
4'hb: instruction_valid = N ^ V;
4'hc: instruction_valid = (~Z) & ( N == V );
4'hd: instruction_valid = Z | ( N ^ V );
4'he: instruction_valid = 1'b1;
default: instruction_valid = 1'b0;
endcase
end


endmodule 