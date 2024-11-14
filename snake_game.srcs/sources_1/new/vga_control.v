`timescale 1ns / 1ps
/*
 * Engineer:     Matthew Pethick
 * Create Date:  29/10/2016
 * Last Edited:  08/11/2024
 * Module Name:  target_generator
 * Project Name: snake_game  
 * Description:  This module uses 2 counters to move along every pixel of the screen.
 *               For each of these pixels that are inside the desired resolution (640x480)
 *               It then set that pixel with the corresponding colour generated in the module
 *               snake_control. It also generates the H-Sync and V-Sync and outputs these
 *               as well as the colour output to the wrapper to be used as the VGA output
 */


module vga_control (
    input         clk,
    input  [11:0] colour_in,
    output [ 9:0] addr_h,
    output [ 8:0] addr_v,
    output [11:0] colour_out,
    output        v_sync,
    output        h_sync
);

  // Define parameters
  parameter HORZ_TIME_TO_PULSE_WIDTH_END = 10'd96;
  parameter HORZ_TIME_TO_BACK_PORCH_END = 10'd144;
  parameter HORZ_TIME_TO_DISPLAY_TIME_END = 10'd784;
  parameter HORZ_TIME_TO_FRONT_PORCH_END = 10'd800;
  parameter VERT_TIME_TO_PULSE_WIDTH_END = 10'd2;
  parameter VERT_TIME_TO_BACK_PORCH_END = 10'd31;
  parameter VERT_TIME_TO_DISPLAY_TIME_END = 10'd511;
  parameter VERT_TIME_TO_FRONT_PORCH_END = 10'd521;

  // Define variables
  reg  [ 9:0] horizontal;
  reg  [ 8:0] vertical;
  reg         vertical_sync;
  reg         horizonal_sync;
  reg  [11:0] current_colour;
  wire        half_speed_clk;
  wire [ 1:0] clock_count;
  wire        vert_count_trig_out;
  wire [ 8:0] vert_count;
  wire        horz_count_trig_out;
  wire [ 9:0] horz_count;

  // Assign the outputs to their related registers
  assign addr_v     = vertical;
  assign addr_h     = horizontal;
  assign v_sync     = vertical_sync;
  assign h_sync     = horizonal_sync;
  assign colour_out = current_colour;


  // Instantiate a generic counter which outputs a trigger at a speed of 25MHz       
  generic_counter #(
      .COUNTER_WIDTH(2),
      .COUNTER_MAX  (3)
  ) clock_rectifier_vga (
      .clk     (clk),
      .reset   (1'b0),
      .enable  (1'b1),
      .trig_out(half_speed_clk),
      .count   (clock_count)
  );

  /* Instantiate a generic counter to count up to the front porch
   * value using the output from the previous counter as the clock.
   */
  generic_counter #(
      .COUNTER_WIDTH(10),
      .COUNTER_MAX  (HORZ_TIME_TO_FRONT_PORCH_END)
  ) counter_horz (
      .clk     (half_speed_clk),
      .reset   (1'b0),
      .enable  (1'b1),
      .trig_out(horz_count_trig_out),
      .count   (horz_count)
  );

  /* Instantiate a generic counter to count up to the front porch 
   * value using the output from the previous  counter as the enable.
   */
  generic_counter #(
      .COUNTER_WIDTH(9),
      .COUNTER_MAX  (VERT_TIME_TO_FRONT_PORCH_END)
  ) counter_vert (
      .clk     (half_speed_clk),
      .reset   (1'b0),
      .enable  (horz_count_trig_out),
      .trig_out(vert_count_trig_out),
      .count   (vert_count)
  );

  /* On the positive clock edge check if the veritical counter is
   * less than the pulse width and if it is set the vertical sync
   * to true, if it isn't set the sync to negative
   */
  always @(posedge clk) begin
    if (vert_count > VERT_TIME_TO_PULSE_WIDTH_END) begin
      vertical_sync <= 1;
    end else begin
      vertical_sync <= 0;
    end
  end

  /* On the positive clock edge check if the horizontal counter is
   * less than the pulse width and if it is set the horizontal sync
   * to true, if it isn't set the sync to negative
   */
  always @(posedge clk) begin
    if (horz_count > HORZ_TIME_TO_PULSE_WIDTH_END) begin
      horizonal_sync <= 1;
    end else begin
      horizonal_sync <= 0;
    end
  end

  /* On the positive clock edge check if the horizontal and veritcla
   * counters are less than the display time and also greater than 
   * the back porch and if it is set the output to the value of the
   * input, if it isn't set the output to zero.
   */
  always @(posedge clk) begin
    if (horz_count > HORZ_TIME_TO_BACK_PORCH_END & horz_count < HORZ_TIME_TO_DISPLAY_TIME_END & vert_count > VERT_TIME_TO_BACK_PORCH_END & vert_count < VERT_TIME_TO_DISPLAY_TIME_END) begin
      current_colour <= colour_in;
    end else begin
      current_colour <= 12'd0;
    end
  end

  /* On the positive clock edge check if the vertical counter is
   * less than the display time and also greater than the back porch
   * and if it is set the vertical address to the value of the 
   * horizontal counter, if it isn't set the address to zero.
   */
  always @(posedge clk) begin
    if (vert_count >= VERT_TIME_TO_BACK_PORCH_END & vert_count <= VERT_TIME_TO_DISPLAY_TIME_END) begin
      vertical <= (vert_count - VERT_TIME_TO_BACK_PORCH_END);
    end else begin
      vertical <= 10'd0;
    end
  end

  /* On the positive clock edge check if the horizontal counter is
   * less than the display time and also greater than the back porch
   * and if it is set the horizontal address to the value of the 
   * horizontal counter, if it isn't set the address to zero.
   */
  always @(posedge clk) begin
    if (horz_count >= HORZ_TIME_TO_BACK_PORCH_END & horz_count <= HORZ_TIME_TO_DISPLAY_TIME_END) begin
      horizontal <= (horz_count - HORZ_TIME_TO_BACK_PORCH_END);
    end else begin
      horizontal <= 9'd0;
    end
  end

endmodule
