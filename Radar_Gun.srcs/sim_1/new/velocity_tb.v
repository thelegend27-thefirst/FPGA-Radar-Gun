`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2026 01:01:51 PM
// Design Name: 
// Module Name: velocity_tb
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


module velocity_tb();
reg clk,rst,Doppler_In;
reg  [19:0] sim_period;
wire [10:0] frequency;
wire [9:0] velocity;
wire dp;
wire [6:0] cathode;
wire [7:0] anode;

top_for_tb uut(clk, rst, Doppler_In, frequency, velocity, dp, cathode, anode);

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
