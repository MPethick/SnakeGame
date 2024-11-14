`timescale 1ns / 1ps
/*
 * Engineer:     Matthew Pethick
 * Create Date:  15/11/2016
 * Last Edited:  14/11/2024
 * Module Name:  snake_control
 * Project Name: snake_game
 * Description:  This module controls the snakes properites (speed/movement/size) 
 *               as well as the eating of the target and control of the lose 
 *               conditions. It also controls the colour output to the VGA.  
 */


module snake_control (
    input         clk,
    input         reset,
    input         speedup_disable,
    input  [ 1:0] game_state,
    input  [ 9:0] x_coord,
    input  [ 8:0] y_coord,
    input  [ 9:0] target_x_coord,
    input  [ 8:0] target_y_coord,
    input  [ 9:0] shift_x,
    input  [ 8:0] shift_y,
    input  [ 1:0] direction,
    input  [ 3:0] score_count,
    output        reached_target,
    output        lose,
    output [11:0] snake_colour_out
);

  // Define parameters
  parameter MAX_LENGTH = 15;
  parameter LEFT = 2'd0;
  parameter UP = 2'd1;
  parameter RIGHT = 2'd2;
  parameter DOWN = 2'd3;
  parameter START = 2'd0;
  parameter PLAY = 2'd1;
  parameter WIN = 2'd2;
  parameter LOSE = 2'd3;

  // Define variables
  genvar        pixel_num;
  reg    [ 3:0] i;          
  reg    [ 3:0] speed_count;
  reg           move_snake;
  reg    [ 9:0] snake_state_x  [MAX_LENGTH-1:0];
  reg    [ 8:0] snake_state_y  [MAX_LENGTH-1:0];
  reg           wall;
  reg           die = 0;
  reg           reached;
  reg    [11:0] current_colour;
  reg           count;
  reg    [15:0] frame_count;
  wire   [ 3:0] snake_length;
  wire    [3:0] snake_speed;
  wire          move_clk;
  wire   [19:0] clock_count;

  // Assign the outputs to their related registers
  assign lose             = die;
  assign reached_target   = reached;
  assign snake_colour_out = current_colour;

  // Controls length of snake
  assign snake_length     = score_count + 5;

  // Controls the speed of the snake, with a lower number being faster
  assign snake_speed      = speedup_disable ? 10 : (10 - score_count);

  // Instantiate a generic counter which outputs a trigger at a speed of 100Hz                  
  generic_counter #(
      .COUNTER_WIDTH(20),
      .COUNTER_MAX  (1000000)
  ) clock_rectifier_snake (
      .clk     (clk),
      .reset   (1'b0),
      .enable  (1'b1),
      .trig_out(move_clk),
      .count   (clock_count)
  );

  /* On every positive edge of the corrected clock edge if the counter is
   * less than ten minus the current score as one to the counter. 
   * Otherwise set the counter back to zero and output a trigger to use 
   * to tell the snake to move. This is used to increasing the speed of 
   * the snake everytime the score increases.
   */
  always @(posedge move_clk) begin
    if (speed_count == snake_speed) begin
      speed_count <= 4'b0;
      move_snake  <= 1'b1;
    end else begin
      speed_count <= speed_count + 1;
      move_snake  <= 1'b0;
    end
  end

  /* On the positive edge of the trigger from the speed controlling always loop,
     * if the reset is pressed set the segment of the snake selected by 
     * the for loop to the centre of the screen. Otherwise set that segment
     * to the segment before it, moving the whole tail to follow the head 
     * everytime the trigger happens. 
     */
  generate
    for (pixel_num = 0; pixel_num < MAX_LENGTH - 1; pixel_num = pixel_num + 1) begin : pixel_shift
      always @(posedge move_snake) begin
        if (reset) begin
          snake_state_x[pixel_num+1] <= 320;
          snake_state_y[pixel_num+1] <= 240;
        end else if (game_state == PLAY) begin
          snake_state_x[pixel_num+1] <= snake_state_x[pixel_num];
          snake_state_y[pixel_num+1] <= snake_state_y[pixel_num];
        end
      end
    end
  endgenerate

  /* On the positive edge of the trigger from the speed controlling always loop,
   * if the reset is pressed set reset the head of the snake to one square
   * to the left of the centre (to avoid it eating itself on reset). Otherwise
   * use the direction set by the navigation state machine to adjest the location 
   * of the head in the approriate direction. If the head will end up hitting one 
   * of the walls instead of moving it will output a value which triggers the lose
   * condition in the apprpriate always loop.
     */
  always @(posedge move_snake) begin
    if (reset) begin
      wall             <= 0;
      snake_state_x[0] <= 310;
      snake_state_y[0] <= 240;
    end else if (game_state == PLAY) begin
      case (direction)
        LEFT: begin
          if (snake_state_x[0] != 0) begin
            snake_state_x[0] <= snake_state_x[0] - 10;
          end else begin
            wall <= 1;
          end
        end
        UP: begin
          if (snake_state_y[0] != 0) begin
            snake_state_y[0] <= snake_state_y[0] - 10;
          end else begin

            wall <= 1;
          end
        end
        RIGHT: begin
          if (snake_state_x[0] != 630) begin
            snake_state_x[0] <= snake_state_x[0] + 10;
          end else begin
            wall <= 1;
          end
        end
        DOWN: begin
          if (snake_state_y[0] != 470) begin
            snake_state_y[0] <= snake_state_y[0] + 10;
          end else begin
            wall <= 1;
          end
        end
      endcase
    end
  end

  /* On the positive edge of the clock if reset is pressed set the lose state
   * trigger to zero. Otherwise check if either the trigger for the snake hitting
   * has happened or the head of the snake is occupying the same square as any of 
   * the tail squares output a trigger which will cause the lose state to occur in
   * the master navigation state.
   */
  always @(posedge clk) begin
    if (reset) begin
      die <= 1'b0;
    end else begin
      if (wall == 1) begin
        die <= 1'b1;
      end else begin
        for (i = 1; i < snake_length; i = i + 1) begin
          if (snake_state_x[0] == snake_state_x[i] && snake_state_y[0] == snake_state_y[i]) begin
            die <= 1'b1;
          end
        end
      end
    end
  end

  /* On the positive edge of the clock check if either the head of the snake is
   * occupying the same square as the target and if it is output a trigger which
   * is used to count up the score and also generate a new location for the target.
   */
  always @(posedge clk) begin
    if (snake_state_x[0] == target_x_coord && snake_state_y[0] == target_y_coord) begin
      reached <= 1'b1;
    end else begin
      reached <= 1'b0;
    end
  end

  /* On the positive edge of the clock use the coordinates from VGA_control in conjunction with the 
   * state given by the master control to correctly colour the corresponding pixel to draw the correct
   * image on the screen. For the start state (0) it draw a yellow border with a blue background with the word
   * "Start" in yellow bouncing around the screen. For the play state (1) it draw a yellow border with a blue 
   * background with a red target and a yellow snake. For the win state (3) it draws a multi-colour animated 
   * display. For the lose state (4) it draws a white border with the word "lose" in white with a red background. 
   */
  always @(posedge clk) begin
    case (game_state)
      START: begin
        if (x_coord <= 1 || x_coord >= 639 || y_coord <= 1 || y_coord >= 479) begin
          current_colour <= 12'd255;
        end else begin
          if(((x_coord >= shift_x      ) && (x_coord <= shift_x + 40 ) && (y_coord >= shift_y + 70) && (y_coord <= shift_y + 80)) ||
             ((x_coord >= shift_x + 30 ) && (x_coord <= shift_x + 40 ) && (y_coord >= shift_y + 45) && (y_coord <= shift_y + 70)) ||
             ((x_coord >= shift_x      ) && (x_coord <= shift_x + 40 ) && (y_coord >= shift_y + 35) && (y_coord <= shift_y + 45)) ||
             ((x_coord >= shift_x      ) && (x_coord <= shift_x + 10 ) && (y_coord >= shift_y + 10) && (y_coord <= shift_y + 35)) ||
             ((x_coord >= shift_x      ) && (x_coord <= shift_x + 40 ) && (y_coord >= shift_y     ) && (y_coord <= shift_y + 10)) ||
             ((x_coord >= shift_x + 45 ) && (x_coord <= shift_x + 75 ) && (y_coord >= shift_y + 70) && (y_coord <= shift_y + 80)) ||
             ((x_coord >= shift_x + 45 ) && (x_coord <= shift_x + 55 ) && (y_coord >= shift_y     ) && (y_coord <= shift_y + 70)) ||
             ((x_coord >= shift_x + 55 ) && (x_coord <= shift_x + 75 ) && (y_coord >= shift_y + 35) && (y_coord <= shift_y + 45)) ||
             ((x_coord >= shift_x + 80 ) && (x_coord <= shift_x + 120) && (y_coord >= shift_y + 70) && (y_coord <= shift_y + 80)) ||
             ((x_coord >= shift_x + 105) && (x_coord <= shift_x + 115) && (y_coord >= shift_y + 45) && (y_coord <= shift_y + 70)) ||
             ((x_coord >= shift_x + 80 ) && (x_coord <= shift_x + 115) && (y_coord >= shift_y + 35) && (y_coord <= shift_y + 45)) ||
             ((x_coord >= shift_x + 80 ) && (x_coord <= shift_x + 90 ) && (y_coord >= shift_y + 45) && (y_coord <= shift_y + 70)) ||    
             ((x_coord >= shift_x + 125) && (x_coord <= shift_x + 135) && (y_coord >= shift_y + 35) && (y_coord <= shift_y + 80)) ||
             ((x_coord >= shift_x + 135) && (x_coord <= shift_x + 155) && (y_coord >= shift_y + 35) && (y_coord <= shift_y + 45)) ||
             ((x_coord >= shift_x + 145) && (x_coord <= shift_x + 155) && (y_coord >= shift_y + 45) && (y_coord <= shift_y + 50)) ||
             ((x_coord >= shift_x + 160) && (x_coord <= shift_x + 190) && (y_coord >= shift_y + 70) && (y_coord <= shift_y + 80)) ||
             ((x_coord >= shift_x + 160) && (x_coord <= shift_x + 170) && (y_coord >= shift_y     ) && (y_coord <= shift_y + 70)) ||
             ((x_coord >= shift_x + 170) && (x_coord <= shift_x + 190) && (y_coord >= shift_y + 35) && (y_coord <= shift_y + 45))   ) begin
            current_colour <= 12'd255;
          end else begin
            current_colour <= 12'd3908;
          end
        end
      end
      PLAY: begin
        if (x_coord <= 1 || x_coord >= 639 || y_coord <= 1 || y_coord >= 479) begin
          current_colour <= 12'd255;
        end else begin
          count <= 0;
          for (i = 0; i < snake_length; i = i + 1) begin
            if (x_coord > snake_state_x[i] && x_coord < snake_state_x[i] + 10 && y_coord > snake_state_y[i] && y_coord < snake_state_y[i] + 10) begin
              current_colour <= 12'd255;
              count          <= 1;
            end
          end
          if (count == 0) begin
            if (reached_target == 0 && x_coord > target_x_coord && x_coord < target_x_coord + 10 && y_coord > target_y_coord && y_coord < target_y_coord + 10) begin
              current_colour <= 12'd15;
            end else begin
              current_colour <= 12'd3908;
            end
          end
        end
      end
      WIN: begin
        if (y_coord == 479) begin
          frame_count <= frame_count + 1;
        end
        if (y_coord > 240) begin
          if (x_coord > 320) begin
            current_colour <= frame_count[15:8] + y_coord + x_coord - 240 - 320;
          end else begin
            current_colour <= frame_count[15:8] + y_coord - x_coord - 240 + 320;
          end
        end else begin
          if (x_coord > 320) begin
            current_colour <= frame_count[15:8] - y_coord + x_coord + 240 - 320;
          end else begin
            current_colour <= frame_count[15:8] - y_coord - x_coord + 240 + 320;
          end
        end
      end
      LOSE: begin
        if ((x_coord <= 1)                                                                 || 
            (x_coord >= 639)                                                               ||
            (y_coord <= 1)                                                                 || 
            (y_coord >= 479)                                                               ||
            ((x_coord >= 40 ) && (x_coord <= 60 ) && (y_coord >= 160) && (y_coord <= 320)) ||
            ((x_coord >= 60 ) && (x_coord <= 120) && (y_coord >= 300) && (y_coord <= 320)) ||
            ((x_coord >= 200) && (x_coord <= 220) && (y_coord >= 160) && (y_coord <= 320)) ||
            ((x_coord >= 220) && (x_coord <= 260) && (y_coord >= 300) && (y_coord <= 320)) ||
            ((x_coord >= 220) && (x_coord <= 260) && (y_coord >= 160) && (y_coord <= 180)) ||
            ((x_coord >= 260) && (x_coord <= 280) && (y_coord >= 160) && (y_coord <= 320)) ||
            ((x_coord >= 360) && (x_coord <= 440) && (y_coord >= 300) && (y_coord <= 320)) ||
            ((x_coord >= 420) && (x_coord <= 440) && (y_coord >= 250) && (y_coord <= 300)) ||
            ((x_coord >= 360) && (x_coord <= 440) && (y_coord >= 230) && (y_coord <= 250)) ||
            ((x_coord >= 360) && (x_coord <= 380) && (y_coord >= 180) && (y_coord <= 230)) ||
            ((x_coord >= 360) && (x_coord <= 440) && (y_coord >= 160) && (y_coord <= 180)) ||
            ((x_coord >= 520) && (x_coord <= 540) && (y_coord >= 160) && (y_coord <= 320)) ||
            ((x_coord >= 540) && (x_coord <= 600) && (y_coord >= 300) && (y_coord <= 320)) ||
            ((x_coord >= 540) && (x_coord <= 600) && (y_coord >= 230) && (y_coord <= 250)) ||
            ((x_coord >= 540) && (x_coord <= 600) && (y_coord >= 160) && (y_coord <= 180))   ) begin
          current_colour <= 12'd4095;
        end else begin
          current_colour <= 12'd15;
        end
      end
    endcase
  end

endmodule
