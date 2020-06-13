module decoder_code_code16(
    clk, rst_n,
    pc1,
    code_full, 
    code_half
);

input               clk;
input               pc1;

input   [31: 0]     code_full;
output  [15: 0]     code_half;

reg                 pc1_last;

always @( posedge clk or negedge rst_n ) begin
if ( ~rst_n )   pc1_last <= 1'b0;
else            pc1_last <= pc1;
end

assign  code_half = pc1_last ? code_full[31:16] : code_full[15: 0];

endmodule