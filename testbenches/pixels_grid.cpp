#include <stdio.h>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vpixels_grid.h"

void tick(VerilatedVcdC* tVcd, Vpixels_grid* pixels_grid, unsigned int tick_count);

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    VerilatedVcdC* tVcd = new VerilatedVcdC;
    
    Vpixels_grid* pixels_grid = new Vpixels_grid;
    pixels_grid->trace(tVcd, 99);
    tVcd->open("pixels_grid.vcd");


    unsigned tick_count = 0;
    pixels_grid->rst_n = 0;
    for (int k = 0; k < (1 << 8); k++) {
        if (k > 5) {
            pixels_grid->rst_n = 1;
        }

        if (k == 10) {
            pixels_grid->pixel_addr = 0b011100;
            pixels_grid->pixel_value = 0xffffff;
            pixels_grid->write_en = 1;
        } else pixels_grid->write_en = 0;

        tick(tVcd, pixels_grid, tick_count);
        tick_count++;
    }
}

void tick(VerilatedVcdC* tVcd, Vpixels_grid* pixels_grid, unsigned int tick_count) {
    pixels_grid->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 - 2 : tick_count);
    pixels_grid->clk = 1;

    pixels_grid->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 : 2);
    pixels_grid->clk = 0;

    pixels_grid->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 + 5: 2 + 5);
    tVcd->flush();
}