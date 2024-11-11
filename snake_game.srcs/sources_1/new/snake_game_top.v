`timescale 1ns / 1ps

/*
 * Engineer:     Matthew Pethick
 * Create Date:  08/11/2016
 * Last Edited:  11/11/2024
 * Module Name:  snake_game_top
 * Project Name: snake_game
 * Description:  This module is used for connecting all the other modules together  
 */


module snake_game_top (
    input         clk,
    input         reset,
    input         speedup_disable,
    input         btn_l,
    input         btn_u,
    input         btn_r,
    input         btn_d,
    // output [ 3:0] seg_select_out,
    // output [ 7:0] dec_out,
    output [11:0] led_out,
    output [11:0] colour_out,
    output        h_sync,
    output        v_sync
);

  // Define variables  
  wire [ 9:0] x_coord;
  wire [ 8:0] y_coord;
  wire [ 9:0] target_x_coord;
  wire [ 8:0] target_y_coord;
  wire [11:0] snake_colour_out;
  wire [ 1:0] game_state;
  wire [ 1:0] direction;
  wire        reached_target;
  wire        win;
  wire        lose;
  wire [ 3:0] score_count;
  wire        score_clk;
  wire        score_clk_count;
  // wire [ 3:0] bin_in;
  // wire        seg_select;
  wire [ 9:0] shift_x;
  wire [ 8:0] shift_y;

  // Instantiate a generic counter which outputs a trigger at a speed of 50MHz        
  generic_counter #(
      .COUNTER_WIDTH(1),
      .COUNTER_MAX  (1)
  ) score_clock_rectifier (
      .clk     (clk),
      .reset   (1'b0),
      .enable  (1'b1),
      .trig_out(score_clk),
      .count   (score_clk_count)
  );

  /* Instantiate a generic counter which counts up the score everytime the
     * target is eaten and outputs a seperate trigger when the counter
     * reaches 10 to use to set it to the win state.
     */
  generic_counter #(
      .COUNTER_WIDTH(4),
      .COUNTER_MAX  (10)
  ) score_counter (
      .clk     (score_clk),
      .reset   (reset),
      .enable  (reached_target),
      .trig_out(win),
      .count   (score_count)
  );

  // Instantiate the module to control the state of the game (e.g. win/lose)     
  master_state_machine msm (
      .clk       (clk),
      .reset     (reset),
      .btn_l     (btn_l),
      .btn_u     (btn_u),
      .btn_r     (btn_r),
      .btn_d     (btn_d),
      .win       (win),
      .lose      (lose),
      .game_state(game_state)
  );

  // Instantiate the module to control the navigation of the snake
  navigation_state_machine nsm (
      .clk      (clk),
      .reset    (reset),
      .btn_l    (btn_l),
      .btn_u    (btn_u),
      .btn_r    (btn_r),
      .btn_d    (btn_d),
      .direction(direction)
  );

  // Instantiate the module to control the start screen's movement
  start_screen screensaver (
      .clk    (clk),
      .shift_x(shift_x),
      .shift_y(shift_y)
  );

  // Instantiate the module to control the target generation 
  target_generator target (
      .clk           (clk),
      .reset         (reset),
      .reached_target(reached_target),
      .target_x_coord(target_x_coord),
      .target_y_coord(target_y_coord)
  );

  // Instantiate the module to control the snake and colours to be displayed
  snake_control snake (
      .clk             (clk),
      .reset           (reset),
      .speedup_disable (speedup_disable),
      .game_state      (game_state),
      .x_coord         (x_coord),
      .y_coord         (y_coord),
      .target_x_coord  (target_x_coord),
      .target_y_coord  (target_y_coord),
      .shift_x         (shift_x),
      .shift_y         (shift_y),
      .direction       (direction),
      .score_count     (score_count),
      .reached_target  (reached_target),
      .lose            (lose),
      .snake_colour_out(snake_colour_out)
  );

  // // Instantiate the module to control the strobing for the 7-seg display 
  // strobe strobe (
  //     .clk        (clk),
  //     .score_count(score_count),
  //     .seg_select (seg_select),
  //     .seg_value  (bin_in)
  // );

  // // Instantiate the module to control 7-seg display 
  // seg_7_display seg_7 (
  //     .bin_in        (bin_in),
  //     .seg_select    (seg_select),
  //     .dot_in        (1'b0),            // The decimal point on the 7-seg is always unused so its driven to 0
  //     .seg_select_out(seg_select_out),
  //     .dec_out       (dec_out)
  // );

  // Instantiate the module to control the RGB LEDs output 
  led_control led_colour (
      .clk        (clk),
      .score_count(score_count),
      .game_state (game_state),
      .led_out    (led_out)
  );

  // Instantiate the module to control VGA output 
  vga_control vga (
      .clk       (clk),
      .colour_in (snake_colour_out),
      .colour_out(colour_out),
      .addr_h    (x_coord),
      .addr_v    (y_coord),
      .h_sync    (h_sync),
      .v_sync    (v_sync)
  );

endmodule
