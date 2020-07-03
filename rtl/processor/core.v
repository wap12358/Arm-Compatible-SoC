module core(
    clk, rst_n, cpu_en,
    rom_en, rom_addr, rom_data,
    ahb_rd_en, ahb_wr_en, ahb_addr, ahb_wr_data, ahb_rd_data, ahb_rd_vld, ahb_busy, ahb_size,
    ir_cpu_restart, ir_data_process, ir_irq, ir_fiq
);


// external port *******************************************************/
// basic signal
input                   clk;
input                   rst_n;
input                   cpu_en;

// rom
output                  rom_en  =   work_en;
output      [31: 0]     rom_addr;
input       [31: 0]     rom_data;

// AHB
output                  ahb_rd_en;
output                  ahb_wr_en;
output      [31: 0]     ahb_addr;
output      [31: 0]     ahb_wr_data;
input       [31: 0]     ahb_rd_data;
input                   ahb_rd_vld;
input                   ahb_busy;
output      [ 1: 0]     ahb_size;

// interrupt
input                   ir_cpu_restart;
input                   ir_data_process;
input                   ir_irq;
input                   ir_fiq;



// wire ******************************************************************/
wire                    work_en;
wire        [31: 0]     reg_r0, reg_r1, reg_r2, reg_r3, reg_r4, reg_r5, reg_r6, reg_r7, reg_r8, reg_r9, reg_ra, reg_rb, reg_rc, reg_rd, reg_re, reg_rf, cpsr, spsr, rd_data, rd2_data;


// operation
wire                    cmd_instruction_valid;
wire                    cmd_ALU_en, cmd_mul_en;
wire        [ 3: 0]     cmd_ALU_operation;
wire        [ 1: 0]     cmd_mul_mode;
wire                    cmd_rd_en, cmd_rd2_en;
wire        [ 4: 0]     cmd_rd_id, cmd_rd2_id;
wire        [ 3: 0]     cmd_psr_wr_cond_en;
wire        [31: 0]     cmd_op1, cmd_op2, cmd_ops_l, cmd_ops_h;
wire                    cmd_c_in;
wire                    cmd_iset_switch;
wire                    cmd_AHB_wr_en, cmd_AHB_rd_en;
wire        [ 1: 0]     cmd_AHB_size;
wire                    cmd_AHB_ldr_p, cmd_AHB_ldrs_s;
wire                    cmd_branch;

// interrupt
wire                    ir_undefined_command;
wire                    ir_swi;
wire                    ir_get_cmd;


cmd_decoder cmd_decoder(

    // basic signal
    .clk(clk),
    .rst_n(rst_n),
    .work_en(work_en),

    // input
    .code(rom_data),

    // registers
    .r0(reg_r0),
    .r1(reg_r1),
    .r2(reg_r2),
    .r3(reg_r3),
    .r4(reg_r4),
    .r5(reg_r5),
    .r6(reg_r6),
    .r7(reg_r7),
    .r8(reg_r8),
    .r9(reg_r9),
    .ra(reg_ra),
    .rb(reg_rb),
    .rc(reg_rc),
    .rd(reg_rd),
    .re(reg_re),
    .rf(reg_rf),
    .rom_pc(rom_addr),
    .cpsr(reg_cpsr),
    .spsr(reg_spsr),
    .rd_data(rd_data),
    .rd2_data(rd2_data),
    .cond_flag(cond_flag),

    // output
    .instruction_valid(cmd_instruction_valid),
    .ALU_en(cmd_ALU_en),
    .mul_en(cmd_mul_en),
    .ALU_operation(cmd_ALU_operation),
    .mul_mode(cmd_mul_mode),
    .rd_en(cmd_rd_en),
    .rd2_en(cmd_rd2_en),
    .rd_id(cmd_rd_id),
    .rd2_id(cmd_rd2_id),
    .psr_wr_cond_en(cmd_psr_wr_cond_en),
    .op1(cmd_op1),
    .op2(cmd_op2),
    .ops_l(cmd_ops_l),
    .ops_h(cmd_ops_h),
    .c_out(cmd_c_out),
    .iset_switch(cmd_iset_switch),
    .AHB_wr_en(cmd_AHB_wr_en),
    .AHB_rd_en(cmd_AHB_rd_en),
    .AHB_size(cmd_AHB_size),
    .AHB_ldr_p(cmd_AHB_ldr_p),
    .AHB_ldrs_s(cmd_AHB_ldrs_s),
    .swi(cmd_swi),
    .undefined_command(cmd_undefined_command),
    .branch(cmd_branch)

);


executor executor(
    // basic signal
    .clk(clk),
    .rst_n(rst_n),
    .work_en_external(cpu_en),
    .work_en(work_en),

    // operation
    .cmd_instruction_valid(cmd_instruction_valid),
    .cmd_ALU_en(cmd_ALU_en),
    .cmd_mul_en(cmd_mul_en),
    .cmd_ALU_operation(cmd_ALU_operation),
    .cmd_mul_mode(cmd_mul_mode),
    .cmd_rd_en(cmd_rd_en),
    .cmd_rd2_en(cmd_rd2_en),
    .cmd_rd_id(cmd_rd_id),
    .cmd_rd2_id(cmd_rd2_id),
    .cmd_psr_wr_cond_en(cmd_psr_wr_cond_en),
    .cmd_op1(cmd_op1),
    .cmd_op2(cmd_op2),
    .cmd_ops_l(cmd_ops_l),
    .cmd_ops_h(cmd_ops_h),
    .cmd_c_in(cmd_c_in),
    .cmd_iset_switch(cmd_iset_switch),
    .cmd_AHB_wr_en(cmd_AHB_wr_en),
    .cmd_AHB_rd_en(cmd_AHB_rd_en),
    .cmd_AHB_size(cmd_AHB_size),
    .cmd_AHB_ldr_p(cmd_AHB_ldr_p),
    .cmd_AHB_ldrs_s(cmd_AHB_ldrs_s),
    .cmd_branch(cmd_branch),

    // interrupt
    .ir_cpu_restart(ir_cpu_restart),
    .ir_undefined_command(ir_undefined_command),
    .ir_swi(ir_swi),
    .ir_get_cmd(ir_get_cmd),
    .ir_data_process(ir_data_process),
    .ir_irq(ir_irq),
    .ir_fiq(ir_fiq),

    // reg
    .reg_r0(reg_r0),
    .reg_r1(reg_r1),
    .reg_r2(reg_r2),
    .reg_r3(reg_r3),
    .reg_r4(reg_r4),
    .reg_r5(reg_r5),
    .reg_r6(reg_r6),
    .reg_r7(reg_r7),
    .reg_r8(reg_r8),
    .reg_r9(reg_r9),
    .reg_ra(reg_ra),
    .reg_rb(reg_rb),
    .reg_rc(reg_rc),
    .reg_rd(reg_rd),
    .reg_re(reg_re),
    .rom_pc(rom_pc),
    .reg_rf(reg_rf),
    .reg_cpsr(reg_cpsr),
    .reg_spsr(reg_spsr),
    .rd_data(rd_data),
    .rd2_data(rd2_data),
    .cond_flag(cond_flag),

    // AHB
    .AHB_wr_en(ahb_wr_en),
    .AHB_rd_en(ahb_rd_en),
    .AHB_addr(ahb_addr),
    .AHB_wr_data(ahb_wr_data),
    .AHB_rd_data(ahb_rd_data),
    .AHB_size(ahb_size),
    .AHB_rd_valid(ahb_rd_vld),
    .AHB_busy(ahb_busy)

);























endmodule