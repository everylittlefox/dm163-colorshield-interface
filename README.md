# dm163 colorshield interface

herein lies a verilog implementation of an interface between your module and the 8x8 LED colorshield, powered by the DM163 LED driver (![datasheet](https://www.digchip.com/datasheets/download_datasheet.php?id=1933103&part-number=DM163)). once `ready` goes high, write one pixel per cycle to the colorshield. this will be the next frame. the module has been synthesized on the PYNQ Z1 board from Xilinx with the examples in the `examples` subdirectory.

## examples

Single pixel moving in one direction:

Single pixel moved by pushing buttons:
![](https://github.com/everylittlefox/dm163-colorshield-interface/blob/main/interactive-pixel.mp4)
