module top_level (input clk,
                  input rst_n,
                  output wire [7:0] channel,
                  output s_sda,
                  output s_clk,
                  output s_rst,
                  output lat,
                  output sb);

  localparam GMA = 2'b00;
  localparam SND = 2'b01;
  localparam PIX = 2'b10;
  
  reg [1:0] state, state_next;
  reg write_en;
  reg send_frame, send_frame_next;
  
  wire shield_ready;
  wire [5:0] pixel_addr = 6'b100_000;
  wire [23:0] pixel_value = 24'hff0000;

  colorshield shield (.clk(clk),
                      .rst_n(rst_n),
                      .write_en(write_en),
                      .pixel_addr(pixel_addr),
                      .pixel_value(pixel_value),
                      .send_frame(send_frame),
                      .channel(channel),
                      .ready(shield_ready),
                      .s_sda(s_sda),
                      .s_clk(s_clk),
                      .s_rst(s_rst),
                      .lat(lat),
                      .sb(sb));

  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      state <= GMA;
      send_frame <= 1'b0;
    end
    else begin
      state <= state_next;
      send_frame <= send_frame_next;
    end
  end

  always @(*) begin
    write_en = 1'b0;
    state_next = state;
    send_frame_next = send_frame;

    case (state)
      GMA: begin
        if (shield_ready) begin
          write_en = 1'b1;
          state_next = SND;
        end
      end
      SND: begin
        send_frame_next = 1'b1;
        state_next = PIX;
      end
      PIX: begin
        send_frame_next = 1'b0;
      end
      default: state_next = GMA;
    endcase
  end
endmodule
