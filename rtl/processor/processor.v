module processor(
    clk,rst_n,
    cpu_en,rom_en,rom_addr,rom_data,
    ir_cpu_restart,ir_irq,ir_fiq,
    HREADY,HRESP,HRDATA,HGRANT,HSIZE,HADDR,HWDATA,HWRITE,HTRANS,HBURST,HBUSREQ,HLOCK,HPROT
);


// external port *******************************************************/
// basic signal
input                   clk;
input                   rst_n;

// core and rom
input                   cpu_en;
output                  rom_en  =   work_en;
output      [31: 0]     rom_addr;
input       [31: 0]     rom_data;

// interrupt
input                   ir_cpu_restart;
input                   ir_irq;
input                   ir_fiq;

// AHB signal
input                   HREADY;
input       [ 1: 0]     HRESP;
input       [31: 0]     HRDATA;

input                   HGRANT;

output      [ 2: 0]     HSIZE;
output      [31: 0]     HADDR;
output      [31: 0]     HWDATA;
output                  HWRITE;
output      [ 1: 0]     HTRANS;
output      [ 2: 0]     HBURST;
output      [ 3: 0]     HPROT;

output                  HBUSREQ;
output                  HLOCK;

// wire *****************************************************************/
// AHB PORT control
wire                    ahb_rd_en;
wire                    ahb_wr_en;
wire        [ 2: 0]     ahb_size;
wire        [31: 0]     ahb_addr;
wire        [31: 0]     ahb_wr_data;
wire        [31: 0]     ahb_rd_data;
wire                    ahb_rd_vld;
wire                    ahb_busy;
wire                    ir_data_process;


core core(
    //basic signal
    .clk(clk),
    .rst_n(rst_n),
    .cpu_en(cpu_en),

    //rom
    .rom_en(rom_en),
    .rom_addr(rom_addr),
    .rom_data(rom_data),

    //interrupt
    .ir_cpu_restart(ir_cpu_restart),
    .ir_irq(ir_irq),
    .ir_fiq(ir_fiq),

    //AHB port control
    .ahb_rd_en(ahb_rd_en),
    .ahb_wr_en(ahb_wr_en),
    .ahb_size(ahb_size),
    .ahb_addr(ahb_addr),
    .ahb_wr_data(ahb_wr_data),
    .ahb_rd_data(ahb_rd_data),
    .ahb_rd_vld(ahb_rd_vld),
    .ahb_busy(ahb_busy),
    .ir_data_process(ir_data_process)

);

ahb_port ahb_master_top(
    //basic signal
    .HCLK(clk),
    .HRESETn(rst_n),

    //control from core
    .core_size(ahb_size),
    .core_add(ahb_addr),
    .core_data(ahb_wr_data),
    .core_writen(ahb_wr_en),
    .core_readen(ahb_rd_en),
    .error(ir_data_process),
    .busy(ahb_busy),
    .valid(ahb_rd_vld),
    .rdata(ahb_rd_data),

    //AHB signal
    .HREADY(HREADY),
    .HRESP(HRESP),
    .HRDATA(HRDATA),

    .HGRANT(HGRANT),

    .HSIZE(HSIZE),
    .HADDR(HADDR),
    .HWDATA(HWDATA),
    .HWRITE(HWRITE),
    .HTRANS(HTRANS),
    .HBURST(HBURST),
    .HPROT(HPROT),

    .HBUSREQ(HBUSREQ),
    .HLOCK(HLOCK)

);






endmodule