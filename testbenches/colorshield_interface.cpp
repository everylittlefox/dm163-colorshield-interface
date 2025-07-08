#include <stdio.h>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vcolorshield_interface.h"

void tick(VerilatedVcdC* tVcd, Vcolorshield_interface* colorshield_interface, unsigned int tick_count);

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    VerilatedVcdC* tVcd = new VerilatedVcdC;
    
    Vcolorshield_interface* colorshield_interface = new Vcolorshield_interface;
    colorshield_interface->trace(tVcd, 99);
    tVcd->open("colorshield_interface.vcd");


    unsigned tick_count = 0;
    colorshield_interface->rst_n = 0;
    for (int k = 0; k < (1 << 14); k++) {
        if (k > 5) {
            colorshield_interface->rst_n = 1;
        }

        tick(tVcd, colorshield_interface, tick_count);
        tick_count++;
    }
}

void tick(VerilatedVcdC* tVcd, Vcolorshield_interface* colorshield_interface, unsigned int tick_count) {
    colorshield_interface->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 - 2 : tick_count);
    colorshield_interface->clk = 1;

    colorshield_interface->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 : 2);
    colorshield_interface->clk = 0;

    colorshield_interface->eval();
    tVcd->dump(tick_count > 0 ? tick_count * 10 + 5: 2 + 5);
    tVcd->flush();
}