// vending_fsm.v
module vending_fsm (
    input  wire       clk,
    input  wire       reset,        // synchronous
    input  wire [1:0] coin,         // raw coin bits (to detect "coin present")
    input  wire       cancel,
    input  wire       ge,           // balance >= price (from comparator)
    input  wire       change_nonzero,
    output reg        add_en,       // enable add coin to balance
    output reg        clear_en,     // clear balance (after vend or cancel)
    output reg        refund_mode,  // 1 for cancel/refund, 0 for vend change
    output reg        dispense,     // one-cycle pulse
    output reg        busy
);
    typedef enum reg [2:0] {
        IDLE            = 3'd0,
        ACCEPT_COINS    = 3'd1,
        CHECK_BALANCE   = 3'd2,
        DISPENSE        = 3'd3,
        RETURN_CHANGE   = 3'd4,
        CANCEL_STATE    = 3'd5
    } state_t;

    reg [2:0] state, next;

    wire coin_present = (coin != 2'b00);

    // state register
    always @(posedge clk) begin
        if (reset) state <= IDLE;
        else state <= next;
    end

    // next-state + outputs
    always @* begin
        add_en = 1'b0;
        clear_en = 1'b0;
        refund_mode = 1'b0;
        dispense = 1'b0;
        busy = 1'b1;
        next = state;

        case (state)
        IDLE: begin
            busy = 1'b0;
            if (cancel) begin
                // nothing to refund; stay IDLE
                next = IDLE;
            end else if (coin_present) begin
                add_en = 1'b1;
                next = CHECK_BALANCE;
            end else begin
                next = IDLE;
            end
        end
        ACCEPT_COINS: begin
            if (cancel) next = CANCEL_STATE;
            else if (coin_present) begin
                add_en = 1'b1;
                next = CHECK_BALANCE;
            end else next = ACCEPT_COINS;
        end
        CHECK_BALANCE: begin
            if (cancel) next = CANCEL_STATE;
            else if (ge) next = DISPENSE;
            else next = ACCEPT_COINS;
        end
        DISPENSE: begin
            dispense = 1'b1;
            if (change_nonzero) begin
                refund_mode = 1'b0; // vend-change
                next = RETURN_CHANGE;
            end else begin
                clear_en = 1'b1; // exact pay
                next = IDLE;
            end
        end
        RETURN_CHANGE: begin
            clear_en = 1'b1;
            next = IDLE;
        end
        CANCEL_STATE: begin
            refund_mode = 1'b1;
            clear_en = 1'b1;
            next = IDLE;
        end
        default: next = IDLE;
        endcase
    end
endmodule
