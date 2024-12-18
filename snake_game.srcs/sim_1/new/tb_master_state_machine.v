`timescale 1ns / 1ps


module tb_master_state_machine;

  // Ports
  reg        clk;
  reg        reset;
  reg        btn_l;
  reg        btn_u;
  reg        btn_r;
  reg        btn_d;
  reg        lose;
  reg        win;
  wire [1:0] game_state;

  // Instantiate the module to control the state of the game (e.g. win/lose)  
  master_state_machine master_state_machine_inst (
      .clk       (clk),
      .reset     (reset),
      .btn_l     (btn_l),
      .btn_u     (btn_u),
      .btn_r     (btn_r),
      .btn_d     (btn_d),
      .lose      (lose),
      .win       (win),
      .game_state(game_state)
  );

  // Initialise the clock to use in simulation at a speed of 125MHz
  initial begin
    clk = 0;
    forever #4 clk = ~clk;
  end

  // Simulation values  
  initial begin
    #200 reset = 0;
    btn_l = 0;
    btn_u = 0;
    btn_r = 0;
    btn_d = 0;
    lose  = 0;
    win   = 0;
    #200 btn_l = 1;
    #200 btn_l = 0;
    win = 1;
    #200 win = 0;
    reset = 1;
    #100 btn_r = 1;
    #200 reset = 0;
    #200 lose = 1;
  end

endmodule
