module executor_ALU(
    
    en,

    opcode,
    op1, op2, c_in,
    
    result,
    N, Z, C, V

);

input               en;

input   [ 3: 0]     opcode;
input   [31: 0]     op1, op2;
input               c_in;

output  [31: 0]     result;
output              N, Z, C, V;

wire    [32: 0]     result_OP1, result_OP2, result_AND, result_ORR, result_EOR, result_BIC, result_MVN, result_ADD, result_ADC, result_SUB, result_RSB, result_SBC, result_RSC;
wire    [31: 0]     op1_OP1, op1_AND, op1_ORR, op1_EOR, op1_BIC, op1_MVN, op1_ADD, op1_ADC, op1_SUB, op1_RSB, op1_SBC, op1_RSC;
wire    [31: 0]     op2_OP2, op2_AND, op2_ORR, op2_EOR, op2_BIC, op2_MVN, op2_ADD, op2_ADC, op2_SUB, op2_RSB, op2_SBC, op2_RSC;


// ALU_operation
parameter   OP1 = 4'h0;
parameter   OP2 = 4'h1;
parameter   AND = 4'h2;
parameter   ORR = 4'h3;
parameter   EOR = 4'h4;
parameter   BIC = 4'h5;
parameter   MVN = 4'h6;
parameter   ADD = 4'h8;
parameter   ADC = 4'h9;
parameter   SUB = 4'hc;
parameter   RSB = 4'ha;
parameter   SBC = 4'hd;
parameter   RSC = 4'hb;

assign  op1_OP1     =  ( opcode == OP1 ) ? op1 : 32'h0;
assign  op1_AND     =  ( opcode == AND ) ? op1 : 32'h0;
assign  op1_ORR     =  ( opcode == ORR ) ? op1 : 32'h0;
assign  op1_EOR     =  ( opcode == EOR ) ? op1 : 32'h0;
assign  op1_BIC     =  ( opcode == BIC ) ? op1 : 32'h0;
assign  op1_MVN     =  ( opcode == MVN ) ? op1 : 32'h0;
assign  op1_ADD     =  ( opcode == ADD ) ? op1 : 32'h0;
assign  op1_ADC     =  ( opcode == ADC ) ? op1 : 32'h0;
assign  op1_SUB     =  ( opcode == SUB ) ? op1 : 32'h0;
assign  op1_RSB     =  ( opcode == RSB ) ? op2 : 32'h0;
assign  op1_SBC     =  ( opcode == SBC ) ? op1 : 32'h0;
assign  op1_RSC     =  ( opcode == RSC ) ? op2 : 32'h0;

assign  op2_OP2     =  ( ( opcode == OP2 ) & en ) ? op2 : 32'h0;
assign  op2_AND     =  ( opcode == AND ) ? op2 : 32'h0;
assign  op2_ORR     =  ( opcode == ORR ) ? op2 : 32'h0;
assign  op2_EOR     =  ( opcode == EOR ) ? op2 : 32'h0;
assign  op2_BIC     =  ( opcode == BIC ) ? op2 : 32'h0;
assign  op2_MVN     =  ( opcode == MVN ) ? op2 : 32'h0;
assign  op2_ADD     =  ( opcode == ADD ) ? op2 : 32'h0;
assign  op2_ADC     =  ( opcode == ADC ) ? op2 : 32'h0;
assign  op2_SUB     =  ( opcode == SUB ) ? op2 : 32'h0;
assign  op2_RSB     =  ( opcode == RSB ) ? op1 : 32'h0;
assign  op2_SBC     =  ( opcode == SBC ) ? op2 : 32'h0;
assign  op2_RSC     =  ( opcode == RSC ) ? op1 : 32'h0;

assign  result_OP1  =  { ( ~opcode[3] ? c_in : 1'b0 ), op1_OP1 };
assign  result_OP2  =  { ( ~opcode[3] ? c_in : 1'b0 ), op2_OP2 };
assign  result_AND  =  { ( ~opcode[3] ? c_in : 1'b0 ), op1_AND & op2_AND };
assign  result_ORR  =  { ( ~opcode[3] ? c_in : 1'b0 ), op1_ORR | op2_ORR };
assign  result_EOR  =  { ( ~opcode[3] ? c_in : 1'b0 ), op1_EOR ^ op2_EOR };
assign  result_BIC  =  { ( ~opcode[3] ? c_in : 1'b0 ), op1_BIC & ( ~op2_BIC ) };
assign  result_MVN  =  { ( ~opcode[3] ? c_in : 1'b0 ), ~op2 };
assign  result_ADD  =  op1 + op2;
assign  result_ADC  =  op1 + op2 + c_in;
assign  result_SUB  =  { 1'b1, op1_SUB | op1_RSB } - ( op2_SUB | op2_RSB );
assign  result_SBC  =  { 1'b1, op1_SBC | op1_RSC } - ( op2_SBC | op2_RSC ) - ~c_in;

assign  {C,result}  =  result_OP1 | result_OP2 | result_AND | result_ORR | result_EOR | result_BIC | result_MVN | result_ADD | result_ADC | result_SUB | result_SBC;
assign  N           =  result[31];
assign  Z           =  ~|result;
assign  V           =  1'b0;

endmodule