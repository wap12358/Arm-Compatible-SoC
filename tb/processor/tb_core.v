`timescale 1 ns/1 ps
`define PERIOD 10
`define HALF_PERIOD (`PERIOD/2)
`define CODE_FILE "./test.bin"
`define ROM_SIZE 8
`define RAM_SIZE 8
module tb_core;

reg     clk = 1'b0;
always #`HALF_PERIOD clk = ~clk;

reg     rst_n = 1'b0;
initial #`PERIOD rst_n = 1'b1;

wire            rom_en;
wire [31:0]     rom_addr;
reg  [31:0]     rom_data;

wire            ahb_rd_en;
wire            ahb_wr_en;
wire    [31: 0] ahb_addr;
wire    [31: 0] ahb_wr_data;
reg     [31: 0] ahb_rd_data;
reg             ahb_rd_vld;
reg             ahb_busy;
wire    [ 1: 0] ahb_size;

core core(
    .clk(clk),
    .rst_n(rst_n),
    .cpu_en(1'b1),
    .rom_en(rom_en),
    .rom_addr(rom_addr),
    .rom_data(rom_data),
    .ahb_rd_en(ahb_rd_en),
    .ahb_wr_en(ahb_wr_en),
    .ahb_addr(ahb_addr),
    .ahb_wr_data(ahb_wr_data),
    .ahb_rd_data(ahb_rd_data),
    .ahb_rd_vld(ahb_rd_vld),
    .ahb_busy(ahb_busy),
    .ahb_size(ahb_size)
);


reg [31:0] rom[(1'b1<<`ROM_SIZE)-1:0];

integer fd,fx;
initial begin
  fd = $fopen(`CODE_FILE,"rb");
  fx = $fread(rom,fd);
  $fclose(fd);
end
	
always @ ( posedge clk )
if ( rom_en )
    rom_data <=  rom[rom_addr[`ROM_SIZE+1:2]];
else;


reg [31:0] data [(1'b1<<`RAM_SIZE)-1:0];
always @ ( posedge clk )
if ( ahb_rd_en )
    ahb_rd_data <=  data[ahb_addr[`RAM_SIZE+1:2]];
else;

always @ ( posedge clk )
if ( ahb_wr_en )
    data[ahb_addr[`RAM_SIZE+1:2]] <=  ahb_wr_data;
else;

always @ ( posedge clk )
if ( ahb_rd_en )
    ahb_rd_vld <= ahb_rd_en;
else;

endmodule
