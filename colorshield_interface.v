module colorshield_interface(input clk,
                              input rst_n,
                              input sw0,
                              // input wire [3:0] btn,
                              // output wire [3:0] led,
                              output wire [7:0] channel,
                              output s_sda,
                              output s_clk,
                              output s_rst,
                              output lat,
                              output sb);

  localparam [3:0] N_RST_WAIT = 8;
  localparam N_GAMMA = 6 * 24; // 24 channels * 6 bits per channel
  localparam N_PIXEL = 8 * 24;

  localparam [5:0] RED_GAMMA = 20;
  localparam [5:0] GREEN_GAMMA = 63;
  localparam [5:0] BLUE_GAMMA = 40;  

  reg [3:0] n_rst_cycles;  
  reg s_rst_int;
  reg rst_done;
  reg sb_int;
  wire sb_next;
  wire [N_GAMMA-1:0] g_data = {8{RED_GAMMA, GREEN_GAMMA, BLUE_GAMMA}};
  wire [N_PIXEL-1:0] p_data = {8{24'h00ff00}};

  reg g_done;
  wire g_done_n;
  wire should_transmit;

  wire g_latch, p_latch;
  wire g_clk, p_clk;
  wire g_sda, p_sda;

  assign g_done_n = ~g_latch | g_done;
  assign should_transmit = rst_done & ~g_done;
  assign sb_next = sb_int | g_done;

  transmit_unit #(.N(N_GAMMA)) txu (.clk(clk),
                     .rst_n(rst_n),
                     .data(g_data),
                     .run(should_transmit),
                     .s_clk(g_clk),
                     .s_sda(g_sda),
                     .latch(g_latch));

  transmit_unit #(.N(N_PIXEL)) tpu (.clk(clk),
                     .rst_n(rst_n),
                     .data(p_data),
                     .run(g_done),
                     .s_clk(p_clk),
                     .s_sda(p_sda),
                     .latch(p_latch));

  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      n_rst_cycles <= N_RST_WAIT;

      sb_int <= 0;
      g_done <= 0;
      s_rst_int <= 1'b0;
      rst_done <= 1'b0;
    end
    else begin
      n_rst_cycles <= (n_rst_cycles > 0) ? n_rst_cycles - 1 : n_rst_cycles;

      sb_int <= sb_next;
      g_done <= g_done_n;
      rst_done <= s_rst_int;
      s_rst_int <= n_rst_cycles == 0;
    end
  end

  assign channel = {{7{1'b0}}, sw0};
  assign s_rst = s_rst_int;
  assign lat = (g_done) ? p_latch : g_latch;
  assign s_sda = (g_done) ? p_sda : g_sda;
  assign s_clk = (g_done) ? p_clk : g_clk;
  assign sb = sb_int;
endmodule
