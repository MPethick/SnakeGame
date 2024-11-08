`timescale 1ns / 1ps
/*
 * Engineer:     Matthew Pethick
 * Create Date:  08/11/2016
 * Last Edited:  08/11/2024
 * Module Name:  navigation_state_machine
 * Project Name: snake_game  
 * Description:  This module controls what direction the snake 
 *               moves using a shift register whether it be 
 *               left, right, up or down
 */


module navigation_state_machine (
    input        clk,
    input        reset,
    input        btn_l,
    input        btn_u,
    input        btn_r,
    input        btn_d,
    output [1:0] direction
);

  // Define parameters
  parameter LEFT = 2'd0;
  parameter UP = 2'd1;
  parameter RIGHT = 2'd2;
  parameter DOWN = 2'd3;

  // Define variables 
  reg [1:0] curr_state;
  reg [1:0] next_state;


  /* On every clock set the current state of the register to the next state
   * or set the current state to zero if the reset has been pressed
   */
  always @(posedge clk) begin
    if (reset) begin
      curr_state <= LEFT;
    end else begin
      curr_state <= next_state;
    end
  end

  /* This section of code calculates the next state of the state machine.
   * If the current state is left (0) or right (2) the next state will be 
   * up (1) if the push button btn_u is pressed or it  will be down (3) if
   * the push button btn_d is pressed or it will stay on the same state. 
   * If the current state is up (1) or down (3) the next state will be 
   * left (0) if the push button btn_l is pressed or it  will be right (2)
   * if the push button btn_r is pressed or it will stay on the same state.
   */
  always @(curr_state or btn_l or btn_u or btn_r or btn_d) begin
    case (curr_state)
      LEFT: begin
        if (~btn_l && btn_u && ~btn_r && ~btn_d) begin
          next_state <= UP;
        end else begin
          if (btn_l == 0 && btn_u == 0 && btn_r == 0 && btn_d == 1) begin
            next_state <= DOWN;
          end else begin
            next_state <= curr_state;
          end
        end
      end
      UP: begin
        if (btn_l && ~btn_u && ~btn_r && ~btn_d) begin
          next_state <= LEFT;
        end else begin
          if (~btn_l && ~btn_u && btn_r && ~btn_d) begin
            next_state <= RIGHT;
          end else begin
            next_state <= curr_state;
          end
        end
      end
      RIGHT: begin
        if (~btn_l && btn_u && ~btn_r && ~btn_d) begin
          next_state <= UP;
        end else begin
          if (~btn_l && ~btn_u && ~btn_r && btn_d) begin
            next_state <= DOWN;
          end else begin
            next_state <= curr_state;
          end
        end
      end
      DOWN: begin
        if (btn_l && ~btn_u && ~btn_r && ~btn_d) begin
          next_state <= LEFT;
        end else begin
          if (~btn_l && ~btn_u && btn_r && ~btn_d) begin
            next_state <= RIGHT;
          end else begin
            next_state <= curr_state;
          end
        end
      end
      default: begin
        next_state <= LEFT;
      end
    endcase
  end

  assign direction = curr_state;

endmodule
