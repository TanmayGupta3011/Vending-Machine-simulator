// coin_decode.v
// decode 2-bit coin input into 4-bit integer value
module coin_decode (
    input  wire [1:0] coin,  // 00=no coin, 01=₹1, 10=₹2, 11=₹5
    output reg  [3:0] value
);
    always @* begin
        case (coin)
            2'b00: value = 4'd0;
            2'b01: value = 4'd1;
            2'b10: value = 4'd2;
            2'b11: value = 4'd5;
            default: value = 4'd0;
        endcase
    end
endmodule
