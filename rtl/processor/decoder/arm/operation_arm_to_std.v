module operation_arm_to_std(
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
    ldrh_offset,   

    // 来自op2_shifter
    op2_in, c_in,

    // 寄存器接口
    r0, r1, r2, r3,
    r4, r5, r6, r7,
    r8, r9, ra, rb,
    rc, rd, re, rf,
    cpsr, spsr,


    // 输出接口，标准内核操作
    ALU_en, ALU_operation,
    mul_en, mul_mode,
    rd_en, rd_id, 
    rd2_en, rd2_id,
    psr_wr_en,
    op1, op2, ops, c_out,
    iset_switch, 
    AHB_wr_en, AHB_rd_en, AHB_size,
    SWI, undefined_command


);

// 来自指令译码
input   [31: 0] code;

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
input           b_l;
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
input           ldrh_offset_sel;
input   [ 7: 0] ldrh_offset;

// 来自op2_shifter
input   [31: 0]  op2_in;
input            c_in;

// 寄存器接口
input   [31: 0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, ra, rb, rc, rd, re, rf, cpsr, spsr;

// 输出标准内核操作
output reg              ALU_en, mul_en;
output reg   [ 3: 0]    ALU_operation;
output reg   [ 2: 0]    mul_mode;
output reg              rd_en, rd2_en;
output reg   [ 4: 0]    rd_id, rd2_id;
output reg              psr_wr_en;
output reg   [31: 0]    op1, op2, ops;
output reg              c_out;
output reg              iset_switch;
output reg              AHB_wr_en, AHB_rd_en;
output reg   [ 3: 0]    AHB_size;
output reg              SWI, undefined_command;

// ALU_operation
parameter   OP1 = 4'h0;
parameter   OP2 = 4'h1;
parameter   OPS = 4'h2;
parameter   AND = 4'h3;
parameter   ORR = 4'h4;
parameter   EOR = 4'h5;
parameter   BIC = 4'h6;
parameter   MVN = 4'h7;
parameter   ADD = 4'h8;
parameter   ADC = 4'h9;
parameter   SUB = 4'hc;
parameter   RSB = 4'ha;
parameter   SBC = 4'hd;
parameter   RSC = 4'hb;

parameter   SU  = 3'b000;   // short unsigned 
parameter   SUA = 3'b001;
parameter   LU  = 3'b100;
parameter   LUA = 3'b101;
parameter   LS  = 3'b110;
parameter   LSA = 3'b111;   // long signed accumulation


// 操作译码 ********************************************************************************************

// ALU_en
always @* begin
if ( cmd_bx | cmd_b | cmd_bl ) 
    ALU_en = 1'b1;
else
    ALU_en = 1'b0;
end

// mul_en
always @* begin
if (  ) 
    mul_en = 1'b1;
else
    mul_en = 1'b0;
end

// ALU_operation
always @* begin
if (  ) 
    ALU_operation = OP1;
else if (  )
    ALU_operation = OPS;
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
else if ( (cmd_dp&(dp_opcode==4'h4|dp_opcode==4'hb)) )
    ALU_operation = ADD;
else if ( (cmd_dp&(dp_opcode==4'h5)) )
    ALU_operation = ADC;
else if ( (cmd_dp&(dp_opcode==4'h2|dp_opcode==4'ha)) )
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
if (  ) 
    mul_mode = SUA;
else if (  )
    mul_mode = LU;
else if (  )
    mul_mode = LUA;
else if (  )
    mul_mode = LS;
else if (  )
    mul_mode = LSA;
else // if (  )
    mul_mode = SU;
end


// rd_en & rd_id
always @* begin
if ( cmd_bx )
    rd_en = 1'b1;
else 
    rd_en = 1'b0;
end
always @* begin
if (  )
    rd_id = rd_in;
else if ( cmd_bx )
    rd_id = 5'h0f;
else if ()
    rd_id = 5'h0;
end


// rd2_en & rd2_id
always @* begin
if ()
    rd2_en = 1'b1;
else 
    rd2_en = 1'b0;
end
always @* begin
if ()
    rd2_id = 5'h0;
else if ()
    rd2_id = 5'h0;
else if ()
    rd2_id = 5'h0;
else
    rd2_id = 5'h0;
end


// psr_wr_en
always @* begin
if ()
    psr_wr_en = 1'b1;
else 
    psr_wr_en = 1'b0;
end


// op1
always @* begin
if ()
    op1 = 32'h0;
else 
    op1 = 32'h0;
end


// op2
always @* begin
if ()
    op2 = 32'h0;
else if (cmd_bx)
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
    default: 
    endcase
else 
    op2 = 32'h0;
end


// ops
always @* begin
if ()
    ops = 32'h0;
else 
    ops = 32'h0;
end


// c_out
always @* begin
if ()
    c_out = 1'b1;
else 
    c_out = c_in;
end


assign  iset_switch = cmd_bx;

// AHB
always @* begin
if ()
    AHB_wr_en = 1'b1;
else 
    AHB_wr_en = 1'b0;
end
always @* begin
if ()
    AHB_rd_en = 1'b1;
else 
    AHB_rd_en = 1'b0;
end
always @* begin
if ()
    AHB_size = 1'b1;
else 
    AHB_size = 1'b0;
end

// interrupt
always @* begin
if ()
    SWI = 1'b1;
else 
    SWI = 1'b0;
end
always @* begin
if ()
    undefined_command = 1'b1;
else 
    undefined_command = 1'b0;
end




endmodule 