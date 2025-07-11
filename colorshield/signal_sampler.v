module signal_sampler #(parameter N = 4)
                      (input clk,
                       input rst_n,
                       input shield_ready,
                       input wire [N-1:0] signal,
                       output reg [N-1:0] sampled);

  wire shield_ready_rising;

  rising_edge_detector s_rising (.clk(clk), .signal(shield_ready), .rising_edge(shield_ready_rising));

  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      sampled <= 0;
    end
    else begin
      if (shield_ready_rising) sampled <= signal;
    end
  end

endmodule
