module cmd_transcode_thumb_to_arm(
    code_thumb,
    code_arm
);


input   [15: 0] thumb_code;
output  [31: 0] code;



// thumb  ********************************************************************
wire    adc_rd_rn           = ( thumb_code[15: 6] == 10'b0100_0001_01   );
wire    add_rd_rn_imm3      = ( thumb_code[15: 9] ==  7'b0001_110       );
wire    add_rd_imm8         = ( thumb_code[15:11] ==  5'b0011_0         );
wire    add_rd_rn_rm        = ( thumb_code[15: 9] ==  7'b0001_100       );
wire    add_rd16_rn16       = ( thumb_code[15: 8] ==  8'b0100_0100      );
wire    add_rd_pc_imm8      = ( thumb_code[15:11] ==  5'b1010_0         );
wire    add_rd_sp_imm8      = ( thumb_code[15:11] ==  5'b1010_1         );
wire    add_sp_imm7         = ( thumb_code[15: 7] ==  9'b1011_0000_0    );

wire    and_rd_rn           = ( thumb_code[15: 6] == 10'b0100_0000_00   );
wire    asr_rd_rn_imm5      = ( thumb_code[15:11] ==  5'b0001_0         );
wire    asr_rd_rs           = ( thumb_code[15: 6] == 10'b0100_0001_00   );
wire    bc_s8               = ( thumb_code[15:12] ==  4'b1101           );
wire    b_imm11             = ( thumb_code[15:11] ==  5'b1110_0         );
wire    bic_rd_rn           = ( thumb_code[15: 6] == 10'b0100_0011_10   );
wire    bkpt_imm8           = ( thumb_code[15: 8] ==  8'b1011_1110      );
wire    bl_imm11            = ( thumb_code[15:13] ==  3'b111            );

wire    blx_rn              = ( thumb_code[15: 7] ==  9'b0100_0111_1    );
wire    bx_rn               = ( thumb_code[15: 7] ==  9'b0100_0111_0    );
wire    cmn_rn_rm           = ( thumb_code[15: 6] == 10'b0100_0010_11   );
wire    cmp_rm_imm8         = ( thumb_code[15:11] ==  5'b0010_1         );
wire    cmp_rn_rm           = ( thumb_code[15: 6] == 10'b0100_0010_10   );
wire    cmp_rn16_rm16       = ( thumb_code[15: 8] ==  8'b0100_0101      );
wire    eor_rd_rn           = ( thumb_code[15: 6] == 10'b0100_0000_01   );
wire    ldm                 = ( thumb_code[15:11] ==  5'b1100_1         );

wire    ldr_rd_rnimm5       = ( thumb_code[15:11] ==  5'b0110_1         );
wire    ldr_rd_rnrm         = ( thumb_code[15: 9] ==  7'b0101_100       );
wire    ldr_rd_pcimm5       = ( thumb_code[15:11] ==  5'b0100_1         );
wire    ldr_rd_spimm8       = ( thumb_code[15:11] ==  5'b1001_1         );
wire    ldrb_rd_rnimm5      = ( thumb_code[15:11] ==  5'b0111_1         );
wire    ldrv_rd_rnrm        = ( thumb_code[15: 9] ==  7'b0101_110       );
wire    ldrh_rd_rnimm5      = ( thumb_code[15:11] ==  5'b1000_1         );
wire    ldrh_rd_rnrm        = ( thumb_code[15: 9] ==  7'b0101_101       );

wire    ldrsb_rd_rnrm       = ( thumb_code[15: 9] ==  7'b0101_011       );
wire    ldrsh_rd_rnrm       = ( thumb_code[15: 9] ==  7'b0101_111       );
wire    lsl_rd_rn_imm5      = ( thumb_code[15:11] ==  5'b0000_0         );
wire    lsl_rd_rn           = ( thumb_code[15: 6] == 10'b0100_0000_10   );
wire    lsr_rd_rn_imm5      = ( thumb_code[15:11] ==  5'b0000_1         );
wire    lsl_rd_rn           = ( thumb_code[15: 6] == 10'b0100_0000_11   );
wire    mov_rd_imm8         = ( thumb_code[15:11] ==  5'b0010_0         );
wire    mov_rd_rn           = ( thumb_code[15: 6] == 10'b0001_1100_00   );

wire    mov_rd_rn           = ( thumb_code[15: 8] ==  8'b0100_0110      );
wire    mul_rd_rn           = ( thumb_code[15: 6] == 10'b0100_0011_01   );
wire    mvn_rd_rn           = ( thumb_code[15: 6] == 10'b0100_0011_11   );
wire    neg_rd_rn           = ( thumb_code[15: 6] == 10'b0100_0010_01   );
wire    orr_rd_rn           = ( thumb_code[15: 6] == 10'b0100_0011_00   );
wire    pop                 = ( thumb_code[15:12] ==  4'b1011           );
wire    push                = ( thumb_code[15:12] ==  4'b1011           );
wire    ror_rd_rn           = ( thumb_code[15: 6] == 10'b0100_0001_11   );

wire    sbc_rd_rn           = ( thumb_code[15: 6] == 10'b0100_0001_10   );
wire    stm                 = ( thumb_code[15:11] ==  5'b1100_0         );
wire    str_rd_rnimm5       = ( thumb_code[15:11] ==  5'b0110_0         );
wire    str_rd_rnrm         = ( thumb_code[15: 9] ==  7'b0101_000       );
wire    str_rd_spimm8       = ( thumb_code[15:11] ==  5'b1001_0         );
wire    strb_rd_rnimm5      = ( thumb_code[15:11] ==  5'b0111_0         );
wire    strb_rd_rnrm        = ( thumb_code[15: 9] ==  7'b0101_010       );
wire    strh_rd_rnimm5      = ( thumb_code[15:11] ==  5'b1000_0         );

wire    strh_rd_rnrm        = ( thumb_code[15: 9] ==  7'b0101_001       );
wire    sub_rd_rn_imm3      = ( thumb_code[15: 9] ==  7'b0001_111       );
wire    sub_rd_imm8         = ( thumb_code[15:11] ==  5'b0011_1         );
wire    sub_rd_rn_rm        = ( thumb_code[15: 9] ==  7'b0001_101       );
wire    sub_sp_imm7         = ( thumb_code[15: 7] ==  9'b1011_0000_1    );
wire    swi_imm8            = ( thumb_code[15: 8] ==  8'b1101_1111      );
wire    tst_rn_rm           = ( thumb_code[15: 6] == 10'b0100_0010_00   );

always @* begin
if (bc_s8)  code[31:28] = thumb_code[11:8];
else        code[31:28] = 4'b1110;

end

always @* begin
if (adc_rd_rn)
    code[27:0] = { 9'b000010110, thumb_code[2:0], 1'b0, thumb_code[2:0], 9'h00, thumb_code[5:3]};
else if (add_rd_rn_imm3)
    code[27:0] = { 9'b001010010, thumb_code[5:3], 1'b0, thumb_code[2:0], 9'h0, thumb_code[8:6] };
else if (add_rd_imm8)
    code[27:0] = { 9'b001010010, thumb_code[10:8], 1'b0, thumb_code[10:8], 4'h0, thumb_code[7:0] };
else if (add_rd_rn_rm)
    code[27:0] = { 9'b000010010, thumb_code[5:3], 1'b0, thumb_code[2:0], 9'h00, thumb_code[8:6]};
else if (add_rd16_rn16)
    code[27:0] = { 8'b00001000, thumb_code[7], thumb_code[2:0], thumb_code[6:3], 8'h00, thumb_code[6:3] };
else if (add_rd_pc_imm8)
    code[27:0] = { 12'b001010001111, 1'b0, thumb_code[10:8], 4'hf, thumb_code[7:0] };
else if (add_rd_sp_imm8)
    code[27:0] = { 12'b001010001101, 1'b0, thumb_code[10:8], 4'hf, thumb_code[7:0] };
else if (add_sp_imm7)
    code[27:0] = { 21'b00101000_1101_1101_11110, thumb_code[6:0] };
else if (and_rd_rn)
    code[27:0] = { 8'b00000001, 1'b0, thumb_code[2:0], 1'b0, thumb_code[2:0], 8'h00, 1'b0, thumb_code[5:3] };
else if (asr_rd_rn_imm5)
    code[27:0] = { 12'b00011011_0000, 1'b0, thumb_code[2:0], thumb_code[10:6], 4'b1000, thumb_code[5:3] };
else if (asr_rd_rs)
    code[27:0] = { 12'b00011011_0000, 1'b0, thumb_code[2:0], 1'b0, thumb_code[5:3], 5'b01010, thumb_code[2:0] };
else if (bc_s8)
    code[27:0] = { 4'b1010, {16{thumb_code[7]}}, thumb_code[7:0] };
// else if (b_imm11)
//     code[27:0] = { 4'b1010, {13{thumb_code[10]}}, thumb_code[10:0] };
else if (bic_rd_rn)
    code[27:0] = { 8'b00011101, 1'b0, thumb_code[2:0], 1'b0, thumb_code[2:0], 8'h00, 1'b0, thumb_code[5:3] };
else if (bkpt_imm8)
    code[27:0] = { 16'h1200, thumb_code[7:4], 4'h7, thumb_code[3:0] };
else if (bl_imm11) // ?????
    case (thumb_code[12:11])
    2'b00: code[27:0] = { 4'b1010, {13{thumb_code[10]}}, thumb_code[10:0] };
    //2'b01: code[27:0] = { 3'b101, thumb_code[0], {14{thumb_code[10]}, thumb_code[10:1] } }
    //2'b10: code[27:0] = {  };
    //2'b11: code[27:0] = { 4'b1011, {14{thumb_code[10]}, thumb_code[10:1] } }
    default: code[27:0] = 28'h0;
    endcase
else if (blx_rn)
    code[27:0] = { 24'h12fff3, thumb_code[6:3] };
else if (bx_rn)
    code[27:0] = {};
else if (cmn_rn_rm)
    code[27:0] = {};
else if (cmp_rm_imm8)
    code[27:0] = {};
else if (cmp_rn_rm)
    code[27:0] = {};
else if (cmp_rn16_rm16)
    code[27:0] = {};
else if (eor_rd_rn)
    code[27:0] = {};
else if (ldm)
    code[27:0] = {};
else if (ldr_rd_rnimm5)
    code[27:0] = {};
else if (ldr_rd_rnrm)
    code[27:0] = {};
else if (ldr_rd_pcimm5)
    code[27:0] = {};
else if (ldr_rd_spimm8)
    code[27:0] = {};
else if (ldrb_rd_rnimm5)
    code[27:0] = {};
else if (ldrv_rd_rnrm)
    code[27:0] = {};
else if (ldrh_rd_rnimm5)
    code[27:0] = {};
else if (ldrh_rd_rnrm)
    code[27:0] = {};
else if (ldrsb_rd_rnrm)
    code[27:0] = {};
else if (ldrsh_rd_rnrm)
    code[27:0] = {};
else if (lsl_rd_rn_imm5)
    code[27:0] = {};
else if (lsl_rd_rn)
    code[27:0] = {};
else if (lsr_rd_rn_imm5)
    code[27:0] = {};
else if (lsl_rd_rn)
    code[27:0] = {};
else if (mov_rd_imm8)
    code[27:0] = {};
else if (mov_rd_rn)
    code[27:0] = {};
else if (mov_rd_rn)
    code[27:0] = {};
else if (mul_rd_rn)
    code[27:0] = {};
else if (mvn_rd_rn)
    code[27:0] = {};
else if (neg_rd_rn)
    code[27:0] = {};
else if (orr_rd_rn)
    code[27:0] = {};
else if (pop)
    code[27:0] = {};
else if (push)
    code[27:0] = {};
else if (ror_rd_rn)
    code[27:0] = {};
else if (sbc_rd_rn)
    code[27:0] = {};
else if (stm)
    code[27:0] = {};
else if (str_rd_rnimm5)
    code[27:0] = {};
else if (str_rd_rnrm)
    code[27:0] = {};
else if (str_rd_spimm8)
    code[27:0] = {};
else if (strb_rd_rnimm5)
    code[27:0] = {};
else if (strb_rd_rnrm)
    code[27:0] = {};
else if (strh_rd_rnimm5)
    code[27:0] = {};
else if (strh_rd_rnrm)
    code[27:0] = {};
else if (sub_rd_rn_imm3)
    code[27:0] = {};
else if (sub_rd_imm8)
    code[27:0] = {};
else if (sub_rd_rn_rm)
    code[27:0] = {};
else if (sub_sp_imm7)
    code[27:0] = {};
else if (swi_imm8)
    code[27:0] = {};
else if (tst_rn_rm)
    code[27:0] = {};





end








endmodule