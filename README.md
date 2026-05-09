# FPGA-Radar-Gun
FPGA Radar Gun project using a HB100 Doppler Radar Module 0~2mph

This project uses the HB100 Doppler Module to track speeds of different objects and displays it on the 7 segment display of the Nexys A7 FPGA board. To run this project open vivado, create a project, and add all the source v files to your sources and add the constraint file to constraints. Make sure top is selected as top module. Then just generate bitstream. The testbench files (frequency_measure_tb, velocity_tb, & top_for_tb) are not required to compile code, they are just there for simulation waveform verification if you are interested in that. Also top_for_tb should go in design sources not simulation sources if you are doing verification. After you have flashed the bitstream the Nexys A7 FPGA, build the circuit provided. You will need op-amps (I used MCP6002, but any op-amp works), resistors, and capacitors (electrolytic and ceramic). Connect the output of the circuit to JD1 of the FPGA. Also connect gnd of circuit to gnd of JD pmod. You can use the 3D printed chasis I have provided, though you will need double-sided tape for the HB100 and FPGA legs. 

# Project Overview
This project uses the HB100 Doppler Module. The module sends out radio waves and receives them. Due to the doppler effect, the radio waves sent back will have a shift in frequency. The module will output that change in frequency as an analog signal. The analog signal will then go through a circuit that will amplify it and convert it from analog to digital. It will then go into the FPGA board which will measure the frequency of the input signal and use a formula to calculate speed. The speed will be displayed on the 7 segment display. 

# System Architecture 
<img width="1444" height="876" alt="image" src="https://github.com/user-attachments/assets/5c99752d-612e-42db-b840-465ba2fbcd6c" />
The output of the HB100 is a tiny analog signal (mV~uV) at a certain frequency. That frequency is the doppler effect frequency and exactly what we need to input into our formula. The output is so small and the FPGA can not read it. We will need to amplify it with a circuit. Here is how the circuit works. The analog signal first goes through a capacitor which filters out any DC offset from the HB100 because we only care about the AC part of the signal (1). Then we introduce a voltage divider to set a midpoint at 1.65v (3.3v/2). The midpoint is used because everything above the midpoint will be considered “high” and everything below will be “low” (2). After that our signal goes through a non-inveriting op amp which amplifies the signal 100x (3). Then a second non-inverting op amp turns the signal into a complete square wave (4). In the end we have a square wave at a frequency that is equivalent to the frequency of the doppler effect. Now we have to measure the frequency of the square wave which will be done inside the FPGA. 

# Interfaces & Peripherals Used
<img width="1988" height="403" alt="image" src="https://github.com/user-attachments/assets/447623e7-4806-42ef-9052-fe4cad014d83" />
To measure frequency the strategy I implemented was using a timer to count to the time between rising edges then using the formula f=1/T to measure frequency. I implemented a timer using the internal 100Mhz clk of the FPGA board. I used a loop so that at every posedge of the clk, I’d increment a counter by 1. This counter just counts. I then used another loop where at every posedge of the input signal, the counter would start, wait for the next posedge, stop, and output the count. Now what we have to do is multiply this count by .0000001 as each posedge of the clk is equal to .0000001s or 10 nano seconds. Then I divided 1 by the count to get frequency. However, this process simplifies to 100Mhz / count, so that is what I ended up using to get frequency. 

To convert frequency to speed the formula v=f*lamda/2. Lamda is the wavelength of the original wave, it is found using lamda=vf where v is equal to the speed of light. It varies across radar guns, our HB100 operates at 10.525 GHz and therefore lamda = .0285 in our case. A problem I faced was that the FPGA can not do floats so I had to modify the formula. I just ended up doing all the calculations with a decimal point over. For example a speed of 12.5 will be calculated as 125. Which is fine because we actually need it in this form for the 7 segment display later. The modified equation I used is v=(f  * 285) + 10002000. The +1000 is there because the FPGA always rounds down, so +1000 ensures proper rounding. I then used v=(v * 2237) + 5001000 to convert m/s to mph (m/s * 2.23694 = mph). It uses the same modifications as the first formula for the same reasons. Here is a table to show conversion from frequency to speed so you get an idea.

Frequency (Hz)     Speed (mph)
10                  0.32
20                  0.64
30                  0.96
1600                51.04

Once we had our speed we needed to display onto the 7 segment display. However the 7 segment display on the Nexys A7 FPGA board only has one set of cathodes connected to all 8 anodes. This means that one number will display on all of the 7 segments and you can’t send different numbers to different 7 segments. To display a 3 digit speed, I needed to implement multiplexing on the 7 segment display.  What we do is we take our first digit, turn off all the anodes except for one, and display that digit. Then we take the next digit, turn off all the anodes except for the next anode, and display the second digit. Same thing for the 3rd digit. The FPGA board does this so fast that it looks like all 3 digits are being displayed at the same time and you can see a clear speed. 

# Verification & Testing
<img width="1937" height="337" alt="image" src="https://github.com/user-attachments/assets/b54d585b-2c02-4387-a962-49435e36d75e" />
For verification I did both software and hardware verification. For software verification I simulated different input frequencies being imputed into the FPGA board. I did it by creating a testbench and toggling the input at a fixed rate. To find how often I need to toggle, I would take the frequency I want to simulate input it into T=1f. This would give us the time for one period, then I would divide that by 2 to get the toggle delay. 

I noticed that during transitions, the FPGA would output speeds in between 2 frequencies. This is because it would read the rising edge of one frequency than read the rising edge of a different frequency, resulting in a speed in between. This was fine though as it just showed acceleration and deceleration. Note that speeds on waveform are 1 magnitude lower than displayed i.e. 320 = 32.0mph.

For hardware verification I did physical testing with the FPGA board, circuit, and module. I made all the connections using a breadboard and began rolling objects in front of the HB100. Something that I found really helpful was using an oscilloscope. The oscilloscope would display what’s happening with the signal and was very helpful with debugging. You can also see on the oscilloscope our circuit amplification as it takes a tiny signal in mV and amplifies it to a 3.3v square wave.

<img width="420" alt="image" src="https://github.com/user-attachments/assets/ea6c83ef-1f29-4193-b169-66730f54a483" />

<img width="300" alt="image" src="https://github.com/user-attachments/assets/545934c4-fa68-412c-9e12-38e6f9fbb3a3" />

# Conclusion
In this project, I successfully designed and implemented an FPGA-based radar speedometer using the HB100 Doppler module. The system was able to detect motion, process the resulting Doppler frequency shift, and convert it into a readable speed displayed on a 7-segment display. This required integrating analog signal conditioning, digital frequency measurement, and hardware-based computation on the FPGA. Through both simulation and hardware testing, I verified that my design functioned as intended.
However, the overall performance of the system was limited by the HB100 module. The maximum output frequency observed was significantly lower than expected, restricting measurable speeds to approximately 0–2 mph. While the signal processing and FPGA implementation were correct, this hardware limitation prevented the system from being used for higher-speed applications such as vehicle detection.
In future work, this limitation could be addressed by selecting a Doppler module with a higher output frequency range or by improving the sensitivity and amplification stages of the circuit. Additionally, implementing more advanced signal processing techniques or filtering could improve accuracy and noise resilience. Despite its limitations, this project provided valuable experience in combining analog and digital design, working with real-world signals, and implementing mathematical models on FPGA hardware.

https://www.youtube.com/watch?v=i8uyQCpuomU

https://www.youtube.com/watch?v=ts4kDAqrsdw

