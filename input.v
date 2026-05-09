`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 03:35:36 PM
// Design Name: 
// Module Name: input
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


module measure_frequency(
    input  clk,
    input  rst,
    input  Doppler_In,
    output [10:0] frequency
);
    reg [31:0] time_out;
    
    //timer
    reg [31:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    always @(posedge Doppler_In or posedge rst) begin
        if (rst)
            time_out <= 0;
        else begin
            time_out <= counter;
            counter  <= 0;   
        end
    end
    
    assign frequency = 100_000_000/time_out;
    
    
    //wavelength = speed of light/frequency - .0285m for 10.525 Ghz
    //velocity formula  v = frequency * wavelength / 2          
//assign velocity = frequency * 285 / 2 / 10_000;
    //verilog not allowing floats (.285) so we do 285 and divide by 1000
    
    //assign vel_calc = frequency * 285;              // freq * 0.0285 * 10000
    //assign velocity = (vel_calc + 1000) / 2000;
    
endmodule

