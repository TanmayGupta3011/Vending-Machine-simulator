`timescale 1ns/1ps

module tb_vending_controller_debug;
    reg clk;
    reg reset;
    reg [1:0] coin;
    reg [1:0] select;
    reg cancel;

    wire dispense;
    wire [3:0] change;
    wire [3:0] balance;
    wire busy;

    // DUT
    vending_controller dut (
        .clk(clk),
        .reset(reset),
        .coin(coin),
        .select(select),
        .cancel(cancel),
        .dispense(dispense),
        .change(change),
        .balance(balance),
        .busy(busy)
    );

    // clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Counters for pass/fail
    integer pass_count;
    integer fail_count;

    // simple monitor: print when interesting signals change
    reg [3:0] last_change;
    reg last_dispense;
    initial begin
        last_change = 4'hF;
        last_dispense = 1'b0;
        @(posedge clk);
        #1;
    end
    
    // print any time dispense pulses or change changes (and show internal DUT signals that exist)
    always @(posedge clk) begin
        #1;
        if (dispense && !last_dispense) begin
            $display("T:%0t  DISPENSE asserted. balance=%0d price=%0d change=%0d add_en=%b clear_en=%b refund_mode=%b",
                     $time, balance, dut.price, change, (dut.add_en), (dut.clear_en), (dut.refund_mode));
        end
        if (change !== last_change) begin
            $display("T:%0t  CHANGE updated. balance=%0d price=%0d change=%0d add_en=%b clear_en=%b refund_mode=%b",
                     $time, balance, dut.price, change, (dut.add_en), (dut.clear_en), (dut.refund_mode));
        end
        last_change = change;
        last_dispense = dispense;
    end

    initial begin
        $display("=== START DEBUG TB ===");
        $dumpfile("waves_debug.vcd");
        $dumpvars(0, tb_vending_controller_debug);

        pass_count = 0;
        fail_count = 0;

        // defaults and reset
        coin = 2'b00; select = 2'b00; cancel = 0;
        reset = 1'b1; @(posedge clk); @(posedge clk); reset = 1'b0; @(posedge clk);

        // ---- Case1: Chips (5) -> 2+2+1 ----
        $display("T:%0t CASE1 start: select=00 (Chips, price 5)", $time);
        select = 2'b00;
        coin = 2'b10; @(posedge clk); #1; $display("T:%0t  coin=2 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);
        coin = 2'b10; @(posedge clk); #1; $display("T:%0t  coin=2 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);
        coin = 2'b01; @(posedge clk); #1; $display("T:%0t  coin=1 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);

        repeat (60) @(posedge clk);

        // ---- Case2: Soda (7) -> 5 + 5 => change 3 ----
        $display("T:%0t CASE2 start: select=01 (Soda, price 7)", $time);
        select = 2'b01;
        coin = 2'b11; @(posedge clk); #1; $display("T:%0t  coin=5 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);
        coin = 2'b11; @(posedge clk); #1; $display("T:%0t  coin=5 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);

        repeat (120) @(posedge clk);

        // ---- Case3: Juice (10) partial then fill ----
        $display("T:%0t CASE3 start: select=10 (Juice, price 10)", $time);
        select = 2'b10;
        coin = 2'b11; @(posedge clk); #1; $display("T:%0t  coin=5 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);
        repeat (6) @(posedge clk);
        coin = 2'b10; @(posedge clk); #1; $display("T:%0t  coin=2 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);
        coin = 2'b10; @(posedge clk); #1; $display("T:%0t  coin=2 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);
        coin = 2'b01; @(posedge clk); #1; $display("T:%0t  coin=1 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);

        repeat (120) @(posedge clk);

        // ---- Case4: Cancel mid-transaction ----
        $display("T:%0t CASE4 start: select=00 (Chips) then cancel", $time);
        select = 2'b00;
        coin = 2'b10; @(posedge clk); #1; $display("T:%0t  coin=2 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);
        coin = 2'b01; @(posedge clk); #1; $display("T:%0t  coin=1 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);
        cancel = 1'b1; @(posedge clk); cancel = 1'b0; #1 $display("T:%0t  cancel pressed -> balance=%0d price=%0d", $time, balance, dut.price);

        repeat (120) @(posedge clk);

        // ---- Case5a: Soda exact 7 ----
        $display("T:%0t CASE5a start: select=01 (Soda)", $time);
        select = 2'b01;
        coin = 2'b11; @(posedge clk); #1; $display("T:%0t  coin=5 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);
        coin = 2'b10; @(posedge clk); #1; $display("T:%0t  coin=2 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);

        repeat (120) @(posedge clk);

        // ---- Case5b: Chips overpay 6 -> change 1 ----
        $display("T:%0t CASE5b start: select=00 (Chips)", $time);
        select = 2'b00;
        coin = 2'b11; @(posedge clk); #1; $display("T:%0t  coin=5 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);
        coin = 2'b01; @(posedge clk); #1; $display("T:%0t  coin=1 inserted -> balance=%0d price=%0d", $time, balance, dut.price);
        coin = 2'b00; @(posedge clk);

        repeat (200) @(posedge clk);

        $display("=== DEBUG TB DONE === PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule