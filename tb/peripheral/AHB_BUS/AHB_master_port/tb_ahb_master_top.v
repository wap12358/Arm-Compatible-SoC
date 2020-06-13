`timescale 1 ns/ 100 ps
module ahb_master_top_vlg_tst();

parameter cp_h = 5;         //half clk period
parameter cp = (2*cp_h);

reg HCLK;
reg HRESETn;

reg [66:0] datain;

reg core_writen;
reg core_readen;
wire error;
wire valid;
wire [31:0] rdata;

reg HREADY;
reg [1:0] HRESP;
reg [31:0] HRDATA;

reg HGRANT;

wire [2:0] HSIZE;
wire [31:0] HADDR;
wire [31:0] HWDATA;
wire HWRITE;
wire [1:0] HTRANS;
wire [2:0] HBURST;
wire [3:0] HPROT;

wire HBUSREQ;
wire HLOCK;

parameter single_data_1 = 67'h21111111111111111;
parameter single_data_2 = 67'h22222222222222222;
parameter single_data_3 = 67'h23333333333333333;
parameter single_data_4 = 67'h24444444444444444;

parameter INCR4_data_1 = 67'h41111111111111111;
parameter INCR4_data_2 = 67'h42222222222222222;
parameter INCR4_data_3 = 67'h43333333333333333;
parameter INCR4_data_4 = 67'h44444444444444444;


ahb_master_top dut(
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .datain(datain),
    .core_writen(core_writen),
    .core_readen(core_readen),
    .error(error),
    .valid(valid),
    .rdata(rdata),
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
    .HBUSREQ(HBUSREQ),
    .HLOCK(HLOCK),
    .HPROT(HPROT)
);

initial                                                
begin
HCLK = 1'b0;
HRESETn = 1'b0;
datain = 'd0;
core_writen = 1'b0;
core_readen = 1'b0;
HGRANT = 1'b0;
HREADY = 1'b1;
HRESP = 2'b00;
HRDATA = 'd0;

#6;
HRESETn = 1'b1;
#cp;
$display("Running testbench");          

test();     //need 450ns

end

always begin #cp_h HCLK = ~HCLK; end

task test();
begin
    write(single_data_1);
    write(single_data_2);
    write(single_data_3);
    write(single_data_4);
    
    //4 single transfer with wait state
    HGRANT = 1'b1;
    #(2*cp);
    HREADY = 1'b0;
    #(2*cp);
    HREADY = 1'b1;

    write(INCR4_data_1);
    write(INCR4_data_2);
    write(INCR4_data_3);
    write(INCR4_data_4);

    //degrant
    HGRANT = 1'b0;
    #(2*cp);
    HGRANT = 1'b1;
    #(3*cp);
    HGRANT = 1'b0;

    write(INCR4_data_1);
    write(INCR4_data_2);
    write(INCR4_data_3);
    write(INCR4_data_4);

    //retry
    HGRANT = 1'b1;
    #(2*cp);
    retry();
    #(3*cp);
    HGRANT = 1'b0;
    #(2*cp);

    //read
    read(single_data_1);
    HGRANT = 1'b1;
    #cp;
    HRDATA = 32'h12345678;
    #cp;
    HRDATA = 32'h00000000;

    write(INCR4_data_1);
    write(INCR4_data_2);
    write(INCR4_data_3);
    write(INCR4_data_4);

    //error
    slave_error();
    #(3*cp);
    HGRANT = 1'b0;
    #(2*cp);
end
endtask

task write(input[66:0] data); 
begin
    core_writen = 1'b1;
    datain = data;
    #cp;
    core_writen = 1'b0;
end
endtask

task read(input[66:0] data);
begin
    core_readen = 1'b1;
    datain = data;
    #cp;
end
endtask

always @(valid) core_readen = 1'b0;

//task grant();
//begin
//    HGRANT = 1'b1;
//    #cp;
//end
//endtask
//
//task degrant();
//begin
//    HGRANT = 1'b0;
//    #cp;
//end
//endtask
//
//task slave_wait();
//begin
//    HREADY = 1'b0;
//    #cp;
//end
//endtask
//
//task slave_ready();
//begin
//    HREADY = 1'b1;
//    #cp;
//end
//endtask

task slave_error();
begin
    HREADY = 1'b0;
    HRESP = 2'b00;
    #cp;
    HREADY = 1'b0;
    HRESP = 2'b01;
    #cp;
    HREADY = 1'b1;
    HRESP = 2'b01;
    #cp;
    HRESP = 2'b00;
end
endtask

task retry();
begin
    HREADY = 1'b0;
    HRESP = 2'b10;
    #cp;
    HREADY = 1'b1;
    HRESP = 2'b10;
    #cp;
    HRESP = 2'b00;
end
endtask

task split();
begin
    HREADY = 1'b0;
    HRESP = 2'b11;
    #cp;
    HREADY = 1'b1;
    HRESP = 2'b11;
    #cp;
    HRESP = 2'b00;
end
endtask

endmodule