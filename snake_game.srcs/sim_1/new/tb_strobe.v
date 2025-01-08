`timescale 1ns / 1ps


module tb_strobe;

  // Ports
  reg        clk;
  reg  [3:0] score_count;
  wire [2:0] seg_select;
  wire [3:0] bin_in;
  wire [7:0] seg_select_out;
  wire [7:0] dec_out;

  // Instantiate the module to control the strobing for the 7-seg display
  strobe strobe_inst (
      .clk        (clk),
      .score_count(score_count),
      .seg_select (seg_select),
      .seg_value  (bin_in)
  );

  // Instantiate the module to control the value on thr 7-seg display  
  seg_7_display seg_7_display_inst (
      .bin_in        (bin_in),
      .seg_select    (seg_select),
      .dot_in        (1'b0),
      .seg_select_out(seg_select_out),
      .dec_out       (dec_out)
  );

  // Initialise the clock to use in simulation at a speed of 100MHz
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Simulation values
  initial begin
    score_count = 0;
    #20000000 score_count = 11;
    #20000000 score_count = 8;
    #20000000 score_count = 4;
    #20000000 score_count = 10;
  end


endmodule
