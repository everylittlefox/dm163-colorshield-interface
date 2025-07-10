module pixel_column_mux(input clk,
                        input rst_n,
                        input send_frame,
                        input write_en,
                        input wire [5:0] pixel_addr,
                        input wire [BITS_PER_PIXEL-1:0] pixel_value,
                        output wire [7:0] channel,
                        output s_sda,
                        output s_clk,
                        output latch,
                        output reg frame_done);

  localparam PIXELS_PER_COL = 8;
  localparam BITS_PER_PIXEL = 24;
  localparam N_BITS = PIXELS_PER_COL*BITS_PER_PIXEL;

  localparam LEFT = 1'b0;
  localparam RIGHT = 1'b1;

  localparam READY = 2'b00;
  localparam SWAP = 2'b01;
  localparam WAITLO = 2'b10;
  localparam WAITHI = 2'b11;

  wire col_done;
  wire l_write_en, r_write_en;
  reg clear;
  wire l_clear, r_clear;
  wire [N_BITS-1:0] col_bits, l_col_bits, r_col_bits;
  
  reg [1:0] state, state_next;
  reg [2:0] col_idx, col_idx_next;
  reg active, active_next;
  reg transmit, transmit_next;
  reg [11:0] n_cycles, n_cycles_next;
  wire [7:0] col_idx_ohot;
  reg [7:0] channel_int, channel_next;

  one_hot_encoder ohot (.in(col_idx), .out(col_idx_ohot));

  pixels_grid left_grid  (.clk(clk),
                          .rst_n(rst_n),
                          .write_en(l_write_en),
                          .clear(l_clear),
                          .pixel_addr(pixel_addr),
                          .pixel_value(pixel_value),
                          .read_col_idx(col_idx),
                          .col_bits(l_col_bits));

  pixels_grid right_grid (.clk(clk),
                          .rst_n(rst_n),
                          .write_en(r_write_en),
                          .clear(r_clear),
                          .pixel_addr(pixel_addr),
                          .pixel_value(pixel_value),
                          .read_col_idx(col_idx),
                          .col_bits(r_col_bits));

  transmit_unit #(.N(N_BITS)) tpu (.clk(clk),
                                    .rst_n(rst_n),
                                    .data(col_bits),
                                    .run(transmit),
                                    .s_clk(s_clk),
                                    .s_sda(s_sda),
                                    .latch(latch));
                     
  assign l_write_en = (active == LEFT) ? 1'b0 : write_en;
  assign r_write_en = (active == RIGHT) ? 1'b0 : write_en;

  assign l_clear = (active == LEFT) ? clear : 1'b0;
  assign r_clear = (active == RIGHT) ? clear : 1'b0;

  assign col_done = ~latch;
  assign col_bits = (active == LEFT) ? l_col_bits : r_col_bits;

  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      state <= READY;
      col_idx <= 0;
      transmit <= 1'b0;
      active <= LEFT;
      n_cycles <= 0;
      channel_int <= 0;
    end
    else begin
      state <= state_next;
      col_idx <= col_idx_next;
      transmit <= transmit_next;
      active <= active_next;
      n_cycles <= n_cycles_next;
      channel_int <= channel_next;
    end
  end

  always @(*) begin
    state_next = state;
    active_next = active;
    transmit_next = transmit;
    col_idx_next = col_idx;
    n_cycles_next = n_cycles;
    channel_next = 0;
    frame_done = 1'b0;
    clear = 1'b0;
    
    case (state)
      READY: begin
        transmit_next = 1'b1;
        
        if (send_frame) begin
          state_next = SWAP;
        end

        if (col_done) begin
          transmit_next = 1'b0;
          n_cycles_next = 12'hfff;
          state_next = WAITLO;
        end
      end
      SWAP: begin
        clear = 1'b1;
        active_next = ~active;
        state_next = READY;
      end
      WAITLO: begin
        if (n_cycles > 0) begin
          n_cycles_next = n_cycles - 1;
        end else begin
          n_cycles_next = 12'hfff;
          state_next = WAITHI;
        end
      end
      WAITHI: begin
        channel_next = col_idx_ohot;

        if (n_cycles > 0) begin
          n_cycles_next = n_cycles - 1;
        end else begin
          state_next = READY;
          transmit_next = 1'b1;
          col_idx_next = col_idx + 1;

          if (col_idx == 3'd7) frame_done = 1'b1;
        end
      end
      default: state_next = READY;
    endcase
  end

  assign channel = channel_int;
endmodule
