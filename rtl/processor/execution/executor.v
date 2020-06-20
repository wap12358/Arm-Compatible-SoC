module executor(

);



// port *****************************************************************************
// basic signal
input               clk; 
input               rst_n; 
input               work_en_external;

// operation
input               cmd_instruction_valid;
input               cmd_ALU_en, cmd_mul_en;
input   [ 3: 0]     cmd_ALU_operation;
input   [ 1: 0]     cmd_mul_mode;
input               cmd_rd_en, cmd_rd2_en;
input   [ 4: 0]     cmd_rd_id, cmd_rd2_id;
input   [ 3: 0]     cmd_psr_wr_cond_en;
input   [31: 0]     cmd_op1, cmd_op2, cmd_ops_l, cmd_ops_h, 
input               cmd_c_in;
input               cmd_iset_switch;
input               cmd_AHB_wr_en, cmd_AHB_rd_en;
input   [ 1: 0]     cmd_AHB_size;
input               cmd_AHB_ldr_p, cmd_AHB_ldrs_s;
input               cmd_branch;

// interrupt
input               ir_cpu_restart;
input               ir_undefined_command;
input               ir_swi;
input               ir_get_cmd;
input               ir_data_process;
input               ir_irq;
input               ir_fiq;

// register to decoder
output  [31: 0]     reg_r0  =   r0;
output  [31: 0]     reg_r1  =   r1;
output  [31: 0]     reg_r2  =   r2;
output  [31: 0]     reg_r3  =   r3;
output  [31: 0]     reg_r4  =   r4;
output  [31: 0]     reg_r5  =   r5;
output  [31: 0]     reg_r6  =   r6;
output  [31: 0]     reg_r7  =   r7;
output  [31: 0]     reg_r8  =   mode_fiq ? r8_fiq  : r8;
output  [31: 0]     reg_r9  =   mode_fiq ? r9_fiq  : r9;
output  [31: 0]     reg_ra  =   mode_fiq ? r10_fiq : r10;
output  [31: 0]     reg_rb  =   mode_fiq ? r11_fiq : r11;
output  [31: 0]     reg_rc  =   mode_fiq ? r12_fiq : r12;
output  [31: 0]     reg_rd  =   mode_fiq ? r13_fiq :
                                mode_irq ? r13_irq :
                                mode_svc ? r13_svc :
                                mode_abt ? r13_abt :
                                mode_und ? r13_abt :
                                           r13;
output  [31: 0]     reg_re  =   mode_fiq ? r13_fiq :
                                mode_irq ? r13_irq :
                                mode_svc ? r13_svc :
                                mode_abt ? r13_abt :
                                mode_und ? r13_abt :
                                           r13;
output  [31: 0]     reg_rf  =   pc;
output  [31: 0]     reg_cpsr=   cpsr;
output  [31: 0]     reg_spsr=   mode_fiq ? spsr_fiq :
                                mode_irq ? spsr_irq :
                                mode_svc ? spsr_svc :
                                mode_abt ? spsr_abt :
                                mode_und ? spsr_abt :
                                           32'h0;
output  [31: 0]     rd_data;
output  [31: 0]     rd2_data;

// AHB master interface
output              AHB_wr_en, AHB_rd_en;
output  [31: 0]     AHB_addr;
output  [31: 0]     AHB_wr_data;
input   [31: 0]     AHB_rd_data;
output  [ 1: 0]     AHB_size;
input               valid, error;

// register & wire ********************************************************************
reg     [31: 0]     r0, r1, r2, r3, r4, r5, r6, r7;
reg     [31: 0]     r8, r8_fiq;
reg     [31: 0]     r9, r9_fiq;
reg     [31: 0]     r10, r10_fiq;
reg     [31: 0]     r11, r11_fiq;
reg     [31: 0]     r12, r12_fiq;
reg     [31: 0]     r13, r13_svc, r13_abt, r13_und, r13_irq, r13_fiq;
reg     [31: 0]     r14, r14_svc, r14_abt, r14_und, r14_irq, r14_fiq;
reg     [31: 0]     pc;
reg     [31: 0]     cpsr;
reg     [31: 0]     spsr_svc, spsr_abt, spsr_und, spsr_irq, spsr_fiq;
wire    [31: 0]     pc_next = pc + ( cpsr_t ? 3'h2 : 3'h4 );
wire                result_n, result_z, result_c, result_v;

// parameter ***************************************************************************
// mode
parameter           parameter_mode_usr  =   5'b10000;
parameter           parameter_mode_sys  =   5'b11111;
parameter           parameter_mode_svc  =   5'b10011;
parameter           parameter_mode_fiq  =   5'b10001;
parameter           parameter_mode_irq  =   5'b10010;
parameter           parameter_mode_abt  =   5'b10111;
parameter           parameter_mode_und  =   5'b11011;

// address
parameter           RD_CPSR             =   5'h10;
parameter           RD_SPSR             =   5'h11;
parameter           RD_CPSR_FO          =   5'h12;  // flag only
parameter           RD_SPSR_FO          =   5'h13;  // flag only
//parameter   RD_AHB_ADDR = 5'h18;

// important wire & register ********************************************************
// mode
wire                mode_usr            =   cpsr[4:0] == parameter_mode_usr;
wire                mode_sys            =   cpsr[4:0] == parameter_mode_sys;
wire                mode_svc            =   cpsr[4:0] == parameter_mode_svc;
wire                mode_fiq            =   cpsr[4:0] == parameter_mode_fiq;
wire                mode_irq            =   cpsr[4:0] == parameter_mode_irq;
wire                mode_abt            =   cpsr[4:0] == parameter_mode_abt;
wire                mode_und            =   cpsr[4:0] == parameter_mode_und;
wire                cpsr_i              =   cpsr[7];
wire                cpsr_f              =   cpsr[6];
wire                cpsr_t              =   cpsr[5];

// pipeline & work_en
wire                work_en_bus_rd;
wire                work_en_bus_rd_busy;
wire                work_en     =   work_en_external & work_en_bus_rd & work_en_bus_busy;
reg     [ 1: 0]     pipeline_en;

// pipeline & work_en
always @(posedge clk or negedge rst_n) begin
if(~rst_n)begin
    pipeline_en <= 2'b00; 
end else if (ir_cpu_restart) begin
    pipeline_en <= 2'b00;
end else if(work_en) begin
    pipeline_en <= cmd_branch ? 2'b00 : {1'b1,pipeline_en[1]};
end
end

//always @(posedge clk or negedge rst_n) begin
//if (~rst_n) begin
//    work_en_rd_bus  <= 1'b1;
//end else if (ir_cpu_restart) begin
//    work_en_rd_bus  <= 1'b1;
//end else begin
//    work_en_bus_rd  <=  cmd_AHB_rd_en   ? 1'b0 :
//                        bus_vld         ? 1'b1 :
//                                          work_en_bus_rd;
//end
//end

assign  work_en_bus_rd = ~( cmd_AHB_rd_en & ~AHB_vld );

assign  work_en_bus_busy = bus_busy;

// basic control logic ***************************************************************
wire    [31: 0]     result_alu, result_mull, result_mulh, result_AHBrd;


// ALU & MUL **************************************************************************
executor_ALU alu(
    .en(),
    .opcode(),
    .op1(),
    .op2(),
    .c_in(),
    .result(result_alu),
    .N(),
    .Z(),
    .C(),
    .V()
);
executor_MUL mul(
    .en(),
    .mode(),
    .op1(),
    .op2(),
    .ops_l(),
    .ops_h(),
    .result({result_mulh,resule_mull}),
    .N(),
    .Z(),
    .C(),
    .V()
);


// registers **************************************************************************
always @(posedge clk or negedge rst_n) begin
if (~rst_n) begin
    r0  <=  32'h0;
    r1  <=  32'h0;
    r2  <=  32'h0;
    r3  <=  32'h0;
    r4  <=  32'h0;
    r5  <=  32'h0;
    r6  <=  32'h0;
    r7  <=  32'h0;
//else if (ir_cpu_restart) begin
//    r0  <=  32'h0;
//    r1  <=  32'h0;
//    r2  <=  32'h0;
//    r3  <=  32'h0;
//    r4  <=  32'h0;
//    r5  <=  32'h0;
//    r6  <=  32'h0;
//    r7  <=  32'h0;
end else begin
    r0  <=  (  rd_en & (  rd_id == 5'h0 ) ) ? rd_data       :
            ( rd2_en & ( rd2_id == 5'h0 ) ) ? rd2_data      :
                                              r0;
    r1  <=  (  rd_en & (  rd_id == 5'h1 ) ) ? rd_data       :
            ( rd2_en & ( rd2_id == 5'h1 ) ) ? rd2_data      : 
                                              r1;
    r2  <=  (  rd_en & (  rd_id == 5'h2 ) ) ? rd_data       :
            ( rd2_en & ( rd2_id == 5'h2 ) ) ? rd2_data      : 
                                              r2;
    r3  <=  (  rd_en & (  rd_id == 5'h3 ) ) ? rd_data       :
            ( rd2_en & ( rd2_id == 5'h3 ) ) ? rd2_data      : 
                                              r3;
    r4  <=  (  rd_en & (  rd_id == 5'h4 ) ) ? rd_data       :
            ( rd2_en & ( rd2_id == 5'h4 ) ) ? rd2_data      : 
                                              r4;
    r5  <=  (  rd_en & (  rd_id == 5'h5 ) ) ? rd_data       :
            ( rd2_en & ( rd2_id == 5'h5 ) ) ? rd2_data      : 
                                              r5;
    r6  <=  (  rd_en & (  rd_id == 5'h6 ) ) ? rd_data       :
            ( rd2_en & ( rd2_id == 5'h6 ) ) ? rd2_data      : 
                                              r6;
    r7  <=  (  rd_en & (  rd_id == 5'h7 ) ) ? rd_data       :
            ( rd2_en & ( rd2_id == 5'h7 ) ) ? rd2_data      : 
                                              r7;
end
end

always @(posedge clk or negedge rst_n) begin
if (~rst_n) begin
    r8      <=  32'h0;
    r8_fiq  <=  32'h0;
    r9      <=  32'h0;
    r9_fiq  <=  32'h0;
    r10     <=  32'h0;
    r10_fiq <=  32'h0;
    r11     <=  32'h0;
    r11_fiq <=  32'h0;
    r12     <=  32'h0;
    r12_fiq <=  32'h0;
//else if (ir_cpu_restart) begin
//    r8      <=  32'h0;
//    r8_fiq  <=  32'h0;
//    r9      <=  32'h0;
//    r9_fiq  <=  32'h0;
//    r10     <=  32'h0;
//    r10_fiq <=  32'h0;
//    r11     <=  32'h0;
//    r11_fiq <=  32'h0;
//    r12     <=  32'h0;
//    r12_fiq <=  32'h0;
end else begin
    r8      <=  (  rd_en & (  rd_id == 5'h8 ) & ~mode_fiq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'h8 ) & ~mode_fiq ) ? rd2_data      : 
                                                              r8;
    r8_fiq  <=  (  rd_en & (  rd_id == 5'h8 ) & ~mode_fiq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'h8 ) & ~mode_fiq ) ? rd2_data      : 
                                                              r8_fiq;
    r9      <=  (  rd_en & (  rd_id == 5'h9 ) & ~mode_fiq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'h9 ) & ~mode_fiq ) ? rd2_data      : 
                                                              r9;
    r9_fiq  <=  (  rd_en & (  rd_id == 5'h9 ) & ~mode_fiq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'h9 ) & ~mode_fiq ) ? rd2_data      : 
                                                              r9_fiq;
    r10     <=  (  rd_en & (  rd_id == 5'ha ) & ~mode_fiq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'ha ) & ~mode_fiq ) ? rd2_data      : 
                                                              r10;
    r10_fiq <=  (  rd_en & (  rd_id == 5'ha ) & ~mode_fiq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'ha ) & ~mode_fiq ) ? rd2_data      : 
                                                              r10_fiq;
    r11     <=  (  rd_en & (  rd_id == 5'hb ) & ~mode_fiq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'hb ) & ~mode_fiq ) ? rd2_data      : 
                                                              r11;
    r11_fiq <=  (  rd_en & (  rd_id == 5'hb ) & ~mode_fiq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'hb ) & ~mode_fiq ) ? rd2_data      : 
                                                              r11_fiq;
    r12     <=  (  rd_en & (  rd_id == 5'hc ) & ~mode_fiq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'hc ) & ~mode_fiq ) ? rd2_data      : 
                                                              r12;
    r12_fiq <=  (  rd_en & (  rd_id == 5'hc ) & ~mode_fiq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'hc ) & ~mode_fiq ) ? rd2_data      : 
                                                              r12_fiq;
end
end

always @(posedge clk or negedge rst_n) begin
if (~rst_n) begin
    r13     <= 32'h0;
    r13_svc <= 32'h0;
    r13_abt <= 32'h0;
    r13_und <= 32'h0;
    r13_irq <= 32'h0;
    r13_fiq <= 32'h0;
//else if (ir_cpu_restart) begin
//    r13     <= 32'h0;
//    r13_svc <= 32'h0;
//    r13_abt <= 32'h0;
//    r13_und <= 32'h0;
//    r13_irq <= 32'h0;
//    r13_fiq <= 32'h0;
end else begin
    r13     <=  (  rd_en & (  rd_id == 5'hd ) & ( mode_usr | mode_sys ) ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'hd ) & ( mode_usr | mode_sys ) ) ? rd2_data      :
                                                                            r13;
    r13_svc <=  (  rd_en & (  rd_id == 5'hd ) & mode_svc ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'hd ) & mode_svc ) ? rd2_data      :
                                                             r13_svc;
    r13_abt <=  (  rd_en & (  rd_id == 5'hd ) & mode_abt ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'hd ) & mode_abt ) ? rd2_data      :
                                                             r13_abt;
    r13_und <=  (  rd_en & (  rd_id == 5'hd ) & mode_und ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'hd ) & mode_und ) ? rd2_data      :
                                                             r13_und;
    r13_irq <=  (  rd_en & (  rd_id == 5'hd ) & mode_irq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'hd ) & mode_irq ) ? rd2_data      :
                                                             r13_irq;
    r13_fiq <=  (  rd_en & (  rd_id == 5'hd ) & mode_fiq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'hd ) & mode_fiq ) ? rd2_data      :
                                                             r13_fiq;
end
end

always @(posedge clk or negedge rst_n) begin
if (~rst_n) begin
    r14     <= 32'h0;
    r14_svc <= 32'h0;
    r14_abt <= 32'h0;
    r14_und <= 32'h0;
    r14_irq <= 32'h0;
    r14_fiq <= 32'h0;
//else if (ir_cpu_restart) begin
//    r14     <= 32'h0;
//    r14_svc <= 32'h0;
//    r14_abt <= 32'h0;
//    r14_und <= 32'h0;
//    r14_irq <= 32'h0;
//    r14_fiq <= 32'h0;
end else begin // 需要考虑中断
    r14     <=  (  rd_en & (  rd_id == 5'he ) & ( mode_usr | mode_sys ) ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'he ) & ( mode_usr | mode_sys ) ) ? rd2_data      :
                                                                            r14;
    r14_svc <=  (  rd_en & (  rd_id == 5'he ) & mode_svc ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'he ) & mode_svc ) ? rd2_data      :
                                                             r14_svc;
    r14_abt <=  (  rd_en & (  rd_id == 5'he ) & mode_abt ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'he ) & mode_abt ) ? rd2_data      :
                                                             r14_abt;
    r14_und <=  (  rd_en & (  rd_id == 5'he ) & mode_und ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'he ) & mode_und ) ? rd2_data      :
                                                             r14_und;
    r14_irq <=  (  rd_en & (  rd_id == 5'he ) & mode_irq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'he ) & mode_irq ) ? rd2_data      :
                                                             r14_irq;
    r14_fiq <=  (  rd_en & (  rd_id == 5'he ) & mode_fiq ) ? rd_data       :
                ( rd2_en & ( rd2_id == 5'he ) & mode_fiq ) ? rd2_data      :
                                                             r14_fiq;
    if (ir_fiq & ~cpsr_f & ir_data_process) begin
        r14_fiq <= 32'h10;
        r14_abt <= pc_next;
    end else if (ir_data_process) begin
        r14_und <= pc_next;
    end else if (ir_fiq & ~cpsr_f) begin
        r14_fiq <= pc_next;   
    end else if (ir_irq & ~cpsr_i) begin
        r14_fiq <= pc_next;
    end else if (ir_get_cmd) begin
        r14_abt <= pc_next;
    end else if (ir_undefined_command) begin
        r14_und <= pc_next;
    end else if (ir_swi) begin
        r14_svc <= pc_next;
    end
end
end

always @(posedge clk or negedge rst_n) begin
if (~rst_n) begin
    pc      <= 32'h0;
end else if (ir_cpu_restart) begin
    pc      <= 32'h0;
end else begin
    if (ir_fiq & ~cpsr_f) begin
        pc  <= 32'h1c;
    end else if (ir_data_process) begin
        pc  <= 32'h10;
    end else if (ir_irq & ~cpsr_i) begin
        pc  <= 32'h18;
    end else if (ir_get_cmd) begin
        pc  <= 32'hc;
    end else if (ir_undefined_command) begin
        pc  <= 32'h4;
    end else if (ir_swi) begin
        pc  <= 32'h8;
    end else if ( rd_en & (rd_id == 5'hf) ) begin
        pc  <= rd_data;
    end else if ( rd2_en & (rd2_id == 5'hf) ) begin
        pc  <= rd2_data;
    end else if (work_en) begin
        pc  <= pc_next;
    end else begin
        pc  <= pc;
    end
end
end

always @(posedge clk or negedge rst_n) begin
if (~rst_n) begin
    cpsr    <= 32'h0;
end else if (ir_cpu_restart) begin
    cpsr    <= { cpsr[31:8], 8'b110_10011 };
end else begin
    cpsr    <=  (  rd_en & (  rd_id == RD_CPSR    ) ) ?    rd_data :
                ( rd2_en & ( rd2_id == RD_CPSR    ) ) ?   rd2_data :
                (  rd_en & (  rd_id == RD_CPSR_FO ) ) ? {  rd_data[31:28], cpsr[27:8],  rd_data[7:0] }   :
                ( rd2_en & ( rd2_id == RD_CPSR_FO ) ) ? { rd2_data[31:28], cpsr[27:8], rd2_data[7:0] }   :
                                                        cpsr;
    // 标志位改变
    cpsr[31]    <= cmd_psr_wr_cond_en[3] ? result_n : cpsr[31];
    cpsr[30]    <= cmd_psr_wr_cond_en[2] ? result_z : cpsr[30];
    cpsr[29]    <= cmd_psr_wr_cond_en[1] ? result_c : cpsr[29];
    cpsr[28]    <= cmd_psr_wr_cond_en[0] ? result_v : cpsr[28];
    // cpsr中断处理
    if (ir_fiq & ~cpsr_f & ir_data_process) begin
        cpsr[7:0]   <= 8'b110_10001;
    end else if (ir_data_process) begin
        cpsr[7:0]   <= { 1'b1, cpsr[6], 1'b0, 5'b10111 };
    end else if (ir_fiq & ~cpsr_f) begin
        cpsr[7:0]   <= 8'b110_10001;
    end else if (ir_irq & ~cpsr_i) begin
        cpsr[7:0]   <= { 1'b1, cpsr[6], 1'b0, 5'b10010 };
    end else if (ir_get_cmd) begin
        cpsr[7:0]   <= { 1'b1, cpsr[6], 1'b0, 5'b10111 };
    end else if (ir_undefined_command) begin
        cpsr[7:0]   <= { 1'b1, cpsr[6], 1'b0, 5'b11011 };
    end else if (ir_swi) begin
        cpsr[7:0]   <= { 1'b1, cpsr[6], 1'b0, 5'b10011 };
    end
end
end

always @(posedge clk or negedge rst_n) begin
if (~rst_n) begin
    spsr_svc    <= 32'h0;
    spsr_abt    <= 32'h0;
    spsr_und    <= 32'h0;
    spsr_irq    <= 32'h0;
    spsr_fiq    <= 32'h0;
//end else if (ir_cpu_restart) begin
//    spsr_svc    <= 32'h0;
//    spsr_abt    <= 32'h0;
//    spsr_und    <= 32'h0;
//    spsr_irq    <= 32'h0;
//    spsr_fiq    <= 32'h0;
end else begin
    spsr_svc    <=  (  rd_en & (  rd_id == RD_SPSR    ) & mode_svc ) ?    rd_data :
                    ( rd2_en & ( rd2_id == RD_SPSR    ) & mode_svc ) ?   rd2_data :
                    (  rd_en & (  rd_id == RD_SPSR_FO ) & mode_svc ) ? {  rd_data[31:28], spsr_svc[27:8],  rd_data[7:0] }   :
                    ( rd2_en & ( rd2_id == RD_SPSR_FO ) & mode_svc ) ? { rd2_data[31:28], spsr_svc[27:8], rd2_data[7:0] }   :
                                                                         spsr_svc;
    spsr_abt    <=  (  rd_en & (  rd_id == RD_SPSR    ) & mode_abt ) ?    rd_data :
                    ( rd2_en & ( rd2_id == RD_SPSR    ) & mode_abt ) ?   rd2_data :
                    (  rd_en & (  rd_id == RD_SPSR_FO ) & mode_abt ) ? {  rd_data[31:28], spsr_abt[27:8],  rd_data[7:0] }   :
                    ( rd2_en & ( rd2_id == RD_SPSR_FO ) & mode_abt ) ? { rd2_data[31:28], spsr_abt[27:8], rd2_data[7:0] }   :
                                                                         spsr_abt;
    spsr_und    <=  (  rd_en & (  rd_id == RD_SPSR    ) & mode_und ) ?    rd_data :
                    ( rd2_en & ( rd2_id == RD_SPSR    ) & mode_und ) ?   rd2_data :
                    (  rd_en & (  rd_id == RD_SPSR_FO ) & mode_und ) ? {  rd_data[31:28], spsr_und[27:8],  rd_data[7:0] }   :
                    ( rd2_en & ( rd2_id == RD_SPSR_FO ) & mode_und ) ? { rd2_data[31:28], spsr_und[27:8], rd2_data[7:0] }   :
                                                                         spsr_und;
    spsr_irq    <=  (  rd_en & (  rd_id == RD_SPSR    ) & mode_irq ) ?    rd_data :
                    ( rd2_en & ( rd2_id == RD_SPSR    ) & mode_irq ) ?   rd2_data :
                    (  rd_en & (  rd_id == RD_SPSR_FO ) & mode_irq ) ? {  rd_data[31:28], spsr_irq[27:8],  rd_data[7:0] }   :
                    ( rd2_en & ( rd2_id == RD_SPSR_FO ) & mode_irq ) ? { rd2_data[31:28], spsr_irq[27:8], rd2_data[7:0] }   :
                                                                         spsr_irq;
    spsr_fiq    <=  (  rd_en & (  rd_id == RD_SPSR    ) & mode_fiq ) ?    rd_data :
                    ( rd2_en & ( rd2_id == RD_SPSR    ) & mode_fiq ) ?   rd2_data :
                    (  rd_en & (  rd_id == RD_SPSR_FO ) & mode_fiq ) ? {  rd_data[31:28], spsr_fiq[27:8],  rd_data[7:0] }   :
                    ( rd2_en & ( rd2_id == RD_SPSR_FO ) & mode_fiq ) ? { rd2_data[31:28], spsr_fiq[27:8], rd2_data[7:0] }   :
                                                                         spsr_fiq;
    if (ir_fiq & ~cpsr_f & ir_data_process) begin
        spsr_abt    <= cpsr;
        spsr_fiq    <= { cpsr[31:28], spsr_fiq[27:8], 1'b1, cpsr[6], 6'b0_10111 } ;
    end else if (ir_data_process) begin
        spsr_abt    <= cpsr;
    end else if (ir_fiq & ~cpsr_f) begin
        spsr_fiq    <= cpsr;
    end else if (ir_irq & ~cpsr_i) begin
        spsr_irq    <= cpsr;
    end else if (ir_get_cmd) begin
        spsr_abt    <= cpsr;
    end else if (ir_undefined_command) begin
        spsr_und    <= cpsr;
    end else if (ir_swi) begin
        spsr_svc    <= cpsr;
    end
end
end

// data I/O ****************************************************************************
reg     [31: 0]     AHB_wr_data_word_buf, AHB_wr_data_buf, result_AHBrd_buf;

assign  AHB_wr_en   = cmd_AHB_wr_en & ~AHB_rd_en;
assign  AHB_rd_en   = cmd_AHB_rd_en & ~AHB_rd_valid;
assign  AHB_addr    = cmd_AHB_ldr_p ? result_alu : op1;
always @* begin
    case (cmd_rd2_id)
    5'h0: AHB_wr_data_word_buf = reg_r0;
    5'h1: AHB_wr_data_word_buf = reg_r1;
    5'h2: AHB_wr_data_word_buf = reg_r2;
    5'h3: AHB_wr_data_word_buf = reg_r3;
    5'h4: AHB_wr_data_word_buf = reg_r4;
    5'h5: AHB_wr_data_word_buf = reg_r5;
    5'h6: AHB_wr_data_word_buf = reg_r6;
    5'h7: AHB_wr_data_word_buf = reg_r7;
    5'h8: AHB_wr_data_word_buf = reg_r8;
    5'h9: AHB_wr_data_word_buf = reg_r9;
    5'ha: AHB_wr_data_word_buf = reg_ra;
    5'hb: AHB_wr_data_word_buf = reg_rb;
    5'hc: AHB_wr_data_word_buf = reg_rc;
    5'hd: AHB_wr_data_word_buf = reg_rd;
    5'he: AHB_wr_data_word_buf = reg_re;
    5'hf: AHB_wr_data_word_buf = reg_rf;
    default: AHB_wr_data_word_buf = 32'h0;
    endcase
end
always @* begin
    case ( cmd_AHB_size )
    //2'b00: AHB_wr_data_buf = AHB_wr_data_word_buf;
    2'b10: AHB_wr_data_buf = AHB_addr[1] ? { 16'h0, AHB_wr_data_word_buf[31:16] } : { 16'h0, AHB_wr_data_word_buf[15:0] };
    2'b11: AHB_wr_data_buf = AHB_addr[1:0] == 2'b11 ? { 24'h0, AHB_wr_data_word_buf[31:24] }    :
                             AHB_addr[1:0] == 2'b10 ? { 24'h0, AHB_wr_data_word_buf[23:16] }    :
                             AHB_addr[1:0] == 2'b01 ? { 24'h0, AHB_wr_data_word_buf[15: 8] }    :
                                                      { 24'h0, AHB_wr_data_word_buf[ 7: 0] }    ;
    default: AHB_wr_data_buf = AHB_wr_data_word_buf;
    endcase
end
assign  AHB_wr_data     = AHB_wr_data_buf;
assign  AHB_size        = cmd_AHB_size == 2'b00 ? 2'b10 :
                          cmd_AHB_size == 2'b10 ? 2'b01 :
                                                  2'b00 ;
always @* begin
    case ( cmd_AHB_size )
    //2'b00: result_AHBrd_buf = AHB_rd_data;
    2'b10: result_AHBrd_buf = cmd_AHB_ldrs_s ? { 16{AHB_rd_data[15]}, AHB_rd_data[15:0] } : { 16'h0, AHB_rd_data[15:0] } ;
    2'b11: result_AHBrd_buf = cmd_AHB_ldrs_s ? { 24{AHB_rd_data[7]}, AHB_rd_data[7:0] } : { 24'h0, AHB_rd_data[7:0] } ;
    default: result_AHBrd_buf = AHB_rd_data;
    endcase
end











endmodule