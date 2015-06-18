# OK_WB_Bridge
A bridge between the OpalKelly Pipe and a Wishbone bus

This module allows communication between OpalKelly FrontPanel and the Wishbone (WB) bus.

The bridge acts as a slave on the WB side.
It requires a Xilinx Coregen 16bit wide FIFO to cross clock boundaries. 
I used a 16 double word-deep blocking-when-full FIFO, you can use larger or smaller, depeneding on your
application. Because it is blocking, you won't lose data if the FIFO is too small, but you will likely 
see decreased performance if you are not emptying it quickly enough.

When you use CoreGen, be sure to select the "first word fall-through" option.

To use:
Simply write to the 0x00 in order to send a double-word out on the out-pipe.

Reading uses the same address, 0x00. If there is valid data in the FIFO, it will be in the lower
16 bits. The 17th bit will tell you if the data was valid.

Things may change in the future, particularly because there is currently no way to tell if the 
out-FIFO (from WB to OK) is full. 

This module was developed for use as part of the AltOR32 SOC
by UltraEmbedded (no affiliation with them, but you can find their system on github.) In that system, 
the SOC module takes care of the WB ack signal, thus it is not implemented in this module. The modifcation
should be pretty trivial; you can just assign the ack to not FIFO-out full.

