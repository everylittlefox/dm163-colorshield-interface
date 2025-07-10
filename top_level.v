module top_level (input clk,
                  input rst_n,
                  output wire [7:0] channel,
                  output s_sda,
                  output s_clk,
                  output s_rst,
                  output lat,
                  output sb);
  
  reg write_en;
  
  wire shield_ready;

  reg [2:0] ball_pos;
  wire [5:0] pixel_addr;
  wire [23:0] pixel_value = 24'hff0000;

  wire ready_edge;

  assign pixel_addr = {ball_pos, 3'b111};
  assign ready_edge = ~write_en & shield_ready; 

  colorshield shield (.clk(clk),
                      .rst_n(rst_n),
                      .write_en(write_en),
                      .pixel_addr(pixel_addr),
                      .pixel_value(pixel_value),
                      .channel(channel),
                      .ready(shield_ready),
                      .s_sda(s_sda),
                      .s_clk(s_clk),
                      .s_rst(s_rst),
                      .lat(lat),
                      .sb(sb));

  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      write_en <= 1'b0;
      ball_pos <= 0;
    end
    else begin
      write_en <= shield_ready;

      if (ready_edge) ball_pos <= ball_pos + 1;
    end
  end
endmodule
