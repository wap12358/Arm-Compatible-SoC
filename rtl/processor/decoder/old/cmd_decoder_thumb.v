module cmd_decoder_thumb(
    code, addr1,
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
    ldr_l,
    ldrh_offset_sel,
    ldrh_offset,

);


input       [31: 0] code;
input               addr1;

output      [ 3: 0] cond;

output reg          cmd_bx;
output reg          cmd_b;
output reg          cmd_bl;
output reg          cmd_dp;
output reg          cmd_mrs;
output reg          cmd_msr;
output reg          cmd_msr_flag_only;
output reg          cmd_mul;
output reg          cmd_mull;
output reg          cmd_ldr;
output reg          cmd_ldrh;
output reg          cmd_ldrsb;
output reg          cmd_ldrsh;
output reg          cmd_ldm;
output reg          cmd_swp;
output reg          cmd_swi;
output reg          cmd_cdp;
output reg          cmd_ldc;
output reg          cmd_mrc;
output reg          cmd_undefine;


output reg  [ 3: 0] rd, rn, rm, rs;



output reg  [ 3: 0] b_offset;
output reg  [ 3: 0] dp_opcode;
output reg  [12: 0] dp_op2;
output reg          dp_s;
output reg          mrs_sel;
output reg          mul_a;
output reg          mull_u;
output reg  [11: 0] ldr_offset;
output reg          ldr_p;
output reg          ldr_u;
output reg          ldr_b;
output reg          ldr_w;
output reg          ldr_l;
output reg          ldrh_offset_sel;
output reg  [ 7: 0] ldrh_offset;


// select halfword
wire    [15: 0] thumb_code;
assign  thumb_code = addr1 ? code[31:16] : code[15:0];






// thumb code to thumb operation ******************************************************
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

wire    blx_rn              = ( thumb_code[15: 6] == 10'b0100_0000_00   );
wire    bx_rn               = ( thumb_code[15:11] ==  5'b0001_0         );
wire    cmn_rn_rm           = ( thumb_code[15: 6] == 10'b0100_0001_00   );
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

// rd
always @* begin
if ( adc_rd_rn | add_rd_rn_imm3 | add_rd_rn_rm ) 
    rd = { 1'b0, thumb_code[2:0] };
else if ( add_rd_imm8 ) 
    rd = { 1'b0, thumb_code[10:8] };
else if ( add_rd16_rn16 ) 
    rd = { thumb_code[7], thumb_code[2:0] };

end

// rn
always @* begin
if ( adc_rd_rn | add_rd_rn_imm3 | add_rd_rn_rm ) 
    rn = { 1'b0, thumb_code[5:3] };
else if ( add_rd_imm8 ) 
    rn = { 1'b0, thumb_code[10:8] };
else if ( add_rd16_rn16 ) 
    rn = thumb_code[6:3];
end

// rm
always @* begin
if (  ) 
    rm = { 1'b0, thumb_code[10:8] };
end

// rs
always @* begin
if (  ) 
    rs = { 1'b0, thumb_code[2:0] };
end




// thumb operation to arm operation ***************************************************
assign  cmd_bx              = (  );
assign  cmd_b               = (  );
assign  cmd_bl              = (  );
assign  cmd_dp              = ( adc_rd_rn | add_rd_rn_imm3 | add_rd_imm8 | add_rd_rn_rm | add_rd16_rn16 );
assign  cmd_mrs             = (  );
assign  cmd_msr             = (  );
assign  cmd_msr_flag_only   = (  );            
assign  cmd_mul             = (  );
assign  cmd_mull            = (  );    
assign  cmd_ldr             = (  );
assign  cmd_ldrh            = (  );    
assign  cmd_ldrsb           = (  );    
assign  cmd_ldrsh           = (  );    
assign  cmd_ldm             = (  );
assign  cmd_swp             = (  );
assign  cmd_swi             = (  );
assign  cmd_cdp             = (  );
assign  cmd_ldc             = (  );
assign  cmd_mrc             = (  );
assign  cmd_undefine        = (  );        

// b_offset
always @* begin

end


// dp_opcode
always @* begin
if( adc_rd_rn )
    dp_opcode = 4'b0101;
else if ( add_rd_rn_imm3 | add_rd_imm8 | add_rd_rn_rm | add_rd16_rn16 )
    dp_opcode = 4'b0100;

end


// dp_op2
always @* begin
if( adc_rd_rn )
    dp_op2 = { 10'h0, thumb_code[2:0] };
else if ( add_rd_rn_imm3 )
    dp_op2 = { 10'h200, thumb_code[8:6] };
else if ( add_rd_imm8 )
    dp_op2 = { 5'h10, thumb_code[7:0] };
else if ( add_rd_rn_rm )
    dp_op2 = { 10'h0, thumb_code[8:6] };
else if ( add_rd16_rn16 )
    dp_op2 = { 9'h0, thumb_code[7], thumb_code[2:0] };

end


// dp_s
always @* begin
if( adc_rd_rn | add_rd_rn_imm3 | add_rd_imm8 | add_rd_rn_rm ) 
        dp_s = 1'b1;
else    dp_s = 1'b0;

end


// mrs_sel
always @* begin

end


// mul_a
always @* begin

end


// mull_u
always @* begin

end


// ldr_offset
always @* begin

end


// ldr_p
always @* begin

end


// ldr_u
always @* begin

end


// ldr_b
always @* begin

end


// ldr_w
always @* begin

end


// ldr_l
always @* begin

end


// ldrh_offset_sel
always @* begin

end


// ldrh_offset
always @* begin

end


















endmodule