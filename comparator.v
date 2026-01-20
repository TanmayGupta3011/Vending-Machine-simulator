// comparator.v  -- improved: outputs equality in bit0 and greater-than in bit1
module comparator #(parameter N = 4) (
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    output wire [N-1:0] out
);
    wire eq;
    wire gt;
    // equality
    assign eq = (A == B);
    // greater-than: uses arithmetic comparison (legal in Verilog-2001)
    assign gt = (A > B);

    // pack into out: LSB = eq, next bit = gt, rest zero
    generate
        if (N == 1) begin
            assign out = {  {N-1{1'b0}}, eq };
        end else begin
            assign out = { {N-2{1'b0}}, gt, eq };
        end
    endgenerate
endmodule
