`timescale 1ns / 1ps
/*
 * Engineer:     Matthew Pethick
 * Create Date:  27/10/2016
 * Last Edited:  08/11/2024
 * Module Name:  seg_7_display
 * Project Name: snake_game 
 * Description:  This module converts the binary number to display 
 *               onto the 7-segment displays on the FPGA
 */

module seg_7_display (
    input  [3:0] bin_in,
    input        seg_select,
    input        dot_in,
    output [3:0] seg_select_out,
    output [7:0] dec_out
);


  //define variables
  reg [3:0] select_out;
  reg [7:0] hex_out;

  // Assign the outputs to their related registers
  assign seg_select_out = select_out;
  assign dec_out = hex_out;

  /* Use the strobe counter to flicker between the 2 7-segments at a speed 
   * the human eye cannot see (so it appears as both are constantly on)
   */
  always @(seg_select) begin
    case (seg_select)
      1'b0:    select_out <= 4'b1110;
      1'b1:    select_out <= 4'b1101;
      default: select_out <= 4'b0000;
    endcase
  end

  /* Convert the binary number to be displayed on the 7-seg into
   * the relevant segments on the display (1 is off 0 is on)
   */
  always @(bin_in or dot_in) begin
    case (bin_in)
      4'h0:    hex_out[6:0] <= 7'b1000000;
      4'h1:    hex_out[6:0] <= 7'b1111001;
      4'h2:    hex_out[6:0] <= 7'b0100100;
      4'h3:    hex_out[6:0] <= 7'b0110000;
      4'h4:    hex_out[6:0] <= 7'b0011001;
      4'h5:    hex_out[6:0] <= 7'b0010010;
      4'h6:    hex_out[6:0] <= 7'b0000010;
      4'h7:    hex_out[6:0] <= 7'b1111000;
      4'h8:    hex_out[6:0] <= 7'b0000000;
      4'h9:    hex_out[6:0] <= 7'b0011000;
      default: hex_out[6:0] <= 7'b1111111;
    endcase

    hex_out[7] <= ~dot_in;
  end

endmodule
