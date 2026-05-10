`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2026 03:07:57 PM
// Design Name: 
// Module Name: frequency_measure_tb
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


module frequency_measure_tb();
reg clk,rst,Doppler_In;
reg  [19:0] sim_period;
wire [10:0] frequency;

measure_frequency_2 uut(clk, rst, Doppler_In, frequency);

always #5 clk = ~clk; //100 MHz clk

initial begin
    clk = 0;
    Doppler_In = 0;
    rst = 1;
    #20;
    rst = 0;
     // ~1 kHz (period = 500,000 ns so we toggle every 500,000 ns)
    sim_period = 500_000;
    repeat (10) #sim_period Doppler_In = ~Doppler_In;

    // ~2 kHz 
    sim_period = 250_000;
    repeat (10) #sim_period Doppler_In = ~Doppler_In;

    // ~500 Hz 
    sim_period = 1_000_000;
    repeat (10) #sim_period Doppler_In = ~Doppler_In;

    // ~800 Hz 
    sim_period = 625_000;
    repeat (10) #sim_period Doppler_In = ~Doppler_In;

    $stop;
    
end


endmodule
