// balance_reg.v (uses your adder module ports A,B,SUM,CARRY_OUT)
module balance_reg (
    input  wire       clk,
    input  wire       reset,       // synchronous reset
    input  wire       add_en,      // add coin enable
    input  wire [3:0] add_value,   // decoded coin value
    input  wire       clear_en,    // clear balance (vend done or cancel)
    output reg  [3:0] balance
);
    wire [3:0] sum_next;
    wire carry_out_unused;

    // instantiate your adder (parameter N defaults to 4)
    adder u_adder (
        .A(balance),
        .B(add_value),
        .SUM(sum_next),
        .CARRY_OUT(carry_out_unused)
    );

    always @(posedge clk) begin
        if (reset) begin
            balance <= 4'd0;
        end else if (clear_en) begin
            balance <= 4'd0;
        end else if (add_en) begin
            balance <= sum_next;
        end else begin
            balance <= balance;
        end
    end
endmodule
