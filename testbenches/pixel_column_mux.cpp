#include <stdio.h>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vpixel_column_mux.h"

void tick(VerilatedVcdC* tVcd, Vpixel_column_mux* pixel_column_mux, unsigned int tick_count);

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    VerilatedVcdC* tVcd = new VerilatedVcdC;
    
    Vpixel_column_mux* pixel_column_mux = new Vpixel_column_mux;
    pixel_column_mux->trace(tVcd, 99);
    tVcd->open("pixel_column_mux.vcd");


    unsigned tick_count = 0;
    pixel_column_mux->rst_n = 0;
    for (int k = 0; k < (1 << 14); k++) {
        if (k > 5) {
            pixel_column_mux->rst_n = 1;
        }

        if (k == 10) {
            pixel_column_mux->pixel_addr = 0b011100;
            pixel_column_mux->pixel_value = 0xffffff;
            pixel_column_mux->write_en = 1;
        } else if (k == 20) {
            pixel_column_mux->pixel_addr = 0b000000;
            pixel_column_mux->pixel_value = 0x00ff00;
            pixel_column_mux->write_en = 1;
        } else if (k == 25) {
            pixel_column_mux->send_frame = 1;
        } else {
            pixel_column_mux->write_en = 0;
            pixel_column_mux->send_frame = 0;
        }

        tick(tVcd, pixel_column_mux, tick_count);
        tick_count++;
    }
}

void tick(VerilatedVcdC* tVcd, Vpixel_column_mux* pixel_column_mux, unsigned int tick_count) {
    pixel_column_mux->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 - 2 : tick_count);
    pixel_column_mux->clk = 1;

    pixel_column_mux->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 : 2);
    pixel_column_mux->clk = 0;

    pixel_column_mux->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 + 5: 2 + 5);
    tVcd->flush();
}