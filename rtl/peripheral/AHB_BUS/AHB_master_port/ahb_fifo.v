//
//  Module: AHB master port fifo
//  Description:
//  This module serve for ahb_master_port
//



module ahb_fifo(HCLK,HRESETn,datain,writen,readen,tail_back,back_length,dataout,empty,full);

input           HCLK;
input           HRESETn;      
input[66:0]     datain;
input           writen;
input           readen;
input           tail_back;
input[4:0]      back_length;
output[66:0]    dataout;
output		    empty;
output	        full;

parameter       DEPTH = 4,
                MAX_COUNT = 4'b1111,              //定义地址最大值
                MIN_COUNT = 4'b0000;
               
reg                 empty_1;
reg                 full_1;
reg[66:0]           dataout_1;
reg[(DEPTH-1):0]    tail;                       //读指针
reg[(DEPTH-1):0]    head;                       //写指针
reg[(DEPTH-1):0]    count;
reg[66:0]           fifomem[0:MAX_COUNT];       //定义fifo存储器，16个67位的存储器

//读出操作
always @(posedge HCLK) begin
  if(HRESETn==0) begin
    dataout_1 <= 66'h00000000000000000;
  end
  else begin
    dataout_1 <= fifomem[tail];
  end
end

//写入数据
always @(posedge HCLK) begin
    if(HRESETn==1'b1 && writen == 1'b1 && full == 1'b0) begin
        fifomem[head]<=datain;
    end
end

//head指针递增
always @(posedge HCLK) begin
    if(HRESETn==1'b0) begin
        head <= MIN_COUNT;
    end
    else begin
        if(writen==1'b1 && full==1'b0) begin
        head<=head+1'b1;
        end
    end
end

//tail指针递增
always @(posedge HCLK) begin
    if(HRESETn==1'b0) begin
        tail <= MIN_COUNT;
    end
    else begin
        if(tail_back) begin
            tail <= tail - back_length;
        end
        else if(readen==1'b1 && empty==1'b0) begin
        tail<=tail+1'b1;
        end
    end
end

//计数器
always @(posedge HCLK) begin
    if(HRESETn==1'b0) begin
        count <= MIN_COUNT;
    end
    else begin
        if(tail_back) begin
           count <= count + back_length;
        end
        else begin
            case ({readen, writen})
            2'b00:
                count <= count;
            2'b01: 
                if (count != MAX_COUNT) 
                    count <= count + 1'b1;     //写状态时计数器进行加法计数
            2'b10: 
                if (count != MIN_COUNT)
                    count <= count - 1'b1;    //读状态时计数器进行减法计数
            2'b11:
                count <= count;
            endcase
        end
    end
end

//empty指针
always @(count) begin
   if (count == MIN_COUNT)
      empty_1 <= 1'b1;      //count为0时empty赋为1
   else
      empty_1 <= 1'b0;
end

//full指针
always @(count) begin
   if (count == MAX_COUNT)
      full_1 <= 1'b1;                     //计数到最大时full赋为1
   else
      full_1 <= 1'b0;
end

//输出
assign dataout = dataout_1;
assign empty = empty_1;
assign full = full_1; 

endmodule





