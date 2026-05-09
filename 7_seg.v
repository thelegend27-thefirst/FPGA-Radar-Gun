`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 03:58:11 PM
// Design Name: 
// Module Name: 7_seg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seven_seg(
    input  wire clk,
    input  wire [9:0] value,      // example: 125 means 12.5
    output reg  [6:0] cathode,
    output reg        dp,
    output reg  [7:0] anode
);

    wire [3:0] hundreds;
    wire [3:0] tens;
    wire [3:0] ones;

    assign hundreds = value / 100;        // 1
    assign tens     = (value / 10) % 10;  // 2
    assign ones     = value % 10;         // 5

    reg [16:0] refresh_counter = 0;
    wire [1:0] digit_select = refresh_counter[16:15];

    reg [3:0] current_digit;

    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
    end

    always @(*) begin
        anode = 8'b11111111; // all off, active-low
        dp = 1'b1;           // decimal point off, active-low

        case (digit_select)
            2'd0: begin
                anode = 8'b11111110;      // rightmost digit
                current_digit = ones;     // 5
            end

            2'd1: begin
                anode = 8'b11111101;      // middle digit
                current_digit = tens;     // 2
                dp = 1'b0;                // decimal point after 2
            end

            2'd2: begin
                anode = 8'b11111011;      // left digit
                current_digit = hundreds; // 1
            end

            default: begin
                anode = 8'b11111111;
                current_digit = 4'd0;
            end
        endcase
    end

    always @(*) begin
        case (current_digit)
            4'd0: cathode = 7'b1000000;
            4'd1: cathode = 7'b1111001;
            4'd2: cathode = 7'b0100100;
            4'd3: cathode = 7'b0110000;
            4'd4: cathode = 7'b0011001;
            4'd5: cathode = 7'b0010010;
            4'd6: cathode = 7'b0000010;
            4'd7: cathode = 7'b1111000;
            4'd8: cathode = 7'b0000000;
            4'd9: cathode = 7'b0010000;
            default: cathode = 7'b1111111;
        endcase
    end

endmodule