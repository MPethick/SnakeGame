`timescale 1ns / 1ps


module tb_vga_control;

// Ports
  reg         clk;
  reg  [11:0] colour_in;
  wire [ 9:0] addr_h;
  wire [ 8:0] addr_v;
  wire [11:0] colour_out;
  wire        v_sync;
  wire        h_sync;

  // Instantiate the module to control VGA Output 
  vga_control vga_control_inst (
      .clk       (clk),
      .colour_in (colour_in),
      .addr_h    (addr_h),
      .addr_v    (addr_v),
      .colour_out(colour_out),
      .v_sync    (v_sync),
      .h_sync    (h_sync)
  );
  
  // Initialise the clock to use in simulation at a speed of 100MHz
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  //Simulation values
  initial begin
    #200 colour_in = 12'b111111000000;
  end

endmodule
