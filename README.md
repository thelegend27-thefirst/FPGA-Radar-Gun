# FPGA-Radar-Gun
FPGA Radar Gun project using a HB100 Doppler Radar Module 0~2mph

This project uses the HB100 Doppler Module to track speeds of different objects and displays it on the 7 segment display of the Nexys A7 FPGA board. To run this project open vivado, create a project, and add all the source v files to your sources and add the constraint file to constraints. Then just generate bitstream. The testbench files (frequency_measure_tb, velocity_tb, & top_for_tb) are not required to compile code, they are just there for simulation waveform verification if you are interested in that. After you have flashed the bitstream the Nexys A7 FPGA, build the circuit provided. You will need op-amps (I used MCP6002, but any op-amp works), resistors, and capacitors (electrolytic and ceramic). Connect the output of the circuit to JD1 of the FPGA. Also connect gnd of circuit to gnd of JD pmod. You can use the 3D printed chasis I have provided, though you will need double-sided tape for the HB100 and FPGA legs. 

# Project Overview
This project uses the HB100 Doppler Module. The module sends out radio waves and receives them. Due to the doppler effect, the radio waves sent back will have a shift in frequency. The module will output that change in frequency as an analog signal. The analog signal will then go through a circuit that will amplify it and convert it from analog to digital. It will then go into the FPGA board which will measure the frequency of the input signal and use a formula to calculate speed. The speed will be displayed on the 7 segment display. 

#System Architecture 
The output of the HB100 is a tiny analog signal (mV~uV) at a certain frequency. That frequency is the doppler effect frequency and exactly what we need to input into our formula. The output is so small and the FPGA can not read it. We will need to amplify it with a circuit. Here is how the circuit works. The analog signal first goes through a capacitor which filters out any DC offset from the HB100 because we only care about the AC part of the signal (1). Then we introduce a voltage divider to set a midpoint at 1.65v (3.3v/2). The midpoint is used because everything above the midpoint will be considered “high” and everything below will be “low” (2). After that our signal goes through a non-inveriting op amp which amplifies the signal 100x (3). Then a second non-inverting op amp turns the signal into a complete square wave (4). In the end we have a square wave at a frequency that is equivalent to the frequency of the doppler effect. Now we have to measure the frequency of the square wave which will be done inside the FPGA. 

#Interfaces & Peripherals Used



