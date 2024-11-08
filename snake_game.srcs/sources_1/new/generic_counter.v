`timescale 1ns / 1ps
/*
 * Engineer:     Matthew Pethick
 * Create Date:  28/10/2016
 * Last Edited:  08/11/2024
 * Module Name:  generic_counter
 * Project Name: snake_game
 * Description:  This module counts up on every positive clock edge to the value of 
 *               the parameter COUNTER_MAX. It then outputs a trigger output and
 *               resets the count back to zero to allow the process to happen again.   
 */


module generic_counter #(
    parameter COUNTER_WIDTH = 10,
    parameter COUNTER_MAX   = 99
) (
    input                      clk,
    input                      reset,
    input                      enable,
    output                     trig_out,
    output [COUNTER_WIDTH-1:0] count
);

  // Define variables
  reg [COUNTER_WIDTH-1:0] count_value = 0;
  reg                     trigger = 0;

  // Assign the outputs to their related registers
  assign count    = count_value;
  assign trig_out = trigger;

  /* Counts up on each positive clock edge until the value set in the parameter
   * is reached where it is set back to one and starts counting up again. If the 
   * reset is triggered the counter is set back to zero.
   */
  always @(posedge clk) begin
    if (reset) begin
      count_value <= 0;
    end else begin
      if (enable) begin
        if (count_value == COUNTER_MAX) begin
          count_value <= 0;
        end else begin
          count_value <= count_value + 1;
        end
      end
    end
  end

  /* On the positive clock edge checks if the counter reaches the defined max paramenter trigger is set
   * to one or else it is set to zero. If the reset is triggered the trigger is set back to zero.
   */
  always @(posedge clk) begin
    if (reset) begin
      trigger <= 0;
    end else begin
      if (count_value == COUNTER_MAX) begin
        trigger <= 1;
      end else begin
        trigger <= 0;
      end
    end
  end

endmodule
