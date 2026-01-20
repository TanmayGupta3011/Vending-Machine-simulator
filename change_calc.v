// change_calc.v (fixed)
// Computes change for vend or refund.
// If refund_mode==1 => return full balance
// else => if balance >= price return (balance - price) else 0.

module change_calc (
    input  wire [3:0] balance,
    input  wire [3:0] price,
    input  wire       refund_mode, // 1: cancel/refund full balance, 0: vend-change
    output wire [3:0] change
);
    wire [3:0] diff;
    wire borrow_out;

    // subtractor module (uses ports A,B,DIFF,BORROW_OUT)
    subtractor u_sub (
        .A(balance),
        .B(price),
        .DIFF(diff),
        .BORROW_OUT(borrow_out)
    );

    // If borrow_out == 0 => balance >= price
    wire ge = ~borrow_out;

    wire [3:0] vend_change;
    assign vend_change = ge ? diff : 4'd0;

    // Build data bus for mux #(1,4): index 0 -> vend_change; index 1 -> balance
    wire [ (2**1)*4 - 1 : 0 ] data_bus;
    assign data_bus = { balance, vend_change }; // MSB chunk is balance

    // instantiate mux with N=1, DATAW=4
    mux #(1,4) u_mux_change (
        .sel(refund_mode),
        .data(data_bus),
        .out(change)
    );
endmodule
