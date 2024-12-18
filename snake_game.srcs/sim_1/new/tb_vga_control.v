`timescale 1ns / 1ps


module tb_vga_control;

// Ports
  reg         clk;
  reg         vga_clk;
  reg  [11:0] colour_in;
  wire [ 9:0] addr_h;
  wire [ 8:0] addr_v;
  wire        v_sync;
  wire        h_sync;
  wire        vde;
  wire [11:0] colour_out;

  // Instantiate the module to control VGA Output 
  vga_control vga_control_inst (
      .clk       (clk),
      .vga_clk   (vga_clk),
      .colour_in (colour_in),
      .addr_h    (addr_h),
      .addr_v    (addr_v),
      .v_sync    (v_sync),
      .h_sync    (h_sync),
      .vde       (vde),
      .colour_out(colour_out)
  );
  
  // Initialise the clock to use in simulation at a speed of 125MHz
  initial begin
    clk = 0;
    forever #4 clk = ~clk;
  end

  // Initialise the clock to use in simulation at a speed of 25MHz
  initial begin
    vga_clk = 0;
    forever #20 vga_clk = ~vga_clk;
  end

  //Simulation values
  initial begin
    #200 colour_in = 12'b111111000000;
  end

endmodule
