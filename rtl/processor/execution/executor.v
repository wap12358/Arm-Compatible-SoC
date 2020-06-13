

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


// register *************************************************************************
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

// parameter ***************************************************************************
// mode
parameter           parameter_mode_usr  =   5'b10000;
parameter           parameter_mode_sys  =   5'b11111;
parameter           parameter_mode_svc  =   5'b10011;
parameter           parameter_mode_fiq  =   5'b10001;
parameter           parameter_mode_irq  =   5'b10010;
parameter           parameter_mode_abt  =   5'b10111;
parameter           parameter_mode_und  =   5'b11011;

// important wire & register ********************************************************
// mode
wire                mode_usr    =   cpsr[4:0] == parameter_mode_usr;
wire                mode_sys    =   cpsr[4:0] == parameter_mode_sys;
wire                mode_svc    =   cpsr[4:0] == parameter_mode_svc;
wire                mode_fiq    =   cpsr[4:0] == parameter_mode_fiq;
wire                mode_irq    =   cpsr[4:0] == parameter_mode_irq;
wire                mode_abt    =   cpsr[4:0] == parameter_mode_abt;
wire                mode_und    =   cpsr[4:0] == parameter_mode_und;

// pipeline & work_en
reg                 work_en_bus_rd;
wire                work_en_bus_busy;
wire                work_en     =   work_en_external & work_en_bus_rd & work_en_bus_busy;
reg     [ 1: 0]     pipeline_en;

always @(posedge clk or negedge rst_n) begin
if(~rst_n)begin
    pipeline_en <= 2'b00; 
end else if(work_en) begin
    pipeline_en <= cmd_branch ? 2'b00 : {1'b1,pipeline_en[1]};
end
end

always @(posedge clk or negedge rst_n) begin
if (~rst_n) begin
    work_en_rd_bus  <= 1'b1;
end else begin
    work_en_bus_rd  <=  cmd_AHB_rd_en   ? 1'b0 :
                        bus_vld         ? 1'b1 :
                                          work_en_bus_rd;
end
end

assign  work_en_bus_busy = bus_busy;

// basic control logic ***************************************************************


// ALU & MUL **************************************************************************
executor_ALU alu(
    .en(),
    .opcode(),
    .op1(),
    .op2(),
    .c_in(),
    .result(),
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
    .result(),
    .N(),
    .Z(),
    .C(),
    .V()
);


// change value of register **********************************************************
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

end else begin

end
end

// data I/O ****************************************************************************



endmodule