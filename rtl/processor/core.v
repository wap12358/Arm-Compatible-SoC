module core(
    clk, rst_n, cpu_en,
    rom_en, rom_addr, rom_data,
    ahb_en, ahb_wr_en, ahb_addr, ahb_wr_data, ahb_rd_data, ahb_rd_vld, ahb_busy, ahb_data_size
);


// external port *******************************************************/
// basic signal
input                   clk;
input                   rst_n;
input                   cpu_en;

// rom
output                  rom_en;
output      [31: 0]     rom_addr;
input       [31: 0]     rom_data;

// AHB
output                  ahb_en;
output                  ahb_wr_en;
output      [31: 0]     ahb_addr;
output      [31: 0]     ahb_wr_data;
input       [31: 0]     ahb_rd_data;
input                   ahb_rd_vld;
input                   ahb_busy;
output      [ 1: 0]     ahb_data_size;

// interrupt






// define wire & reg *****************************************************/
// basic control signal
reg                     work_en;
































endmodule