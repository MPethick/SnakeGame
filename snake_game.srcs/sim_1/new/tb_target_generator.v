`timescale 1ns / 1ps


module tb_target_generator;

  // Ports
  reg        clk;
  reg        reset;
  reg        reached_target;
  wire [9:0] target_x_coord;
  wire [8:0] target_y_coord;

  // Instantiate the module to control the target generation
  target_generator target_generator_inst (
      .clk           (clk),
      .reset         (reset),
      .reached_target(reached_target),
      .target_x_coord(target_x_coord),
      .target_y_coord(target_y_coord)
  );

  // Initialise the clock to use in simulation at a speed of 125MHz
  initial begin
    clk = 0;
    forever #4 clk = ~clk;
  end

  // Simulation values  
  initial begin
    reset          = 0;
    reached_target = 0;
    forever #500 reached_target = ~reached_target;
  end

endmodule
