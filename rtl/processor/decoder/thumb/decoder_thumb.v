module decoder_thumb(

    // basic signal
    clk, rst_n,

    // instruction 32bit
    code,

    // registers
    r0, r1, r2, r3,
    r4, r5, r6, r7,
    r8, r9, r10, r11,
    r12, r13, r14, r15,
    cpsr, spsr, 

);

input               clk, rst_n;

input   [31: 0]     code;

input   [31: 0]     r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, cpsr, spsr;




wire    [15: 0]     code16;

decoder_thumb_halfword_sel decoder_thumb_halfword_sel(
    .clk(clk),
    .rst_n(rst_n),
    .pc1(r15[1]),
    .code_full(code),
    .code_half(code16)
);








endmodule