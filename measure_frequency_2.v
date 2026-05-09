`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2026 10:31:27 PM
// Design Name: 
// Module Name: measure_frequency_2
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


module measure_frequency_2(
    input clk,
    input rst,
    input doppler_in,
    output [10:0] frequency
);
    reg [31:0] time_out;
    reg [31:0] counter;
    reg doppler_in_last;

    wire rising_edge = doppler_in & ~doppler_in_last;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter  <= 0;
            time_out <= 0;
            doppler_in_last <= 0;
        end else begin
            doppler_in_last <= doppler_in;

            if (rising_edge) begin
                time_out <= counter;
                counter  <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
    
    assign frequency = 100_000_000/time_out;

endmodule
