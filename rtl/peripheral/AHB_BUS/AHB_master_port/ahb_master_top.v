module ahb_master_top(HCLK,HRESETn,core_size,core_add,core_data,core_writen,core_readen,error,valid,rdata,
                    HREADY,HRESP,HRDATA,HGRANT,HSIZE,HADDR,HWDATA,HWRITE,HTRANS,HBURST,HBUSREQ,HLOCK,HPROT);

input HCLK;
input HRESETn;

//input [66:0] datain;

input core_size；
input core_add;
input core_data;
input core_writen;
input core_readen;
output error;
output valid;
output [31:0] rdata;

input HREADY;
input [1:0] HRESP;
input [31:0] HRDATA;

input HGRANT;

output [2:0] HSIZE;
output [31:0] HADDR;
output [31:0] HWDATA;
output HWRITE;
output [1:0] HTRANS;
output [2:0] HBURST;
output [3:0] HPROT;

output HBUSREQ;
output HLOCK;

wire [66:0] dataout;
wire empty;
wire full;
wire [66:0]datain;
wire fifo_writen;
wire fifo_readen;
wire tail_back;
wire [4:0] back_length;

ahb_master_port ahb_master_port(.HCLK(HCLK),.HRESETn(HRESETn),
                        .dataout(dataout),.empty(empty),.full(full),.datain(datain),
                        .fifo_writen(fifo_writen),.fifo_readen(fifo_readen),.tail_back(tail_back),.back_length(back_length),
                        .core_size(core_size),.core_add(core_add),.core_data(core_data),
                        .core_writen(core_writen),.core_readen(core_readen),.error(error),.valid(valid),.rdata(rdata),
                        .HREADY(HREADY),.HRESP(HRESP),.HRDATA(HRDATA),.HGRANT(HGRANT),.HSIZE(HSIZE),
                        .HADDR(HADDR),.HWDATA(HWDATA),.HWRITE(HWRITE),.HTRANS(HTRANS),.HBURST(HBURST),
								.HBUSREQ(HBUSREQ),.HLOCK(HLOCK),.HPROT(HPROT));

ahb_fifo ahb_fifo(.HCLK(HCLK),.HRESETn(HRESETn),.datain(datain),.writen(fifo_writen),.readen(fifo_readen),
                        .tail_back(tail_back),.back_length(back_length),.dataout(dataout),.empty(empty),.full(full));

endmodule




