`timescale 1ns / 1ps
/*
 * Engineer:     Matthew Pethick
 * Create Date:  15/11/2016
 * Last Edited:  08/11/2024
 * Module Name:  target_generator
 * Project Name: snake_game  
 * Description:  This module randomly generates the location
 *               for the target whenever it is eaten or reset
 */


module target_generator (
    input        clk,
    input        reset,
    input        reached_target,
    output [9:0] target_x_coord,
    output [8:0] target_y_coord

);

  // Define parameters 
  parameter x_max = 630;
  parameter y_max = 470;

  // Define variables
  reg [7:0] random_x = 0;
  reg [6:0] random_y = 0;
  reg [9:0] target_x = 120;
  reg [8:0] target_y = 80;

  // Assign the outputs to their related registers
  assign target_x_coord = target_x;
  assign target_y_coord = target_y;

  /* On every positive clock edge generate a random X
   * coordinate using a linear feedback shift register
   */
  always @(posedge clk) begin
    if (random_x == 8'd0) begin
      random_x <= 8'd1;
    end else begin
      random_x[7] <= random_x[0];
      random_x[6] <= random_x[7];
      random_x[5] <= random_x[6] ^ random_x[0];
      random_x[4] <= random_x[5] ^ random_x[0];
      random_x[3] <= random_x[4] ^ random_x[0];
      random_x[2] <= random_x[3];
      random_x[1] <= random_x[2];
      random_x[0] <= random_x[1];
    end
  end


  /* On every positive clock edge generate a random Y
   * coordinate using a linear feedback shift register
   */
  always @(posedge clk) begin
    if (random_y == 7'd0) begin
      random_y <= 7'd1;
    end else begin
      random_y[6] <= random_y[0];
      random_y[5] <= random_y[6] ^ random_y[0];
      random_y[4] <= random_y[5] ^ random_y[0];
      random_y[3] <= random_y[4] ^ random_y[0];
      random_y[2] <= random_y[3];
      random_y[1] <= random_y[2];
      random_y[0] <= random_y[1];
    end
  end

  /* On every positive clock edge if either the reset is
   * pressed or the target is eaten assign the random new 
   * coordinates to the target to randomly generate the location
   * each new time its created. Also if the target would be outside
   * the screen it moves it inside.
   */
  always @(posedge clk) begin
    if (reset || reached_target) begin
      target_x <= (random_x * 10) % x_max;
      target_y <= (random_y * 10) % y_max;
    end
  end

endmodule
