// `timescale 1ns/1ps

// module tb_vending_controller_wait;
//     reg clk;
//     reg reset;
//     reg [1:0] coin;
//     reg [1:0] select;
//     reg cancel;

//     wire dispense;
//     wire [3:0] change;
//     wire [3:0] balance;
//     wire busy;

//     // DUT instance
//     vending_controller dut (
//         .clk(clk),
//         .reset(reset),
//         .coin(coin),
//         .select(select),
//         .cancel(cancel),
//         .dispense(dispense),
//         .change(change),
//         .balance(balance),
//         .busy(busy)
//     );

//     // clock generation
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk; // 10ns period
//     end

//     integer pass_count;
//     integer fail_count;

//     // Helper variables used inline
//     integer i;
//     integer found;
//     integer expected;
//     integer ok;

//     initial begin
//         // VCD
//         $dumpfile("waves.vcd");
//         $dumpvars(0, tb_vending_controller_wait);

//         pass_count = 0;
//         fail_count = 0;

//         // defaults
//         coin = 2'b00;
//         select = 2'b00;
//         cancel = 1'b0;

//         // reset
//         reset = 1'b1;
//         @(posedge clk);
//         @(posedge clk);
//         reset = 1'b0;
//         @(posedge clk);

//         // CASE1: Chips (price=5) -> 2+2+1
//         select = 2'b00;
//         coin = 2'b10; @(posedge clk); coin = 2'b00; @(posedge clk);
//         coin = 2'b10; @(posedge clk); coin = 2'b00; @(posedge clk);
//         coin = 2'b01; @(posedge clk); coin = 2'b00; @(posedge clk);

//         found = 0;
//         for (i = 0; i < 40; i = i + 1) begin
//             @(posedge clk);
//             if (dut.dispense) begin found = 1; i = 40; end
//         end
//         if (found) pass_count = pass_count + 1; else begin fail_count = fail_count + 1; $display("ASSERT FAIL: Case1 dispense at %0t", $time); end

//         expected = 0; ok = 0;
//         for (i = 0; i < 20; i = i + 1) begin @(posedge clk); if (change === expected) begin ok = 1; i = 20; end end
//         if (ok) pass_count = pass_count + 1; else begin fail_count = fail_count + 1; $display("ASSERT FAIL: Case1 change expected %0d, got %0d at %0t", expected, change, $time); end
//         @(posedge clk);

//         // CASE2: Soda (price=7) -> 5 + 5 => change 3
//         select = 2'b01;
//         coin = 2'b11; @(posedge clk); coin = 2'b00; @(posedge clk);
//         coin = 2'b11; @(posedge clk); coin = 2'b00; @(posedge clk);

//         found = 0;
//         for (i = 0; i < 60; i = i + 1) begin @(posedge clk); if (dut.dispense) begin found = 1; i = 60; end end
//         if (found) pass_count = pass_count + 1; else begin fail_count = fail_count + 1; $display("ASSERT FAIL: Case2 dispense at %0t", $time); end

//         expected = 3; ok = 0;
//         for (i = 0; i < 40; i = i + 1) begin @(posedge clk); if (change === expected) begin ok = 1; i = 40; end end
//         if (ok) pass_count = pass_count + 1; else begin fail_count = fail_count + 1; $display("ASSERT FAIL: Case2 change expected %0d, got %0d at %0t", expected, change, $time); end
//         @(posedge clk);

//         // CASE3: Juice (price=10) partial then fill
//         select = 2'b10;
//         coin = 2'b11; @(posedge clk); coin = 2'b00; @(posedge clk);
//         @(posedge clk); @(posedge clk);
//         if (dut.dispense) begin fail_count = fail_count + 1; $display("ASSERT FAIL: Case3 early dispense at %0t", $time); end else pass_count = pass_count + 1;

//         coin = 2'b10; @(posedge clk); coin = 2'b00; @(posedge clk);
//         coin = 2'b10; @(posedge clk); coin = 2'b00; @(posedge clk);
//         coin = 2'b01; @(posedge clk); coin = 2'b00; @(posedge clk);

//         found = 0;
//         for (i = 0; i < 80; i = i + 1) begin @(posedge clk); if (dut.dispense) begin found = 1; i = 80; end end
//         if (found) pass_count = pass_count + 1; else begin fail_count = fail_count + 1; $display("ASSERT FAIL: Case3 dispense at %0t", $time); end

//         expected = 0; ok = 0;
//         for (i = 0; i < 40; i = i + 1) begin @(posedge clk); if (change === expected) begin ok = 1; i = 40; end end
//         if (ok) pass_count = pass_count + 1; else begin fail_count = fail_count + 1; $display("ASSERT FAIL: Case3 change expected %0d, got %0d at %0t", expected, change, $time); end
//         @(posedge clk);

//         // CASE4: Cancel mid-transaction (refund)
//                 // CASE4: Cancel mid-transaction (refund)
//         select = 2'b00;
//         coin = 2'b10; @(posedge clk); coin = 2'b00; @(posedge clk);
//         coin = 2'b01; @(posedge clk); coin = 2'b00; @(posedge clk);

//         // press cancel for one cycle
//         cancel = 1'b1;
//         @(posedge clk);
//         // sample immediately (race-safe): see if change equals expected right at this post-edge
//         expected = 3; ok = 0;
//         if (change === expected) begin ok = 1; end
//         // deassert cancel (same as user interaction)
//         cancel = 1'b0;
//         // if not seen yet, wait up to 60 cycles for change to become expected
//         if (!ok) begin
//             for (i = 0; i < 60; i = i + 1) begin
//                 @(posedge clk);
//                 if (change === expected) begin ok = 1; i = 60; end
//             end
//         end
//         if (ok) pass_count = pass_count + 1; else begin fail_count = fail_count + 1; $display("ASSERT FAIL: Case4 refund expected %0d, got %0d at %0t", expected, change, $time); end
//         @(posedge clk);

//         // CASE5a: Soda exact 7 -> 5 + 2
//         select = 2'b01;
//         coin = 2'b11; @(posedge clk); coin = 2'b00; @(posedge clk);
//         coin = 2'b10; @(posedge clk); coin = 2'b00; @(posedge clk);

//         found = 0;
//         for (i = 0; i < 60; i = i + 1) begin @(posedge clk); if (dut.dispense) begin found = 1; i = 60; end end
//         if (found) pass_count = pass_count + 1; else begin fail_count = fail_count + 1; $display("ASSERT FAIL: Case5a dispense at %0t", $time); end

//         expected = 0; ok = 0;
//         for (i = 0; i < 40; i = i + 1) begin @(posedge clk); if (change === expected) begin ok = 1; i = 40; end end
//         if (ok) pass_count = pass_count + 1; else begin fail_count = fail_count + 1; $display("ASSERT FAIL: Case5a change expected %0d, got %0d at %0t", expected, change, $time); end
//         @(posedge clk);

//         // CASE5b: Chips overpay 6 -> insert 1 first then 5 to genuinely overpay
//                 // CASE5b: Chips overpay 6 -> insert 1 first then 5 to genuinely overpay
//         select = 2'b00;
//         coin = 2'b01; @(posedge clk); coin = 2'b00; @(posedge clk); // +1
//         coin = 2'b11; @(posedge clk); coin = 2'b00; @(posedge clk); // +5 -> total 6


//         found = 0;
//         for (i = 0; i < 120; i = i + 1) begin @(posedge clk); if (dut.dispense) begin found = 1; i = 120; end end
//         if (found) pass_count = pass_count + 1; else begin fail_count = fail_count + 1; $display("ASSERT FAIL: Case5b dispense at %0t", $time); end

//         expected = 1; ok = 0;
//         for (i = 0; i < 80; i = i + 1) begin @(posedge clk); if (change === expected) begin ok = 1; i = 80; end end
//         if (ok) pass_count = pass_count + 1; else begin fail_count = fail_count + 1; $display("ASSERT FAIL: Case5b change expected %0d, got %0d at %0t", expected, change, $time); end
//         @(posedge clk);

//         $display("SIM: PASS=%0d FAIL=%0d", pass_count, fail_count);
//         if (fail_count == 0) $display("ALL TESTS PASSED");
//         $finish;
//     end
// endmodule


























