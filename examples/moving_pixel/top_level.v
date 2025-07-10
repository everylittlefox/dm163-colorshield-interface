module top_level (input clk,
                  input rst_n,
                  output wire [7:0] channel,
                  output s_sda,
                  output s_clk,
                  output s_rst,
                  output lat,
                  output sb);
  
  wire shield_ready, write_en;

  reg [2:0] ball_pos;
  wire [5:0] pixel_addr;
  wire [23:0] pixel_value = 24'hff0000;
  reg [7:0] ball_speed; // TODO: pick a better name than "speed", which is incorrect

  reg shield_ready_int;
  wire ready_edge;

  // We can leave write_en HIGH since just one pixel is sent in entire the INPUT phase
  assign write_en = 1'b1;
  assign pixel_addr = {ball_pos, 3'b111};
  assign ready_edge = shield_ready & ~shield_ready_int;
  
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
      ball_pos <= 0;
      ball_speed <= 8'hff;
      shield_ready_int <= 1'b0;
    end
    else begin
      shield_ready_int <= shield_ready;
      
      if (ready_edge) begin
        ball_speed <= ball_speed - 1;

        if (ball_speed == 0) ball_pos <= ball_pos + 1;
      end
    end
  end
endmodule
