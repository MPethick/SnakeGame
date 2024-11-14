`timescale 1ns / 1ps
/*
 * Engineer:     Matthew Pethick
 * Create Date:  19/11/2016
 * Last Edited:  14/11/2024
 * Module Name:  target_generator
 * Project Name: snake_game  
 * Description:  This module converts the score to be used as an 
 *               input for the seg_7_display module using strobing 
 */


module strobe (
    input        clk,
    input  [3:0] score_count,
    output       seg_select,
    output [3:0] seg_value
);

  // Define variables
  reg         select = 0;
  reg  [ 3:0] out = 0;
  wire [ 3:0] score_tens;
  wire [ 3:0] score_unit;
  wire        strobe_clk;
  wire [16:0] clock_count;
  wire        strobe;
  wire        strobe_count;

  // Assign the outputs to their related registers
  assign seg_select = select;
  assign seg_value  = out;

  // Split the score into tens and units
  assign score_tens = score_count % 10;
  assign score_unit = score_count / 10;

  // Instantiate a generic counter which outputs a trigger at a speed of 1KHz   
  generic_counter #(
      .COUNTER_WIDTH(17),
      .COUNTER_MAX  (100000)
  ) clock_rectifier_strobe (
      .clk     (clk),
      .reset   (1'b0),
      .enable  (1'b1),
      .trig_out(strobe_clk),
      .count   (clock_count)
  );

  // Instantiate a generic counter which outputs a strobe  at a speed of 500Hz   
  generic_counter #(
      .COUNTER_WIDTH(1),
      .COUNTER_MAX  (1)
  ) strobe_counter (
      .clk     (strobe_clk),
      .reset   (1'b0),
      .enable  (1'b1),
      .trig_out(strobe),
      .count   (strobe_count)
  );

  /* If the input has no tens unit only use the first seven segment and display
   * the units. If the input has a tens unit use the strobe as well as a two way
   * multiplxer to flicker the tens and units on two seperate seven segments at 
   * a speed so fast that it looks constantly on to the human eye.
   */
  always @(strobe or score_tens or score_unit) begin
    if (score_unit == 0) begin
      select <= 1'b0;
      out    <= score_tens;
    end else begin
      select <= strobe;
      case (strobe)
        1'b0:    out <= score_tens;
        1'b1:    out <= score_unit;
        default: out <= 3'b000;
      endcase
    end
  end

endmodule
