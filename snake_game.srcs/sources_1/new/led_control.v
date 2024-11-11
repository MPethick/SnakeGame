`timescale 1ns / 1ps
/*
 * Engineer:     Matthew Pethick
 * Create Date:  11/11/2024
 * Last Edited:  11/11/2024
 * Module Name:  led_control
 * Project Name: snake_game 
 * Description:  This module converts the score to display 
 *               on to the RGB LEDs in HEX on the FPGA and
 *               also shows a win/loss state on the LEDs
 */

module led_control (
    input         clk,
    input  [ 3:0] score_count,
    input  [ 1:0] game_state,
    output [11:0] led_out
);

  // Define parameters
  parameter START = 2'd0;
  parameter PLAY = 2'd1;
  parameter WIN = 2'd2;
  parameter LOSE = 2'd3;

  //define variables
  reg [2:0] led_0;
  reg [2:0] led_1;
  reg [2:0] led_2;
  reg [2:0] led_3;

  // Assign the outputs to their related registers
  assign led_out[2:0]  = led_0;
  assign led_out[5:3]  = led_1;
  assign led_out[8:6]  = led_2;
  assign led_out[11:9] = led_3;

  /* Depending on the game state control the colour of the RBG LEDs. 
   * If the game has not started don't set any colour on them. If the
   * game is in play, show the hex value of the score in blue. If the 
   * game has been lost, show the hex value of the score that the lose 
   * occured on in red. If the game has been won, show the hex value of
   * the winning score (10) in green.
  */
  always @(posedge clk) begin
    case (game_state)
      START: begin
        led_0 = 3'b000;
        led_1 = 3'b000;
        led_2 = 3'b000;
        led_3 = 3'b000;
      end
      PLAY: begin
        // Blue is on bit 0
        led_0 = {2'b00, score_count[0]};
        led_1 = {2'b00, score_count[1]};
        led_2 = {2'b00, score_count[2]};
        led_3 = {2'b00, score_count[3]};
      end
      WIN: begin
        // Green is on bit 1
        led_0 = {1'b0, score_count[0], 1'b0};
        led_1 = {1'b0, score_count[1], 1'b0};
        led_2 = {1'b0, score_count[2], 1'b0};
        led_3 = {1'b0, score_count[3], 1'b0};
      end
      LOSE: begin
        // Red is on bit 2
        led_0 = {score_count[0], 2'b00};
        led_1 = {score_count[1], 2'b00};
        led_2 = {score_count[2], 2'b00};
        led_3 = {score_count[3], 2'b00};
      end
    endcase
  end

endmodule
