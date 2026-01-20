// price_select.v
// Use the provided mux module (your mux expects sel + wide data vector).
module price_select (
    input  wire [1:0] select,
    output wire [3:0] price
);
    // prices: 00 -> 5, 01 -> 7, 10 -> 10, default->0
    wire [3:0] p0 = 4'd5;
    wire [3:0] p1 = 4'd7;
    wire [3:0] p2 = 4'd10;
    wire [3:0] p3 = 4'd0;

    // build data bus: data[0*4 +:4] = p0, data[1*4 +:4] = p1, ...
    wire [(2**2)*4-1:0] data_bus;
    assign data_bus = { p3, p2, p1, p0 }; // p0 is LSB slice

    // instantiate mux with N=2 (sel width) and DATAW=4
    mux #(2,4) u_mux (
        .sel(select),
        .data(data_bus),
        .out(price)
    );
endmodule
