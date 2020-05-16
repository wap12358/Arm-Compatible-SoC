module op2_shifter(
    op2_before,
    op2_after,
    c_in,
    c_out,
    r0, r1, r2, r3,
    r4, r5, r6, r7,
    r8, r9, ra, rb,
    rc, rd, re, rf
);

input       [12: 0] op2_before;
output reg  [31: 0] op2_after;

input           c_in;
output reg      c_out;

input   [31:0]  r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, ra, rb, rc, rd, re, rf;

reg     [31: 0] number;
reg     [31: 0] shift_bit;
reg     [ 1: 0] shift_mode;

wire            eq32;
wire            lt32;

// number
always @* begin
if (op2_before[12]) begin
    number = { 24'h0, op2_before[7:0] };
end else begin
    case(op2_before[3:0])
    4'h0: number = r0;
    4'h1: number = r1;
    4'h2: number = r2;
    4'h3: number = r3;
    4'h4: number = r4;
    4'h5: number = r5;
    4'h6: number = r6;
    4'h7: number = r7;
    4'h8: number = r8;
    4'h9: number = r9;
    4'ha: number = ra;
    4'hb: number = rb;
    4'hc: number = rc;
    4'hd: number = rd;
    4'he: number = re;
    4'hf: number = rf;
    default: number = 32'h0;
    endcase
end
end


// shift_bit
always @* begin
if (op2_before[12]) begin
    shift_bit = { 27'h0, op2_before[11:8], 1'b0 };
end else begin
    if (op2_before[4]) begin
    case(op2_before[11:8])
    4'h0: shift_bit = r0;
    4'h1: shift_bit = r1;
    4'h2: shift_bit = r2;
    4'h3: shift_bit = r3;
    4'h4: shift_bit = r4;
    4'h5: shift_bit = r5;
    4'h6: shift_bit = r6;
    4'h7: shift_bit = r7;
    4'h8: shift_bit = r8;
    4'h9: shift_bit = r9;
    4'ha: shift_bit = ra;
    4'hb: shift_bit = rb;
    4'hc: shift_bit = rc;
    4'hd: shift_bit = rd;
    4'he: shift_bit = re;
    4'hf: shift_bit = rf;
    default: shift_bit = 32'h0;
    endcase
    end else begin
    shift_bit = { 27'h0, op2_before[11:7] };
    end
end
end


// shift_mode
always @* begin
if (op2_before[12]) begin
    shift_mode = 2'b11;
end else begin
    shift_mode = op2_before[6:5];
end
end


assign  eq32 = shift_bit == 32'd32;
assign  lt32 = ( ( |shift_bit[31:6] ) | ( shift_bit[5] & ( |shift_bit[4:0] ) ) );



// shifter
always @* begin
if ( shift_mode == 2'b00 ) begin
    c_out = c_in;
    if ( eq32 | lt32 ) op2_after = 32'h0;
    else begin
    case(shift_bit[4:0])
    5'd00: op2_after = number;
    5'd01: op2_after = { number[30: 0],  1'b0 };
    5'd02: op2_after = { number[29: 0],  2'b0 };
    5'd03: op2_after = { number[28: 0],  3'b0 };
    5'd04: op2_after = { number[27: 0],  4'b0 };
    5'd05: op2_after = { number[26: 0],  5'b0 };
    5'd06: op2_after = { number[25: 0],  6'b0 };
    5'd07: op2_after = { number[24: 0],  7'b0 };
    5'd08: op2_after = { number[23: 0],  8'b0 };
    5'd09: op2_after = { number[22: 0],  9'b0 };
    5'd10: op2_after = { number[21: 0], 10'b0 };
    5'd11: op2_after = { number[20: 0], 11'b0 };
    5'd12: op2_after = { number[19: 0], 12'b0 };
    5'd13: op2_after = { number[18: 0], 13'b0 };
    5'd14: op2_after = { number[17: 0], 14'b0 };
    5'd15: op2_after = { number[16: 0], 15'b0 };
    5'd16: op2_after = { number[15: 0], 16'b0 };
    5'd17: op2_after = { number[14: 0], 17'b0 };
    5'd18: op2_after = { number[13: 0], 18'b0 };
    5'd19: op2_after = { number[12: 0], 19'b0 };
    5'd20: op2_after = { number[11: 0], 20'b0 };
    5'd21: op2_after = { number[10: 0], 21'b0 };
    5'd22: op2_after = { number[ 9: 0], 22'b0 };
    5'd23: op2_after = { number[ 8: 0], 23'b0 };
    5'd24: op2_after = { number[ 7: 0], 24'b0 };
    5'd25: op2_after = { number[ 6: 0], 25'b0 };
    5'd26: op2_after = { number[ 5: 0], 26'b0 };
    5'd27: op2_after = { number[ 4: 0], 27'b0 };
    5'd28: op2_after = { number[ 3: 0], 28'b0 };
    5'd29: op2_after = { number[ 2: 0], 29'b0 };
    5'd30: op2_after = { number[ 1: 0], 30'b0 };
    5'd31: op2_after = { number[    0], 31'b0 };
    default: op2_after = 32'b0;
    endcase
    end
end else if ( shift_mode == 2'b01 ) begin
    c_out = c_in;
    if ( eq32 | lt32 ) op2_after = 32'h0;
    else begin
    case(shift_bit[4:0])
    5'd00: op2_after = number;
    5'd01: op2_after = {  1'b0, number[31: 1] };
    5'd02: op2_after = {  2'b0, number[31: 2] };
    5'd03: op2_after = {  3'b0, number[31: 3] };
    5'd04: op2_after = {  4'b0, number[31: 4] };
    5'd05: op2_after = {  5'b0, number[31: 5] };
    5'd06: op2_after = {  6'b0, number[31: 6] };
    5'd07: op2_after = {  7'b0, number[31: 7] };
    5'd08: op2_after = {  8'b0, number[31: 8] };
    5'd09: op2_after = {  9'b0, number[31: 9] };
    5'd10: op2_after = { 10'b0, number[31:10] };
    5'd11: op2_after = { 11'b0, number[31:11] };
    5'd12: op2_after = { 12'b0, number[31:12] };
    5'd13: op2_after = { 13'b0, number[31:13] };
    5'd14: op2_after = { 14'b0, number[31:14] };
    5'd15: op2_after = { 15'b0, number[31:15] };
    5'd16: op2_after = { 16'b0, number[31:16] };
    5'd17: op2_after = { 17'b0, number[31:17] };
    5'd18: op2_after = { 18'b0, number[31:18] };
    5'd19: op2_after = { 19'b0, number[31:19] };
    5'd20: op2_after = { 20'b0, number[31:20] };
    5'd21: op2_after = { 21'b0, number[31:21] };
    5'd22: op2_after = { 22'b0, number[31:22] };
    5'd23: op2_after = { 23'b0, number[31:23] };
    5'd24: op2_after = { 24'b0, number[31:24] };
    5'd25: op2_after = { 25'b0, number[31:25] };
    5'd26: op2_after = { 26'b0, number[31:26] };
    5'd27: op2_after = { 27'b0, number[31:27] };
    5'd28: op2_after = { 28'b0, number[31:28] };
    5'd29: op2_after = { 29'b0, number[31:29] };
    5'd30: op2_after = { 30'b0, number[31:30] };
    5'd31: op2_after = { 31'b0, number[31:31] };
    default: op2_after = 32'b0;
    endcase
    end
end else if ( shift_mode == 2'b10 ) begin
    c_out = c_in;
    if ( eq32 | lt32 ) op2_after = {32{number[31]}};
    else begin
    case(shift_bit[4:0])
    5'd00: op2_after = number;
    5'd01: op2_after = { { 1{number[31]}}, number[31: 1] };
    5'd02: op2_after = { { 2{number[31]}}, number[31: 2] };
    5'd03: op2_after = { { 3{number[31]}}, number[31: 3] };
    5'd04: op2_after = { { 4{number[31]}}, number[31: 4] };
    5'd05: op2_after = { { 5{number[31]}}, number[31: 5] };
    5'd06: op2_after = { { 6{number[31]}}, number[31: 6] };
    5'd07: op2_after = { { 7{number[31]}}, number[31: 7] };
    5'd08: op2_after = { { 8{number[31]}}, number[31: 8] };
    5'd09: op2_after = { { 9{number[31]}}, number[31: 9] };
    5'd10: op2_after = { {10{number[31]}}, number[31:10] };
    5'd11: op2_after = { {11{number[31]}}, number[31:11] };
    5'd12: op2_after = { {12{number[31]}}, number[31:12] };
    5'd13: op2_after = { {13{number[31]}}, number[31:13] };
    5'd14: op2_after = { {14{number[31]}}, number[31:14] };
    5'd15: op2_after = { {15{number[31]}}, number[31:15] };
    5'd16: op2_after = { {16{number[31]}}, number[31:16] };
    5'd17: op2_after = { {17{number[31]}}, number[31:17] };
    5'd18: op2_after = { {18{number[31]}}, number[31:18] };
    5'd19: op2_after = { {19{number[31]}}, number[31:19] };
    5'd20: op2_after = { {20{number[31]}}, number[31:20] };
    5'd21: op2_after = { {21{number[31]}}, number[31:21] };
    5'd22: op2_after = { {22{number[31]}}, number[31:22] };
    5'd23: op2_after = { {23{number[31]}}, number[31:23] };
    5'd24: op2_after = { {24{number[31]}}, number[31:24] };
    5'd25: op2_after = { {25{number[31]}}, number[31:25] };
    5'd26: op2_after = { {26{number[31]}}, number[31:26] };
    5'd27: op2_after = { {27{number[31]}}, number[31:27] };
    5'd28: op2_after = { {28{number[31]}}, number[31:28] };
    5'd29: op2_after = { {29{number[31]}}, number[31:29] };
    5'd30: op2_after = { {30{number[31]}}, number[31:30] };
    5'd31: op2_after = { {31{number[31]}}, number[31:31] };
    default: op2_after = 32'b0;
    endcase
    end
end else begin
    if ( shift_bit == 32'h0 ) begin op2_after = number; c_out = c_in; end
    else begin
    case(shift_bit[4:0])
    5'd00: begin op2_after = number; c_out = number[31]; end
    5'd01: begin op2_after = { number[    0], number[31: 1] }; c_out = number[ 0]; end
    5'd02: begin op2_after = { number[ 1: 0], number[31: 2] }; c_out = number[ 1]; end
    5'd03: begin op2_after = { number[ 2: 0], number[31: 3] }; c_out = number[ 2]; end
    5'd04: begin op2_after = { number[ 3: 0], number[31: 4] }; c_out = number[ 3]; end
    5'd05: begin op2_after = { number[ 4: 0], number[31: 5] }; c_out = number[ 4]; end
    5'd06: begin op2_after = { number[ 5: 0], number[31: 6] }; c_out = number[ 5]; end
    5'd07: begin op2_after = { number[ 6: 0], number[31: 7] }; c_out = number[ 6]; end
    5'd08: begin op2_after = { number[ 7: 0], number[31: 8] }; c_out = number[ 7]; end
    5'd09: begin op2_after = { number[ 8: 0], number[31: 9] }; c_out = number[ 8]; end
    5'd10: begin op2_after = { number[ 9: 0], number[31:10] }; c_out = number[ 9]; end
    5'd11: begin op2_after = { number[10: 0], number[31:11] }; c_out = number[10]; end
    5'd12: begin op2_after = { number[11: 0], number[31:12] }; c_out = number[11]; end
    5'd13: begin op2_after = { number[12: 0], number[31:13] }; c_out = number[12]; end
    5'd14: begin op2_after = { number[13: 0], number[31:14] }; c_out = number[13]; end
    5'd15: begin op2_after = { number[14: 0], number[31:15] }; c_out = number[14]; end
    5'd16: begin op2_after = { number[15: 0], number[31:16] }; c_out = number[15]; end
    5'd17: begin op2_after = { number[16: 0], number[31:17] }; c_out = number[16]; end
    5'd18: begin op2_after = { number[17: 0], number[31:18] }; c_out = number[17]; end
    5'd19: begin op2_after = { number[18: 0], number[31:19] }; c_out = number[18]; end
    5'd20: begin op2_after = { number[19: 0], number[31:20] }; c_out = number[19]; end
    5'd21: begin op2_after = { number[20: 0], number[31:21] }; c_out = number[20]; end
    5'd22: begin op2_after = { number[21: 0], number[31:22] }; c_out = number[21]; end
    5'd23: begin op2_after = { number[22: 0], number[31:23] }; c_out = number[22]; end
    5'd24: begin op2_after = { number[23: 0], number[31:24] }; c_out = number[23]; end
    5'd25: begin op2_after = { number[24: 0], number[31:25] }; c_out = number[24]; end
    5'd26: begin op2_after = { number[25: 0], number[31:26] }; c_out = number[25]; end
    5'd27: begin op2_after = { number[26: 0], number[31:27] }; c_out = number[26]; end
    5'd28: begin op2_after = { number[27: 0], number[31:28] }; c_out = number[27]; end
    5'd29: begin op2_after = { number[28: 0], number[31:29] }; c_out = number[28]; end
    5'd30: begin op2_after = { number[29: 0], number[31:30] }; c_out = number[29]; end
    5'd31: begin op2_after = { number[30: 0], number[   31] }; c_out = number[30]; end
    default: op2_after = 32'b0;
    endcase
    end
end
end


endmodule