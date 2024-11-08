`timescale 1ns / 1ps


module tb_strobe;

  // Ports
  reg        clk;
  reg  [3:0] score_count;
  wire       seg_select;
  wire [3:0] seg_value;

  // Instantiate the module to control the strobing for the 7-seg display
  strobe strobe_inst (
      .clk        (clk),
      .score_count(score_count),
      .seg_select (seg_select),
      .seg_value  (seg_value)
  );

  // Initialise the clock to use in simulation at a speed of 100MHz
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Simulation values
  initial begin
    #200 score_count = 0;
    #200 score_count = 11;
    #200 score_count = 8;
    #200 score_count = 4;
    #200 score_count = 10;
  end


endmodule
