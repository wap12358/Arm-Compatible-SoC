//
//  Module: AHB master port
//  Description:
//  Receives the master's signal and outputs the signal in compliance with the AHB bus specification
//



module ahb_master_port(HCLK,HRESETn,dataout,empty,full,datain,fifo_writen,fifo_readen,tail_back,back_length,
                    core_size,core_add,core_data,core_writen,core_readen,error,busy,valid,rdata,
                    HREADY,HRESP,HRDATA,HGRANT,HSIZE,HADDR,HWDATA,HWRITE,HTRANS,HBURST,HBUSREQ,HLOCK,HPROT);

input HCLK;
input HRESETn;

//FIFO control
//input [66:0] datain;
input [66:0] dataout;
input empty;
input full;
output [66:0]datain;
output fifo_writen;
output fifo_readen;
output tail_back;
output [4:0] back_length;

//core control
input core_size;
input core_add;
input core_data;
input core_writen;
input core_readen;
output error;//if HRESP is ERROR, error will be high.
output busy;//when fifo is full
output valid;//when bus transfer rdata to core, valid will be high in one cycle
output [31:0] rdata;

//in from slave
input HREADY;
input [1:0] HRESP;
input [31:0] HRDATA;

//in from arbiter
input HGRANT;

//out to mux
output [2:0] HSIZE;
output [31:0] HADDR;
output [31:0] HWDATA;
output HWRITE;
output [1:0] HTRANS;
output [2:0] HBURST;
output [3:0] HPROT;

//out to arbiter
output HBUSREQ;
output HLOCK;

//***********************************************************************************************//

//reg define

reg         fifo_readen_1;
reg [3:0]   back_length_1;
reg [2:0]   HSIZE_1;
reg [31:0]  HADDR_1;
reg [1:0]   HTRANS_1;
reg [2:0]   HBURST_1;

reg [31:0]  data_buf;

reg [3:0]   count;

reg is_read;                //master is reading
reg is_work;                //master is writing or reading
reg is_break;               //master lose the grant when a burst do not complete
reg is_waitting_rdata;      //master is waiting for rdata
reg is_single_pipeline;

//***********************************************************************************************//

//output logic

//fifo_datain
assign datain={core_size,core_add,core_data};

//fifo_writen
assign fifo_writen = core_writen;

//fifo_readen will be valid when HGRANT and HREADY are high and FIFO is not empty
assign fifo_readen = HGRANT && HREADY && (!empty);

//always @(posedge HCLK or negedge HRESETn) begin
//    if(!HRESETn) begin
//        fifo_readen_1 <= 1'b0;
//    end
//    else begin
//        if(HGRANT && HREADY && (!empty)) begin
//            fifo_readen_1 <= 1'b1;
//        end
//        else begin
//            fifo_readen_1 <= 1'b0;
//        end
//    end
//end

//tail_back
assign tail_back = (!HREADY && (HRESP == 2'b10 || HRESP == 2'b11));

//back_length
assign back_length = back_length_1;

always @(*) begin
    if(tail_back) begin
        case(HSIZE_1)
            3'b000:back_length_1 = 5'h2;
            3'b001:back_length_1 = 5'h2;
            3'b010:back_length_1 = 5'h2;
            3'b011:back_length_1 = 5'h2;
            3'b100:back_length_1 = 5'h5 - count;
            3'b101:back_length_1 = 5'h9 - count;
            3'b110:back_length_1 = 5'h11 - count;
            3'b111:back_length_1 = 5'h11 - count;
        endcase
    end
    else begin
        back_length_1 = 5'h0;
    end
end

//error
assign error = HRESP == 2'b01;

//busy
assign busy = full;

//valid
assign valid = HREADY && is_waitting_rdata;

//rdata
assign rdata = HRDATA;

//HSIZE AND HADDR
assign HSIZE = HSIZE_1;
assign HADDR = HADDR_1;


always @(*) begin
    if(is_read) begin
        HSIZE_1 = datain[66:64];
    end
    else begin
        HSIZE_1 = dataout[66:64];
    end
end

always @(*) begin
    if(is_read) begin
        HADDR_1 = datain[63:32];
    end
    else begin
        HADDR_1 = dataout[63:32];
    end
end

//HWDATA, since AHB BUS is two pipe pipeline, HWDATA should be one cycle later than HADDR.
assign HWDATA = data_buf[31:0];

always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn) begin
        data_buf <= 32'h00000000;
    end
    else begin
        data_buf <= dataout[31:0];
    end
end

//HWRITE
assign HWRITE =  (!is_read);

//HTRANS
assign HTRANS = HTRANS_1;

always @(posedge HCLK or negedge HRESETn) begin     //this core do not have busy state, reader can add it by yourself if you need.
    if(!HRESETn) begin
        HTRANS_1 <= 2'b00;
    end
    else begin
        if(HGRANT) begin
            if( HRESP == 2'b01 && !HREADY ||
                HRESP == 2'b10 && !HREADY ||
                HRESP == 2'b11 && !HREADY ) begin
                HTRANS_1 <= 2'b00;
            end
            else if(is_single_pipeline) begin
                HTRANS_1 <= 2'b10;
            end
            else if((HREADY && count == 4'h1) ||            //final beat in a burst, next cycle should give IDLE 
                    (!is_work)) begin
                HTRANS_1 <= 2'b00;       
            end
            else if(HREADY && HTRANS_1 == 2'b10) begin
                HTRANS_1 <= 2'b11;
            end
            else if(count == 4'h0) begin
                HTRANS_1 <= 2'b10;
            end
            else begin
                HTRANS_1 <= HTRANS_1;
            end
        end
    end
end

//HBURST
assign HBURST = HBURST_1;

always @(*) begin
    if(HTRANS_1 == 2'b10) begin
        case(HSIZE_1)
        3'b000:HBURST_1 = 3'h0;             //   8 bits， single
        3'b001:HBURST_1 = 3'h0;             //  16 bits， single
        3'b010:HBURST_1 = 3'h0;             //  32 bits， single
        3'b011:HBURST_1 = 3'h0;             //  64 bits， single
        3'b100:HBURST_1 = 3'h3;             // 128 bits， INCR4
        3'b101:HBURST_1 = 3'h5;             // 256 bits， INCR8
        3'b110:HBURST_1 = 3'h7;             // 512 bits， INCR16
        3'b111:HBURST_1 = 3'h7;             //1024 bits， INCR16
        endcase                             //this core do not choose warp or incr, we use incr as deafult
    end
    else if(is_break) begin
        HBURST_1 = 3'h1;                    //INCR, use Incrementing burst of unspecified length to transfer the rest data
    end
    else begin
        HBURST_1 = HBURST_1;
    end
end

//HPROT, this core do not need protect
assign HPROT = 4'h0;

//HBUSREQ will be valid when FIFO is not empty
assign HBUSREQ = is_work;

//HLOCK, this core would not lock, so HLOCK is always low.
assign HLOCK = 1'b0;

//***********************************************************************************************//

//other logic

//is_read, when core_readen is high, core will handover until ahb bus transfer rdata to core, core_readen will be high all the time.
always @(*) begin
    if(empty && core_readen) begin
        is_read = 1'b1;
    end
    else begin
        is_read = 1'b0;
    end
end

//is_work
always @(*) begin
    if(!empty || is_read) begin
        is_work = 1'b1;
    end
    else begin
        is_work = 1'b0;
    end
end

//counter
always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn) begin
        count <= 4'h0;  //count == 0 means master is not transfering.
    end
    else begin
        if( HRESP == 2'b01 && !HREADY ||
            HRESP == 2'b10 && !HREADY ||
            HRESP == 2'b11 && !HREADY ) begin
            count <= 4'h0;
        end
        else if(is_single_pipeline) begin
            count <= 4'h0;
        end
        else if(HTRANS_1 == 2'b10) begin
            case(HSIZE_1)
            3'b100:count <= 4'h3;   // 128 bits
            3'b101:count <= 4'h7;   // 256 bits
            3'b110:count <= 4'hf;   // 512 bits
            3'b111:count <= 4'hf;   //1024 bits  needs 32-beat, but we have only 16-beat burst.
            endcase
        end
        else if(HGRANT && HREADY && HTRANS_1 == 2'b11) begin
            count <= count - 1'b1;
        end
        else begin
            count <= count;
        end
        //if( HRESP == 2'b01 && !HREADY ||
        //    HRESP == 2'b10 && !HREADY ||
        //    HRESP == 2'b11 && !HREADY ||
        //    (HREADY && count == 5'h1 && HSIZE_1 != 3'h0 && HSIZE_1 != 3'h1 && HSIZE_1 != 3'h2) || 
        //    (!is_work)) begin
        //    count <= 5'h0;
        //end
        //else if(HREADY && (count == 5'h0 || (count == 5'h1 && (HSIZE_1 == 3'h0 || HSIZE_1 == 3'h1 || HSIZE_1 == 3'h2)))) begin
        //    case(HSIZE_1)
        //    3'b000:count <= 5'h1;   //   8 bits
        //    3'b001:count <= 5'h1;   //  16 bits
        //    3'b010:count <= 5'h1;   //  32 bits
        //    3'b011:count <= 5'h1;   //  64 bits
        //    3'b100:count <= 5'h4;   // 128 bits
        //    3'b101:count <= 5'h8;   // 256 bits
        //    3'b110:count <= 5'h10;  // 512 bits
        //    3'b111:count <= 5'h10;  //1024 bits  needs 32-beat, but we have only 16-beat burst.
        //    endcase
        //end
        //else if(count != 5'h0 && count != 5'h1|| (count == 5'h1 && HSIZE_1 != 3'h0 && HSIZE_1 != 3'h1 && HSIZE_1 != 3'h2)) begin
        //    count <= count - 1'b1;
        //end
        //else begin
        //    count <= count;
        //end
    end
end

//is_break
always @(*) begin
    if(!HGRANT && count != 4'h1 && count != 4'h0) begin
        is_break = 1'b1;
    end
    else begin
        is_break = 1'b0;
    end
end

//is_waitting_rdata
always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn) begin
        is_waitting_rdata <= 1'b0;
    end
    else begin
        if(is_waitting_rdata == 1'b1 && HREADY) begin
            is_waitting_rdata <= 1'b0;
        end
        else if(HGRANT && HREADY && is_read) begin
            is_waitting_rdata <= 1'b1;
        end
    end
end

//is_single_pipeline
always @(*) begin
    if(HSIZE_1 == 3'h4 || HSIZE_1 == 3'h5 || HSIZE_1 == 3'h6 || HSIZE_1 == 3'h7) begin
        is_single_pipeline = 1'b0;
    end
    else begin
        is_single_pipeline = 1'b1;
    end
end

endmodule




