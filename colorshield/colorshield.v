module colorshield (input clk,
                    input rst_n,
                    input write_en,
                    input wire [5:0] pixel_addr,
                    input wire [23:0] pixel_value,
                    output wire [7:0] channel,
                    output reg ready,
                    output s_sda,
                    output s_clk,
                    output s_rst,
                    output lat,
                    output sb);

  localparam [3:0] N_RST_INPUT = 8;
  localparam N_GAMMA = 6 * 24; // 24 channels * 6 bits per channel
  localparam W = 18; // 2^W is the number of cycles to wait before next paint

  localparam [5:0] RED_GAMMA = 63;
  localparam [5:0] GREEN_GAMMA = 63;
  localparam [5:0] BLUE_GAMMA = 63;

  localparam PAINT = 1'b0;
  localparam INPUT = 1'b1;

  reg [3:0] n_rst_cycles;
  reg s_rst_int;
  reg rst_done;
  reg sb_int;
  wire sb_next;
  wire [N_GAMMA-1:0] g_data = {8{RED_GAMMA, GREEN_GAMMA, BLUE_GAMMA}};

  reg g_done;
  wire g_done_n;
  wire should_transmit;

  wire g_latch, p_latch;
  wire g_clk, p_clk;
  wire g_sda, p_sda;
  wire p_frame_done;

  reg state, state_next;
  reg [W-1:0] frame_wait, frame_wait_next;
  wire write_en_int;
  reg send_frame;

  assign g_done_n = ~g_latch | g_done;
  assign should_transmit = rst_done & ~g_done;
  assign sb_next = sb_int | g_done;
  assign write_en_int = write_en & ready;

  transmit_unit #(.N(N_GAMMA)) txu (.clk(clk),
                                    .rst_n(rst_n),
                                    .data(g_data),
                                    .run(should_transmit),
                                    .s_clk(g_clk),
                                    .s_sda(g_sda),
                                    .latch(g_latch));

  pixel_column_mux pix_unit (.clk(clk),
                              .rst_n(rst_n),
                              .send_frame(send_frame),
                              .write_en(write_en_int),
                              .pixel_addr(pixel_addr),
                              .pixel_value(pixel_value),
                              .channel(channel),
                              .s_sda(p_sda),
                              .s_clk(p_clk),
                              .latch(p_latch),
                              .frame_done(p_frame_done));

  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      n_rst_cycles <= N_RST_INPUT;
      sb_int <= 0;
      g_done <= 0;
      s_rst_int <= 1'b0;
      rst_done <= 1'b0;

      state <= INPUT;
      frame_wait <= 0;
    end
    else begin
      n_rst_cycles <= (n_rst_cycles > 0) ? n_rst_cycles - 1 : n_rst_cycles;
      sb_int <= sb_next;
      g_done <= g_done_n;
      rst_done <= s_rst_int;
      s_rst_int <= n_rst_cycles == 0;

      state <= state_next;
      frame_wait <= frame_wait_next;
    end
  end

  always @(*) begin
    state_next = state;
    frame_wait_next = frame_wait;
    send_frame = 1'b0;

    case (state)
      PAINT: begin
        ready = 1'b0;

        if (p_frame_done) begin
          frame_wait_next = {W{1'b1}};
          state_next = INPUT;
        end
      end
      INPUT: begin
        ready = g_done;

        if (frame_wait > 0) frame_wait_next = frame_wait - 1;
        else begin
          state_next = PAINT;
          send_frame = 1'b1;
        end
      end
    endcase
  end

  assign s_rst = s_rst_int;
  assign lat = (g_done) ? p_latch : g_latch;
  assign s_sda = (g_done) ? p_sda : g_sda;
  assign s_clk = (g_done) ? p_clk : g_clk;
  assign sb = sb_int;
endmodule
