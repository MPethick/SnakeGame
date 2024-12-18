`timescale 1ns / 1ps


module tb_navigation_state_machine;

  // Ports
  reg        clk;
  reg        reset;
  reg        btn_l;
  reg        btn_u;
  reg        btn_r;
  reg        btn_d;
  wire [1:0] direction;

  // Instantiate the module to control the navigation of the snake   
  navigation_state_machine navigation_state_machine_inst (
      .clk      (clk),
      .reset    (reset),
      .btn_l    (btn_l),
      .btn_u    (btn_u),
      .btn_r    (btn_r),
      .btn_d    (btn_d),
      .direction(direction)
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
    #200 btn_u = 1;
    #200 btn_u = 0;
    btn_d = 1;
    #200 btn_d = 0;
    btn_r = 1;
    #200 reset = 1;
    #100 btn_r = 0;
    btn_d = 1;
    #200 reset = 0;
    #200 btn_d = 0;
    btn_r = 1;
  end

endmodule
