
module mux #(parameter N = 2, parameter DATAW = 4) (
    input  wire [N-1:0] sel,
    input  wire [(2**N)*DATAW-1:0] data,
    output wire [DATAW-1:0] out
);

    wire [(2**N)-1:0] onehots;
    decoder #(N) dec(.sel(sel), .out(onehots));

    integer i, j;
    reg [DATAW-1:0] out_reg;
    always @(*) begin
        out_reg = {DATAW{1'b0}};
        for (i = 0; i < (2**N); i = i + 1) begin
            if (onehots[i]) begin
                out_reg = data[i*DATAW +: DATAW];
            end
        end
    end
    assign out = out_reg;
endmodule
