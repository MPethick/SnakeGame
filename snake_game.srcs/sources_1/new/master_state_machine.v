`timescale 1ns / 1ps
/*
 * Engineer:     Matthew Pethick
 * Create Date:  08/11/2016
 * Last Edited:  08/11/2024
 * Module Name:  master_state_machine
 * Project Name: snake_game  
 * Description:  This module controls what state the game should be in 
 *               using a shift register whether it be start screen, play
 *               screen, win screen or lose screen
 */


module master_state_machine (
    input        clk,
    input        reset,
    input        btn_l,
    input        btn_u,
    input        btn_r,
    input        btn_d,
    input        win,
    input        lose,
    output [1:0] game_state
);

  // Define parameters
  parameter START = 2'd0;
  parameter PLAY = 2'd1;
  parameter WIN = 2'd2;
  parameter LOSE = 2'd3;

  // Define variables 
  reg [1:0] curr_state;
  reg [1:0] next_state;

  assign game_state = curr_state;

  /* On every clock set the current state of the register to the next state
     * or set the current state to zero if the reset has been pressed
     */
  always @(posedge clk) begin
    if (reset) begin
      curr_state <= START;
    end else begin
      curr_state <= next_state;
    end
  end

  /* This section of code calculates the next state of the state machine.
     * If the current state is the start state (0) the next state will be
     * set the play state (1) if any of the direction control push buttons
     * have been pressed or otherwise stay in the start screen. If the current
     * state is the play state (1) the next state will be set to the win state (2)
     * if the win conditions are reached or the lose state (3) if the lose conditions
     * are met. Otherwise it will stay in the play state. Finally if it is in the
     * win state (2) or lose state (3) it will stay in the same state.
     */
  always @(curr_state or win or lose or btn_l or btn_u or btn_r or btn_d) begin
    case (curr_state)
      START: begin
        if (btn_l || btn_u || btn_r || btn_d) begin
          next_state <= PLAY;
        end else begin
          next_state <= curr_state;
        end
      end
      PLAY: begin
        if (win) begin
          next_state <= WIN;
        end else begin
          if (lose) begin
            next_state <= LOSE;
          end else begin
            next_state <= curr_state;
          end
        end
      end
      WIN: begin
        next_state <= curr_state;
      end
      LOSE: begin
        next_state <= curr_state;
      end
      default: begin
        next_state <= START;
      end
    endcase
  end

endmodule
