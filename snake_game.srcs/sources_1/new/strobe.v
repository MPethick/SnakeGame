`timescale 1ns / 1ps
/*
 * Engineer:     Matthew Pethick
 * Create Date:  19/11/2016
 * Last Edited:  08/01/2025
 * Module Name:  target_generator
 * Project Name: snake_game  
 * Description:  This module converts the score to be used as an 
 *               input for the seg_7_display module using strobing 
 */


module strobe (
    input        clk,
    input  [3:0] score_count,
    output [2:0] seg_select,
    output [3:0] seg_value
);

  // Define variables
  reg  [ 3:0] out = 0;
  wire [ 3:0] score_tens_mill;
  wire [ 3:0] score_mill;
  wire [ 3:0] score_hund_thou;
  wire [ 3:0] score_tens_thou;
  wire [ 3:0] score_thou;
  wire [ 3:0] score_hund;
  wire [ 3:0] score_tens;
  wire [ 3:0] score_unit;
  wire        strobe_clk;
  wire [16:0] clock_count;
  wire        trig;
  wire  [ 2:0] strobe;

  // Assign the outputs to their related registers
  assign seg_select = strobe;
  assign seg_value  = out;

  // Split the score for the 8 different displays
  assign score_tens_mill  = (score_count / 10000000) % 10;
  assign score_mill  = (score_count / 1000000) % 10;
  assign score_hund_thou  = (score_count / 100000) % 10;
  assign score_tens_thou  = (score_count / 10000) % 10;
  assign score_thou = (score_count / 1000) % 10;
  assign score_hund = (score_count / 100) % 10;
  assign score_tens = (score_count / 10) % 10;
  assign score_unit = score_count % 10;

  // Instantiate a generic counter which outputs a trigger at a speed of 1KHz   
  generic_counter #(
      .COUNTER_WIDTH(17),
      .COUNTER_MAX  (99999)
  ) clock_rectifier_strobe (
      .clk     (clk),
      .reset   (1'b0),
      .enable  (1'b1),
      .trig_out(strobe_clk),
      .count   (clock_count)
  );

  // Instantiate a generic counter which strobes through the 8 displays at a speed of 1KHz   
  generic_counter #(
      .COUNTER_WIDTH(3),
      .COUNTER_MAX  (7)
  ) strobe_counter (
      .clk     (strobe_clk),
      .reset   (1'b0),
      .enable  (1'b1),
      .trig_out(trig),
      .count   (strobe)
  );

  /* If the input has no tens unit only use the first seven segment and display
   * the units. If the input has a tens unit use the strobe as well as a two way
   * multiplxer to flicker the tens and units on two seperate seven segments at 
   * a speed so fast that it looks constantly on to the human eye. Follow this
   * logic for all higher places.
   */
  always @(strobe) begin
    case (strobe)
      3'd0: begin
        out    <= score_unit;
      end
      3'd1: begin
        out    <= (score_count >= 10) ? score_tens : 4'b1111;
      end
      3'd2: begin
        out    <= (score_count >= 100) ? score_hund : 4'b1111;
      end
      3'd3: begin
        out    <= (score_count >= 1000) ? score_thou : 4'b1111;
      end
      3'd4: begin
        out    <= (score_count >= 10000) ? score_tens_thou : 4'b1111;
      end
      3'd5: begin
        out    <= (score_count >= 100000) ? score_hund_thou : 4'b1111;
      end
      3'd6: begin
        out    <= (score_count >= 1000000) ? score_mill : 4'b1111;
      end
      3'd7: begin
        out    <= (score_count >= 10000000) ? score_tens_mill : 4'b1111;
      end
      default: begin
        out    <= 4'b1111;
      end
    endcase
  end

endmodule
