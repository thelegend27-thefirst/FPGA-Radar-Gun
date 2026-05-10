`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2026 11:05:42 PM
// Design Name: 
// Module Name: Frequency_measure
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


module Frequency_measure (
    input  wire CLK100MHZ,
    input  wire radar_in,          // CLEAN digital square wave from comparator/Schmitt trigger
    input  wire resetn,            // active-low reset
    output reg  [7:0] AN,          // active-low digit enables
    output reg  CA, CB, CC, CD, CE, CF, CG, DP
);

    // ============================================================
    // Parameters
    // ============================================================
    localparam integer CLK_HZ            = 100_000_000;
    localparam integer HALF_SEC_TICKS    = 50_000_000;

    // HB100 at 10.525 GHz:
    // fd = 31.36 * mph
    // mph_tenths = (freq_hz * 10) / 31.36
    //            = (freq_hz * 1000) / 3136
    // freq_hz    = CLK_HZ / period_cycles
    //
    // So:
    // mph_tenths = (CLK_HZ * 1000) / (3136 * period_cycles)
    //
    // For 100 MHz clock:
    localparam integer MPH10_NUM         = 31_887_755; // approx (100_000_000*1000)/3136

    // Reject absurdly high values/noise
    localparam integer MAX_MPH10_VALID   = 9999;       // 999.9 mph max shown/accepted

    // ============================================================
    // Synchronize radar input into FPGA clock domain
    // ============================================================
    reg radar_ff1, radar_ff2, radar_ff3;

    always @(posedge CLK100MHZ) begin
        radar_ff1 <= radar_in;
        radar_ff2 <= radar_ff1;
        radar_ff3 <= radar_ff2;
    end

    wire radar_rise = (radar_ff2 == 1'b1) && (radar_ff3 == 1'b0);

    // ============================================================
    // Period measurement
    // ============================================================
    reg [31:0] cycle_counter = 0;
    reg [31:0] last_period   = 0;
    reg        period_valid  = 0;

    always @(posedge CLK100MHZ) begin
        if (!resetn) begin
            cycle_counter <= 0;
            last_period   <= 0;
            period_valid  <= 0;
        end else begin
            cycle_counter <= cycle_counter + 1;

            if (radar_rise) begin
                last_period   <= cycle_counter;
                cycle_counter <= 0;
                period_valid  <= (cycle_counter != 0);
            end
        end
    end

    // ============================================================
    // Convert one period reading into mph*10
    // ============================================================
    reg [31:0] mph10_now;

    always @(*) begin
        if (last_period != 0)
            mph10_now = MPH10_NUM / last_period;
        else
            mph10_now = 0;
    end

    // ============================================================
    // Half-second averaging
    // ============================================================
    reg [25:0] halfsec_counter = 0;

    reg [47:0] speed_sum   = 0;   // enough headroom
    reg [15:0] speed_count = 0;

    reg [31:0] avg_mph10   = 0;   // displayed value, mph*10

    always @(posedge CLK100MHZ) begin
        if (!resetn) begin
            halfsec_counter <= 0;
            speed_sum       <= 0;
            speed_count     <= 0;
            avg_mph10       <= 0;
        end else begin
            // accumulate valid readings on each new measured period
            if (radar_rise && period_valid) begin
                if ((mph10_now > 0) && (mph10_now <= MAX_MPH10_VALID)) begin
                    speed_sum   <= speed_sum + mph10_now;
                    speed_count <= speed_count + 1;
                end
            end

            // 0.5 second update
            if (halfsec_counter == HALF_SEC_TICKS - 1) begin
                halfsec_counter <= 0;

                if (speed_count != 0)
                    avg_mph10 <= speed_sum / speed_count;
                else
                    avg_mph10 <= 0;

                speed_sum   <= 0;
                speed_count <= 0;
            end else begin
                halfsec_counter <= halfsec_counter + 1;
            end
        end
    end

    // ============================================================
    // Convert avg_mph10 to 4 display digits: XXX.X
    // ============================================================
    reg [3:0] digit3, digit2, digit1, digit0; // digit0 is tenths

    integer temp;
    always @(*) begin
        temp   = avg_mph10;
        digit0 = temp % 10;       // tenths
        temp   = temp / 10;
        digit1 = temp % 10;       // ones
        temp   = temp / 10;
        digit2 = temp % 10;       // tens
        temp   = temp / 10;
        digit3 = temp % 10;       // hundreds
    end

    // ============================================================
    // 7-segment scan
    // Show on rightmost 4 digits, blank upper 4 digits
    // Active-low segments and anodes on Nexys A7
    // ============================================================
    reg [19:0] scan_counter = 0;
    always @(posedge CLK100MHZ) begin
        scan_counter <= scan_counter + 1;
    end

    wire [2:0] scan_sel = scan_counter[19:17];

    reg [3:0] seg_value;
    reg       seg_dp;
    reg [6:0] seg7;

    // Hex/decimal to 7-seg, active-low abcdefg
    always @(*) begin
        case (seg_value)
            4'd0: seg7 = 7'b0000001;
            4'd1: seg7 = 7'b1001111;
            4'd2: seg7 = 7'b0010010;
            4'd3: seg7 = 7'b0000110;
            4'd4: seg7 = 7'b1001100;
            4'd5: seg7 = 7'b0100100;
            4'd6: seg7 = 7'b0100000;
            4'd7: seg7 = 7'b0001111;
            4'd8: seg7 = 7'b0000000;
            4'd9: seg7 = 7'b0000100;
            default: seg7 = 7'b1111111; // blank
        endcase
    end

    always @(*) begin
        // defaults: everything off
        AN       = 8'b11111111;
        seg_value = 4'hF;       // blank
        seg_dp    = 1'b1;       // dp off (active-low)

        case (scan_sel)
            3'd0: begin
                AN        = 8'b11111110; // AN0 rightmost
                seg_value = digit0;      // tenths
                seg_dp    = 1'b1;        // no decimal point
            end
            3'd1: begin
                AN        = 8'b11111101; // AN1
                seg_value = digit1;      // ones
                seg_dp    = 1'b0;        // decimal point ON here => XX.X
            end
            3'd2: begin
                AN        = 8'b11111011; // AN2
                seg_value = digit2;      // tens
                seg_dp    = 1'b1;
            end
            3'd3: begin
                AN        = 8'b11110111; // AN3
                seg_value = digit3;      // hundreds
                seg_dp    = 1'b1;
            end
            3'd4: begin
                AN        = 8'b11101111; // AN4 blank
                seg_value = 4'hF;
                seg_dp    = 1'b1;
            end
            3'd5: begin
                AN        = 8'b11011111; // AN5 blank
                seg_value = 4'hF;
                seg_dp    = 1'b1;
            end
            3'd6: begin
                AN        = 8'b10111111; // AN6 blank
                seg_value = 4'hF;
                seg_dp    = 1'b1;
            end
            3'd7: begin
                AN        = 8'b01111111; // AN7 blank
                seg_value = 4'hF;
                seg_dp    = 1'b1;
            end
        endcase
    end

    always @(*) begin
        {CA, CB, CC, CD, CE, CF, CG} = seg7;
        DP = seg_dp;
    end

endmodule
