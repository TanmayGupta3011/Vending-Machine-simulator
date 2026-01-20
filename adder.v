
module adder #(parameter N = 4) (
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    output wire [N-1:0] SUM,
    output wire CARRY_OUT
);
    wire [N:0] carry;
    assign carry[0] = 1'b0;
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_fulladder
            wire axb;
            xor x1(axb, A[i], B[i]);
            xor x2(SUM[i], axb, carry[i]);
            wire aandb, bandc, a_and_c;
            and g1(aandb, A[i], B[i]);
            and g2(bandc, B[i], carry[i]);
            and g3(a_and_c, A[i], carry[i]);
            or  g4(carry[i+1], aandb, bandc, a_and_c);
        end
    endgenerate
    assign CARRY_OUT = carry[N];
endmodule
