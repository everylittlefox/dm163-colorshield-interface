module pixels_grid (input clk,
                     input rst_n,
                     input write_en,
                     input clear,
                     input wire [5:0] pixel_addr,
                     input wire [BITS_PER_PIXEL-1:0] pixel_value,
                     input [2:0] read_col_idx,
                     output [N_BITS-1:0] col_bits);

  localparam PIXELS_PER_COL = 8;
  localparam N_COLS = 8;
  localparam BITS_PER_PIXEL = 24;
  localparam N_BITS = PIXELS_PER_COL*BITS_PER_PIXEL;
  integer i;
  
  wire [2:0] x_coord, y_coord;
  reg [N_BITS-1:0] pixels [N_COLS-1:0];
  
  assign {x_coord, y_coord} = pixel_addr;
  assign col_bits = pixels[read_col_idx];

  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      for (i = 0; i < N_COLS; i = i + 1) begin: reset_for
        pixels[i] <= {PIXELS_PER_COL{24'h000000}};
      end
    end else if (write_en) begin
      pixels[x_coord][y_coord * BITS_PER_PIXEL +: BITS_PER_PIXEL] <= pixel_value;
    end else if (clear) begin
      for (i = 0; i < N_COLS; i = i + 1) begin: clear_for
        pixels[i] <= {PIXELS_PER_COL{24'h000000}};
      end
    end
  end
endmodule
