`timescale 1ns/1ps

module tb_vending_controller_wait;
    reg clk;
    reg reset;
    reg [1:0] coin;
    reg [1:0] select;
    reg cancel;

    wire dispense;
    wire [3:0] change;
    wire [3:0] balance;
    wire busy;

    // DUT instance
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

    // clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    integer pass_count;
    integer fail_count;
    integer i, found, expected, ok;

    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_vending_controller_wait);

        pass_count = 0;
        fail_count = 0;
        coin = 2'b00;
        select = 2'b00;
        cancel = 1'b0;

        // reset
        reset = 1'b1;
        @(posedge clk); @(posedge clk);
        reset = 1'b0;
        @(posedge clk);

        // -------------------- CASE 1 --------------------
        $display("\n=== CASE 1: Chips selected (price = 5) ===");
        select = 2'b00;
        coin = 2'b10; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.2 --> balance=%0d", dut.balance);
        coin = 2'b10; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.2 --> balance=%0d", dut.balance);
        coin = 2'b01; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.1 --> balance=%0d", dut.balance);

        found = 0;
        for (i=0;i<40;i=i+1) begin @(posedge clk);
            if (dispense) begin
                $display("Dispensing Chips! Change returned: %0d", change);
                found=1; i=40;
            end
        end
        if (found) pass_count++; else begin fail_count++; $display("ASSERT FAIL: Case1 dispense at %0t", $time); end
        @(posedge clk);

        // -------------------- CASE 2 --------------------
        $display("\n=== CASE 2: Soda selected (price = 7) ===");
        select = 2'b01;
        coin = 2'b11; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.5 --> balance=%0d", dut.balance);
        coin = 2'b11; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.5 --> balance=%0d", dut.balance);

        found=0;
        for (i=0;i<60;i=i+1) begin @(posedge clk);
            if (dispense) begin
                $display("Dispensing Soda! Change returned: %0d", change);
                found=1; i=60;
            end
        end
        if (found) pass_count++; else begin fail_count++; $display("ASSERT FAIL: Case2 dispense at %0t", $time); end
        @(posedge clk);

        // -------------------- CASE 3 --------------------
        $display("\n=== CASE 3: Juice selected (price = 10) ===");
        select = 2'b10;
        coin = 2'b11; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.5 --> balance=%0d", dut.balance);
        @(posedge clk); @(posedge clk);
        coin = 2'b10; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.2 --> balance=%0d", dut.balance);
        coin = 2'b10; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.2 --> balance=%0d", dut.balance);
        coin = 2'b01; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.1 --> balance=%0d", dut.balance);

        found=0;
        for (i=0;i<80;i=i+1) begin @(posedge clk);
            if (dispense) begin
                $display("Dispensing Juice! Change returned: %0d", change);
                found=1; i=80;
            end
        end
        if (found) pass_count++; else begin fail_count++; $display("ASSERT FAIL: Case3 dispense at %0t", $time); end
        @(posedge clk);

        // -------------------- CASE 4 --------------------
        $display("\n=== CASE 4: Cancel transaction (refund) ===");
        select = 2'b00;
        coin = 2'b10; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.2 --> balance=%0d", dut.balance);
        coin = 2'b01; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.1 --> balance=%0d", dut.balance);
        cancel = 1'b1; @(posedge clk);
        cancel = 1'b0;
        expected=3; ok=0;
        for (i=0;i<60;i=i+1) begin @(posedge clk);
            if (change===expected) begin
                $display("Cancel pressed --> refund Rs.%0d", change);
                ok=1; i=60;
            end
        end
        if (ok) pass_count++; else begin fail_count++; $display("ASSERT FAIL: Case4 refund expected %0d got %0d", expected, change); end
        @(posedge clk);

        // -------------------- CASE 5a --------------------
        $display("\n=== CASE 5a: Soda exact (5 + 2) ===");
        select = 2'b01;
        coin = 2'b11; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.5 --> balance=%0d", dut.balance);
        coin = 2'b10; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.2 --> balance=%0d", dut.balance);
        found=0;
        for (i=0;i<60;i=i+1) begin @(posedge clk);
            if (dispense) begin
                $display("Dispensing Soda! Change returned: %0d", change);
                found=1; i=60;
            end
        end
        if (found) pass_count++; else begin fail_count++; $display("ASSERT FAIL: Case5a dispense"); end
        @(posedge clk);

        // -------------------- CASE 5b --------------------
        $display("\n=== CASE 5b: Chips overpay (1 + 5) ===");
        select = 2'b00;
        coin = 2'b01; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.1 --> balance=%0d", dut.balance);
        coin = 2'b11; @(posedge clk); coin = 0; @(posedge clk); $display("Inserted Rs.5 --> balance=%0d", dut.balance);
        found=0;
        for (i=0;i<120;i=i+1) begin @(posedge clk);
            if (dispense) begin
                $display("Dispensing Chips! Change returned: %0d", change);
                found=1; i=120;
            end
        end
        if (found) pass_count++; else begin fail_count++; $display("ASSERT FAIL: Case5b dispense"); end
        @(posedge clk);

        $display("\n=== SIMULATION COMPLETE ===");
        $display("FINAL RESULT: PASS=%0d FAIL=%0d", pass_count, fail_count);
        if (fail_count==0) $display("ALL TESTS PASSED, MACHINE WORKING PERFECTLY!");
        else $display("SOME TESTS FAILED, CHECK LOG ABOVE");
        $finish;
    end
endmodule
