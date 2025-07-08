#include <stdio.h>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vcolorshield.h"

void tick(VerilatedVcdC* tVcd, Vcolorshield* colorshield, unsigned int tick_count);

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    VerilatedVcdC* tVcd = new VerilatedVcdC;
    
    Vcolorshield* colorshield = new Vcolorshield;
    colorshield->trace(tVcd, 99);
    tVcd->open("colorshield.vcd");


    unsigned tick_count = 0;
    colorshield->rst_n = 0;
    for (int k = 0; k < (1 << 14); k++) {
        if (k > 5) {
            colorshield->rst_n = 1;
        }

        if (k == 10) {
            colorshield->pixel_addr = 0b011100;
            colorshield->pixel_value = 0xffffff;
            colorshield->write_en = 1;
        } else if (k == 20) {
            colorshield->pixel_addr = 0b000000;
            colorshield->pixel_value = 0x00ff00;
            colorshield->write_en = 1;
        } else if (k == 25) {
            colorshield->send_frame = 1;
        } else {
            colorshield->write_en = 0;
            colorshield->send_frame = 0;
        }

        tick(tVcd, colorshield, tick_count);
        tick_count++;
    }
}

void tick(VerilatedVcdC* tVcd, Vcolorshield* colorshield, unsigned int tick_count) {
    colorshield->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 - 2 : tick_count);
    colorshield->clk = 1;

    colorshield->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 : 2);
    colorshield->clk = 0;

    colorshield->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 + 5: 2 + 5);
    tVcd->flush();
}