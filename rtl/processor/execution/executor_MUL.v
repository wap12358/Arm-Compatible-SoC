module executor_MUL(
    
    en,

    mode,
    op1, op2, 
    ops_l, ops_h, 

    result,
    N, Z, C, V

);

// port ******************************************************
input   wire                en;
input   wire    [ 1: 0]     mode;
input   wire    [31: 0]     op1, op2, ops_l, ops_h;
output  wire    [63: 0]     result;
output  wire                N, Z, C, V;

// wire ******************************************************
wire    signed  [32: 0]     mul_in_a    =   { mode[0] ? op1[31] : 1'b0, op1 };
wire    signed  [32: 0]     mul_in_b    =   { mode[0] ? op2[31] : 1'b0, op2 };
wire    signed  [32: 0]     mul_in_s_s  =   { mode[0] ? ops_l[31] : 1'b0, ops_l };
wire    signed  [64: 0]     mul_in_s_l  =   { mode[0] ? ops_h[31] : 1'b0, ops_h, ops_l };
wire    signed  [64: 0]     mul_res_mul =   mul_in_a * mul_in_b;
wire    signed  [64: 0]     mul_res_acc =   mul_res_mul + ( mode[1] ? mul_in_s_l : mul_in_s_s );

assign  result  =   mul_res_acc;
assign  C       =   mode[1] ? mul_res_acc[64] : mul_res_acc[32];
assign  Z       =   mode[1] ? ~&mul_res_acc[63:0] : ~&mul_res_acc[31:0];
assign  N       =   mode[1] ? mul_res_acc[63] : mul_res_acc[31];
assign  V       =   mode[1] ? ( ( mul_res_mul[63] & mul_in_s_l[63] & ~mul_res_acc[63] ) | ( ~mul_res_mul[63] & ~mul_in_s_l[63] & mul_res_acc[63]) ) :
                              ( ( mul_res_mul[31] & mul_in_s_l[31] & ~mul_res_acc[31] ) | ( ~mul_res_mul[31] & ~mul_in_s_l[31] & mul_res_acc[31]) );
endmodule