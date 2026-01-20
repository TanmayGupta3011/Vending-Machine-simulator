// vending_controller.v  -- uses comparator gt/eq bits for >= detection
module vending_controller (
    input  wire       clk,
    input  wire       reset,
    input  wire [1:0] coin,     // 00=no coin, 01=1, 10=2, 11=5
    input  wire [1:0] select,   // 00 Chips(5), 01 Soda(7), 10 Juice(10)
    input  wire       cancel,
    output wire       dispense,
    output wire [3:0] change,   // change amount
    output wire [3:0] balance,  // visible balance
    output wire       busy
);
    wire [3:0] price;
    wire [3:0] coin_value;
    wire add_en, clear_en, refund_mode;
    wire [3:0] change_calc_val;

    // price selection
    price_select u_price (.select(select), .price(price));

    // coin decode (uses your provided module)
    coin_decode u_decode (.coin(coin), .value(coin_value));

    // balance register
    balance_reg u_balance (
        .clk(clk),
        .reset(reset),
        .add_en(add_en),
        .add_value(coin_value),
        .clear_en(clear_en),
        .balance(balance)
    );

    // comparator: now outputs eq and gt in out[0], out[1]
    wire [3:0] cmp_out;
    comparator #(4) u_cmp (.A(balance), .B(price), .out(cmp_out));
    // cmp_out[1] = gt, cmp_out[0] = eq
    wire balance_ge_price;
    assign balance_ge_price = (cmp_out[1] | cmp_out[0]); // >=

    // change_calc: refund_mode selected by FSM
    change_calc u_change (
        .balance(balance),
        .price(price),
        .refund_mode(refund_mode),
        .change(change_calc_val)
    );

    // change_nonzero: whether there is positive change to return (balance > price)
    wire change_nonzero;
    assign change_nonzero = (cmp_out[1]); // strictly greater

    // instantiate FSM (your vending_fsm) - it will drive add_en/clear_en/refund_mode/dispense/busy
    vending_fsm u_fsm (
        .clk(clk),
        .reset(reset),
        .coin(coin),
        .cancel(cancel),
        .ge(balance_ge_price),
        .change_nonzero(change_nonzero),
        .add_en(add_en),
        .clear_en(clear_en),
        .refund_mode(refund_mode),
        .dispense(dispense),
        .busy(busy)
    );

    assign change = change_calc_val;

endmodule
