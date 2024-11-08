`timescale 1ns / 1ps
/*
 * Engineer:     Matthew Pethick
 * Create Date:  19/11/2016
 * Last Edited:  08/11/2024
 * Module Name:  start_screen
 * Project Name: snake_game
 * Description:  This module is used for controlling the movement om the start screen
 */


module start_screen (
    input        clk,
    output [9:0] shift_x,
    output [8:0] shift_y
);

  // Define variables
  reg  [ 9:0] shift_word_x = 300;
  reg  [ 8:0] shift_word_y = 300;
  reg         word_wait_x;
  reg         word_wait_y;
  reg         word_x = 1;
  reg         word_y = 1;
  wire        shift_word_trig;
  wire [20:0] trig_count;

  // Assign the outputs to their related registers
  assign shift_x = shift_word_x;
  assign shift_y = shift_word_y;

  /* Instantiate a generic counter which outputs a trigger at a speed of 
   * 5Hz for use on the the moving word
   */
  generic_counter #(
      .COUNTER_WIDTH(21),
      .COUNTER_MAX  (2000000)
  ) trigger_creator (
      .clk     (clk),
      .reset   (1'b0),
      .enable  (1'b1),
      .trig_out(shift_word_trig),
      .count   (trig_count)
  );

  /* On the positive clock edge it first checks if either of the edges of
   * the word are touching the border the corresponding direction variable
   * inverts so the letter stays within the border. It then checks if the 
   * trig out from the counter is positive and if it is it increments 1 to both
   * x and y shift depending on the variable mentioned earlier. 
   */
  always @(posedge clk) begin
    if ((shift_word_x == 2 || shift_word_x == 449) && word_wait_x == 1) begin
      word_wait_x <= 0;
      word_x      <= ~word_x;
    end else begin
      if ((shift_word_y == 2 || shift_word_y == 399) && word_wait_y == 1) begin
        word_wait_y <= 0;
        word_y      <= ~word_y;
      end
    end

    begin
      if (shift_word_trig == 1) begin
        if (word_x == 1) begin
          shift_word_x <= shift_word_x + 1;
          word_wait_x  <= 1;
        end else begin
          shift_word_x <= shift_word_x - 1;
          word_wait_x  <= 1;
        end
      end
    end
    begin
      if (shift_word_trig == 1) begin
        if (word_y == 1) begin
          shift_word_y <= shift_word_y + 1;
          word_wait_y  <= 1;
        end else begin
          shift_word_y <= shift_word_y - 1;
          word_wait_y  <= 1;
        end
      end
    end
  end

endmodule
