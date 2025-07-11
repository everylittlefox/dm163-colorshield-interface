module rising_edge_detector (input clk,
                             input signal,
                             output rising_edge);

  reg signal_int;

  always @(posedge clk) begin
    signal_int <= signal;
  end
  
  assign rising_edge = signal & ~signal_int;
endmodule
