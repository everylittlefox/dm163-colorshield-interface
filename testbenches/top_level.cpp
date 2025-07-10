#include <stdio.h>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vtop_level.h"

void tick(VerilatedVcdC* tVcd, Vtop_level* top_level, unsigned int tick_count);

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    VerilatedVcdC* tVcd = new VerilatedVcdC;
    
    Vtop_level* top_level = new Vtop_level;
    top_level->trace(tVcd, 99);
    tVcd->open("top_level.vcd");


    unsigned tick_count = 0;
    top_level->rst_n = 0;
    for (int k = 0; k < (1 << 18); k++) {
        if (k > 5) {
            top_level->rst_n = 1;
        }

        tick(tVcd, top_level, tick_count);
        tick_count++;
    }
}

void tick(VerilatedVcdC* tVcd, Vtop_level* top_level, unsigned int tick_count) {
    top_level->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 - 2 : tick_count);
    top_level->clk = 1;

    top_level->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 : 2);
    top_level->clk = 0;

    top_level->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 + 5: 2 + 5);
    tVcd->flush();
}