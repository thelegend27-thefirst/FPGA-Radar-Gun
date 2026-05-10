`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 04:02:58 PM
// Design Name: 
// Module Name: top
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


module top (
    input clk,
    input rst,
    input Doppler_In,
    //output [31:0] time_out,
    //output [10:0] frequency, // 11 bit so top displayable speed is 65mph
    //output [9:0] velocity,
    output dp,
    output [6:0] cathode,      // a,b,c,d,e,f,g
    output [7:0] anode        // digit enables
);
    wire [10:0] frequency; // 11 bit so top displayable speed is 65mph
    wire [9:0] velocity;
    wire [31:0] vel_calc;
    wire [9:0] velocity_meters_per_second;
    wire [31:0] mph_calc;
   
    
    //measure_frequency u1(clk, rst, Doppler_In, frequency);
    measure_frequency_2 u1(clk, rst, Doppler_In, frequency);
    
    
        //wavelength = speed of light/frequency - .0285m for 10.525 Ghz
    //velocity formula  v = frequency * wavelength / 2          
//assign velocity = frequency * 285 / 2 / 10_000;
    //verilog not allowing floats (.285) so we do 285 and divide by 1000
    
    assign vel_calc = frequency * 285;              // freq * 0.0285 * 10000
    assign velocity_meters_per_second = (vel_calc + 1000) / 2000;
    assign mph_calc = velocity_meters_per_second * 2237;
    assign velocity = (mph_calc + 500) / 1000;
    
    
    seven_seg u3 (
        .clk(clk),
        .value(velocity),
        .cathode(cathode),
        .dp(dp),
        .anode(anode)
    );


endmodule
