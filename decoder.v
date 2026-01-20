
module decoder #(parameter N = 2) (
    input  wire [N-1:0] sel,
    output wire [(2**N)-1:0] out
);
    
    wire [N-1:0] sel_n;
    genvar i, j, k;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_inv
            not u_not(sel_n[i], sel[i]);
        end
    endgenerate

    generate
        for (i = 0; i < (2**N); i = i + 1) begin : gen_out
            
            wire [N-1:0] terms;
            for (j = 0; j < N; j = j + 1) begin : gen_terms

                if (((i >> j) & 1) == 1) begin
                    buf b_term(terms[j], sel[j]);
                end else begin
                    buf b_term_n(terms[j], sel_n[j]);
                end
            end

            if (N == 1) begin : gen_and1
            
                assign out[i] = terms[0];
            end else begin : gen_and_tree
            
                wire [N-1:0] and_stage;
                assign and_stage[0] = terms[0];
                for (k = 1; k < N; k = k + 1) begin : gen_andchain
                    and u_and(and_stage[k], and_stage[k-1], terms[k]);
                end
                assign out[i] = and_stage[N-1];
            end
        end
    endgenerate
endmodule
