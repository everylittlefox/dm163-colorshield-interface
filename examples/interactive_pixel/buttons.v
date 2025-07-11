module buttons (input clk,
                input rst_n,
                input shield_ready,
                input wire [3:0] btn,
                output up,
                output down,
                output left,
                output right);

  wire up_int, down_int, left_int, right_int;
  wire [3:0] btn_sample;

  assign {up_int, down_int, left_int, right_int} = btn_sample;

  signal_sampler btn_sampler (.clk(clk),
                             .rst_n(rst_n),
                             .shield_ready(shield_ready),
                             .signal(btn),
                             .sampled(btn_sample));

  rising_edge_detector r_up (.clk(clk), .signal(up_int), .rising_edge(up));
  rising_edge_detector r_down (.clk(clk), .signal(down_int), .rising_edge(down));
  rising_edge_detector r_left (.clk(clk), .signal(left_int), .rising_edge(left));
  rising_edge_detector r_right (.clk(clk), .signal(right_int), .rising_edge(right));

endmodule
