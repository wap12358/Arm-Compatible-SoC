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
    swi, undefined_command

);

















endmodule 