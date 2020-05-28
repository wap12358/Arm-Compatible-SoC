module decoder_thumb_std(
    // 指令识别结果
    adc_rd_rn,
    add_rd_rn_imm3,
    add_rd_imm8,
    add_rd_rn_rm,
    add_rd16_rn16,
    add_rd_pc_imm8,
    add_rd_sp_imm8,
    add_sp_imm7,
    and_rd_rn,
    asr_rd_rn_imm5,
    asr_rd_rs,
    bc_s8,
    b_imm11,
    bic_rd_rn,
    bkpt_imm8,
    bl_imm11,
    blx_rn,
    bx_rn,
    cmn_rn_rm,
    cmp_rm_imm8,
    cmp_rn_rm,
    cmp_rn16_rm16,
    eor_rd_rn,
    ldm,
    ldr_rd_rnimm5,
    ldr_rd_rnrm,
    ldr_rd_pcimm5,
    ldr_rd_spimm8,
    ldrb_rd_rnimm5,
    ldrv_rd_rnrm,
    ldrh_rd_rnimm5,
    ldrh_rd_rnrm,
    ldrsb_rd_rnrm,
    ldrsh_rd_rnrm,
    lsl_rd_rn_imm5,
    lsl_rd_rn,
    lsr_rd_rn_imm5,
    lsl_rd_rn,
    mov_rd_imm8,
    mov_rd_rn,
    mov_rd_rn,
    mul_rd_rn,
    mvn_rd_rn,
    neg_rd_rn,
    orr_rd_rn,
    pop,
    push,
    ror_rd_rn,
    sbc_rd_rn,
    stm,
    str_rd_rnimm5,
    str_rd_rnrm,
    str_rd_spimm8,
    strb_rd_rnimm5,
    strb_rd_rnrm,
    strh_rd_rnimm5,
    strh_rd_rnrm,
    sub_rd_rn_imm3,
    sub_rd_imm8,
    sub_rd_rn_rm,
    sub_sp_imm7,
    swi_imm8,
    tst_rn_rm,

    // 指令参数
    rd, rn, rm, imm,
    cond, 

    // 寄存器接口
    r0, r1, r2, r3,
    r4, r5, r6, r7,
    r8, r9, r10, r11,
    r12, r13, r14, r15,
    cpsr, spsr,


    // 输出接口，标准内核操作
    instruction_valid,
    ALU_en, mul_en, ALU_operation,
    rd_en, rd_id, 
    rd2_en, rd2_id,
    psr_wr_cond_en,
    op1, op2, c_out,
    iset_switch, 
    AHB_wr_en, AHB_rd_en, AHB_size,
    AHB_ldr_p, AHB_ldrs_s,
    swi, undefined_command,
    branch
);

input           adc_rd_rn, add_rd_rn_imm3, add_rd_imm8, add_rd_rn_rm, add_rd16_rn16, add_rd_pc_imm8, add_rd_sp_imm8, add_sp_imm7, and_rd_rn, asr_rd_rn_imm5, asr_rd_rs, bc_s8, b_imm11, bic_rd_rn, bkpt_imm8, bl_imm11, blx_rn, bx_rn, cmn_rn_rm, cmp_rm_imm8, cmp_rn_rm, cmp_rn16_rm16, eor_rd_rn, ldm, ldr_rd_rnimm5, ldr_rd_rnrm, ldr_rd_pcimm5, ldr_rd_spimm8, ldrb_rd_rnimm5, ldrv_rd_rnrm, ldrh_rd_rnimm5, ldrh_rd_rnrm, ldrsb_rd_rnrm, ldrsh_rd_rnrm, lsl_rd_rn_imm5, lsl_rd_rn, lsr_rd_rn_imm5, lsl_rd_rn, mov_rd_imm8, mov_rd_rn, mov_rd_rn, mul_rd_rn, mvn_rd_rn, neg_rd_rn, orr_rd_rn, pop, push, ror_rd_rn, sbc_rd_rn, stm, str_rd_rnimm5, str_rd_rnrm, str_rd_spimm8, strb_rd_rnimm5, strb_rd_rnrm, strh_rd_rnimm5, strh_rd_rnrm, sub_rd_rn_imm3, sub_rd_imm8, sub_rd_rn_rm, sub_sp_imm7, swi_imm8, tst_rn_rm;
input   [ 3: 0] rd, rn, rm;
input   [31: 0] imm;
input   [ 3: 0] cond;
input   [31: 0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, cpsr, spsr;



// 输出标准内核操作
output reg              instruction_valid;
output reg              ALU_en, mul_en;
output reg  [ 3: 0]     ALU_operation;
output reg              rd_en, rd2_en;
output reg  [ 4: 0]     rd_id, rd2_id;
output reg  [ 3: 0]     psr_wr_cond_en;
output reg  [31: 0]     op1, op2;
output reg              c_out;
output                  iset_switch;
output reg              AHB_wr_en, AHB_rd_en;
output reg  [ 1: 0]     AHB_size;
output                  AHB_ldr_p, AHB_ldrs_s;
output reg              swi, undefined_command;
output reg              branch;

reg         [31: 0]     op2_buf;

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

// rd_id
parameter   RD_CPSR     = 5'h10;
parameter   RD_SPSR     = 5'h11;
parameter   RD_CPSR_FO  = 5'h12;  // flag only
parameter   RD_SPSR_FO  = 5'h13;  // flag only

// CPSR condition flag
wire    N = cpsr[31];
wire    Z = cpsr[30];
wire    C = cpsr[29];
wire    V = cpsr[28];


// 操作译码 ********************************************************************************************

// ALU_en
always @* begin
if ( adc_rd_rn | add_rd_rn_imm3 | add_rd_imm8 | add_rd_rn_rm | add_rd16_rn16 | add_rd_pc_imm8 | add_rd_sp_imm8 | add_sp_imm7 | and_rd_rn | asr_rd_rn_imm5 | asr_rd_rs | bc_s8 | b_imm11 ) 
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
else if ( and_rd_rn )
    ALU_operation = AND;
else if (  )
    ALU_operation = ORR;
else if (  )
    ALU_operation = EOR;
else if (  )
    ALU_operation = BIC;
else if (  )
    ALU_operation = MVN;
else if ( add_rd_rn_imm3 | add_rd_imm8 | add_rd_rn_rm | add_rd16_rn16 | add_rd_pc_imm8 | add_rd_sp_imm8 | add_sp_imm7 | bc_s8 | b_imm11 )
    ALU_operation = ADD;
else if ( adc_rd_rn )
    ALU_operation = ADC;
else if (  )
    ALU_operation = SUB;
else if (  )
    ALU_operation = RSB;
else if (  )
    ALU_operation = SBC;
else if (  )
    ALU_operation = RSC;
else
    ALU_operation = OP2;
end


// rd_en & rd_id
always @* begin
if ( adc_rd_rn | add_rd_rn_imm3 | add_rd_imm8 | add_rd_rn_rm | add_rd16_rn16 | add_rd_pc_imm8 | add_rd_sp_imm8 | add_sp_imm7 | and_rd_rn | asr_rd_rn_imm5 | asr_rd_rs | bc_s8 | b_imm11 )
    rd_en = 1'b1;
else 
    rd_en = 1'b0;
end
always @* begin
if ( adc_rd_rn | add_rd_rn_imm3 | add_rd_imm8 | add_rd_rn_rm | add_rd16_rn16 | add_rd_pc_imm8 | add_rd_sp_imm8 | add_sp_imm7 | and_rd_rn | asr_rd_rn_imm5 | asr_rd_rs | bc_s8 | b_imm11 )
    rd_id = { 1'b0, rd };
else if (  )
    rd_id = 5'h0f;
else if (  )
    rd_id = mrs_sel ? RD_SPSR : RD_CPSR;
else if (  )
    rd_id = mrs_sel ? RD_SPSR_FO : RD_CPSR_FO;
else
    rd_id = 5'h0;
end


// rd2_en & rd2_id
always @* begin
if (  )
    rd2_en = 1'b1;
else 
    rd2_en = 1'b0;
end
always @* begin
if (  )
    rd2_id = { 1'b0, rn };
else if (  )
    rd2_id = { 1'b0, rd };
else if (  )
    rd2_id = { 1'b0, rm };
else
    rd2_id = 5'h0;
end


// psr_wr_cond_en
always @* begin
if ( adc_rd_rn | add_rd_rn_imm3 | add_rd_imm8 | add_rd_rn_rm | and_rd_rn | asr_rd_rn_imm5 )
    psr_wr_cond_en = 4'b1111;
else if ( asr_rd_rs )
    psr_wr_cond_en = 4'b1110;
else if (  )
    psr_wr_cond_en = 4'b1100;
else 
    psr_wr_cond_en = 4'b0000;
end


// op1
always @* begin
if ( adc_rd_rn | add_rd_rn_imm3 | add_rd_imm8 | add_rd_rn_rm | add_rd16_rn16 | add_rd_pc_imm8 | add_rd_sp_imm8 | add_sp_imm7 | and_rd_rn | bc_s8 | b_imm11 )
    case (rn)
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
    4'ha: op1 = r10;
    4'hb: op1 = r11;
    4'hc: op1 = r12;
    4'hd: op1 = r13;
    4'he: op1 = r14;
    4'hf: op1 = r15;
    default: op1 = 32'h0;
    endcase
else 
    op1 = 32'h0;
end


// op2 & shifter & c_out
always @* begin
c_out = C;
case (rm)
4'h0: op2_buf = r0;
4'h1: op2_buf = r1;
4'h2: op2_buf = r2;
4'h3: op2_buf = r3;
4'h4: op2_buf = r4;
4'h5: op2_buf = r5;
4'h6: op2_buf = r6;
4'h7: op2_buf = r7;
4'h8: op2_buf = r8;
4'h9: op2_buf = r9;
4'ha: op2_buf = r10;
4'hb: op2_buf = r11;
4'hc: op2_buf = r12;
4'hd: op2_buf = r13;
4'he: op2_buf = r14;
4'hf: op2_buf = r15;
default: op2_buf = 32'h0;
endcase
if ( adc_rd_rn | add_rd_rn_rm | add_rd16_rn16 | and_rd_rn )
    op2 = op2_buf;
else if ( add_rd_rn_imm3 | add_rd_imm8 | add_rd_pc_imm8 | add_rd_sp_imm8 | add_sp_imm7 | bc_s8 | b_imm11 )
    op2 = imm;
else if ( asr_rd_rn_imm5 | asr_rd_rs ) begin
    if (((|imm[4:0]) & asr_rd_rn_imm5) | ((~|imm[7:5]) & asr_rd_rs) ) begin
        c_out = ( imm[4:0] == 0 ) ? C : op2_buf[imm[4:0]-1];
        op2 = op2_buf >> imm[4:0];
    end else begin
        c_out = op2_buf[31];
        op2 = {32{op2_buf[31]}};
    end
end
else 
    op2 = 32'h0;
end


assign  iset_switch = 1'b0;

// AHB
always @* begin
if (  )
    AHB_wr_en = 1'b1;
else 
    AHB_wr_en = 1'b0;
end
always @* begin
if (  )
    AHB_rd_en = 1'b1;
else 
    AHB_rd_en = 1'b0;
end
always @* begin
if (  )
    AHB_size = 2'b11;
else if (  )
    AHB_size = 2'b10;
else
    AHB_size = 2'b00;
end
assign AHB_ldr_p    = 1'b0;
assign AHB_ldrs_s   = 1'b0;

// interrupt
always @* begin
if (  )
    swi = 1'b1;
else 
    swi = 1'b0;
end
always @* begin
if (  )
    undefined_command = 1'b0;
else 
    undefined_command = 1'b1;
end

// branch ( 放弃流水线上的指令 )
always @* begin
if ( bc_s8 | b_imm11 ) begin
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