module top_level (input clk,
                  input rst_n,
                  input wire [3:0] btn,
                  output wire [7:0] channel,
                  output s_sda,
                  output s_clk,
                  output s_rst,
                  output lat,
                  output sb);
  
  wire shield_ready;
  wire write_en;
  wire [5:0] pixel_addr;
  wire [23:0] pixel_value;
  wire up, down, left, right;
  
  reg [2:0] pixel_x, pixel_y;
  
  // We can leave write_en HIGH since just one pixel is sent in entire the INPUT phase
  assign write_en = 1'b1;
  assign pixel_value = 24'hfff_fff;
  assign pixel_addr = {pixel_x, pixel_y};
  
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
   
  buttons btns (.clk(clk),
                .rst_n(rst_n),
                .shield_ready(shield_ready),
                .btn(btn),
                .up(up),
                .down(down),
                .left(left),
                .right(right));

  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      // rough center
      pixel_x <= 3'b100;
      pixel_y <= 3'b100;
    end
    else if (shield_ready) begin
      if (up) pixel_y <= (pixel_y < 3'd7) ? pixel_y + 1 : 3'd7;
      if (down) pixel_y <= (pixel_y > 3'd0) ? pixel_y - 1 : 3'd0;

      if (left) pixel_x <= (pixel_x > 0) ? pixel_x - 1 : 3'd0;
      if (right) pixel_x <= (pixel_x < 3'd7) ? pixel_x + 1 : 3'd7;
    end
  end
endmodule
