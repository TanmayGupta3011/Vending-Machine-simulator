
module subtractor #(parameter N = 4) (
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    output wire [N-1:0] DIFF,
    output wire BORROW_OUT
);
    wire [N-1:0] B_inv;
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_not
            not n(B_inv[i], B[i]);
        end
    endgenerate
    wire [N:0] carry;
    assign carry[0] = 1'b1; 
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_fa
            wire axb;
            xor x1(axb, A[i], B_inv[i]);
            xor x2(DIFF[i], axb, carry[i]);
            wire aandb, bandc, a_and_c;
            and g1(aandb, A[i], B_inv[i]);
            and g2(bandc, B_inv[i], carry[i]);
            and g3(a_and_c, A[i], carry[i]);
            or  g4(carry[i+1], aandb, bandc, a_and_c);
        end
    endgenerate
    assign BORROW_OUT = ~carry[N];
endmodule
