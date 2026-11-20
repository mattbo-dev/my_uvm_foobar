`timescale 1ns / 1ps

module tb_top;

  import uvm_pkg::*;
  import my_uvm_pkg::*;

  logic       clk;
  logic       rst_n;
  logic [7:0] data_in;
  logic [7:0] data_out;

  // Instantiate the sample DUT from rtl/dut.sv
  dut u_dut (
      .clk     (clk),
      .rst_n   (rst_n),
      .data_in (data_in),
      .data_out(data_out)
  );

  // 100 MHz clock: 10 ns period
  initial begin
    clk = 1'b0;

    forever begin
      #5ns clk = ~clk;
    end
  end

  // Reset and simple stimulus
  initial begin
    rst_n   = 1'b0;
    data_in = 8'h00;

    repeat (2) @(posedge clk);
    rst_n = 1'b1;

    // Apply 0x12
    @(negedge clk);
    data_in = 8'h12;

    @(posedge clk);
    #1ns;

    if (data_out !== 8'h12) begin
      $error("DUT mismatch: expected 0x12, got 0x%02h", data_out);
    end

    // Apply 0x34
    @(negedge clk);
    data_in = 8'h34;

    @(posedge clk);
    #1ns;

    if (data_out !== 8'h34) begin
      $error("DUT mismatch: expected 0x34, got 0x%02h", data_out);
    end else begin
      $display("DUT smoke test passed: data_out=0x%02h", data_out);
    end
  end

  // Start UVM
  initial begin
    run_test();
  end

  // Waveform output used with --trace-fst
  initial begin
    $dumpfile("waves.fst");
    $dumpvars(0, tb_top);
  end

endmodule
