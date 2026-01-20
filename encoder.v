
module encoder #(parameter N = 2) (
    input  wire [(2**N)-1:0] in,
    output reg  [N-1:0] out
);
    integer i;
    always @(*) begin
        out = {N{1'b0}};

        begin : loop_block
            for (i = 0; i < (2**N); i = i + 1) begin
                if (in[i]) begin
                    out = i[N-1:0];
                    disable loop_block; 
                end
            end
        end
    end
endmodule
