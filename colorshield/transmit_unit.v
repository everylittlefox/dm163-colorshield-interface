module transmit_unit
                    #(parameter N = 8)
                    (input clk,
                     input rst_n,
                     input wire [N-1:0] data,
                     input run,
                     output s_clk,
                     output s_sda,
                     output reg latch);
                    //  output ready_out);

  localparam N_BIT = $clog2(N);
  localparam [1:0] N_CLK_HALF_PERIOD = 2;
  localparam CHECK = 3'b000;
  localparam INIT  = 3'b100;
  localparam TRANS = 3'b001;
  localparam DNCLK = 3'b010;
  localparam UPCLK = 3'b011;

  reg [N_BIT:0] bit_count, bit_count_next;
  reg [N-1:0] data_int, data_next;
  reg [2:0] state, state_next;
  reg [1:0] clk_wait, clk_wait_next;
  reg s_clk_int, s_clk_next;
  // reg ready_int, ready_next;
  reg s_sda_int, s_sda_next;


  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      bit_count <= 0;
      data_int <= 0;
      state <= INIT;
      s_clk_int <= 1'b0;
      s_sda_int <= 1'b0;
      // ready_int <= 1'b1;
      clk_wait <= 0;
    end
    else begin
      bit_count <= bit_count_next;
      data_int <= data_next;
      state <= state_next;
      clk_wait <= clk_wait_next;
      s_clk_int <= s_clk_next;
      s_sda_int <= s_sda_next;
      // ready_int <= ready_next;
    end
  end

  always @(*) begin
    s_clk_next = s_clk_int;
    s_sda_next = s_sda_int;
    state_next = state;
    data_next = data_int;
    clk_wait_next = clk_wait;
    // ready_next = ready_int;
    bit_count_next = bit_count;
    latch = 1'b1;

    case (state)
      INIT: begin
        s_clk_next = 1'b0;
        s_sda_next = 1'b0;
        // ready_next = 1'b1;

        if (run) begin
          state_next = CHECK;
          bit_count_next = N[N_BIT:0];
          data_next = data;
        end
      end
      CHECK: begin
        s_clk_next = 1'b0;
        s_sda_next = 1'b0;
        // ready_next = 1'b0;
        
        if (bit_count > 0) begin
          state_next = TRANS;
        end else begin
          latch = 1'b0;
          state_next = INIT;
        end
      end
      TRANS: begin        
        s_sda_next = data_int[N-1];
        data_next = data_int << 1;
        bit_count_next = bit_count - 1;
        s_clk_next = 1'b0;
        state_next = DNCLK;
        clk_wait_next = N_CLK_HALF_PERIOD;
      end
      DNCLK: begin        
        if (clk_wait == 2'b00) begin
          s_clk_next = 1'b1;
          clk_wait_next = N_CLK_HALF_PERIOD;
          state_next = UPCLK;
        end else clk_wait_next = clk_wait - 1;
      end
      UPCLK: begin
        if (clk_wait == 2'b00) begin
          s_clk_next = 1'b0;
          state_next = CHECK;
          s_sda_next = 1'b0;
        end else clk_wait_next = clk_wait - 1;
      end
      default: state_next = INIT;
    endcase
  end

  assign s_clk = s_clk_int;
  assign s_sda = s_sda_int;
  // assign ready_out = ready_int;

endmodule
