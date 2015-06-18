

module OK_WB_Bridge(
    input wire [30:0] ok1,
    output wire [16:0] ok2,
    input wire ti_clk,
    input wire clk_i,
    input wire rst_i,
    input wire stb_i,
    input wire [7:0] adr_i,
    input wire we_i,
    input  wire [31:0] dat_i,
    output wire [31:0] dat_o
);

    // Wire declarations
    wire OKfifowrite;
    wire OKfiforead;
    wire [15:0] OKdatain;
    wire [15:0] OKdataout;
    wire [15:0] OK_rec_dat;

    wire n_fifo_em;
    wire fifoem;
    wire fifofull1;
    wire fifofull2;

    wire [17*2-1:0]  ok2x;
    okWireOR # (.N(2)) wireOR (ok2, ok2x);
        
    //Circuit behavior

    assign dat_o = {15'b0, ~n_fifo_em, OK_rec_dat};
        
    FIFO_16bit_dual_port fifo_in (
         .rst(rst_i), // input rst
         .wr_clk(ti_clk), // input wr_clk
         .rd_clk(clk_i), // input rd_clk
         .din(OKdatain), // input [15 : 0] din
         .wr_en(OKfifowrite), // input wr_en
         .rd_en(stb_i & ~we_i), // input rd_en
         .dout(OK_rec_dat), // output [15 : 0] dout
         .full(fifofull1), // output full
         .empty(n_fifo_em) // output empty
    );
        
    FIFO_16bit_dual_port fifo_out (
         .rst(rst_i), // input rst
         .wr_clk(clk_i), // input wr_clk
         .rd_clk(ti_clk), // input rd_clk
         .din(dat_i), // input [15 : 0] din
         .wr_en(stb_i & we_i), // input wr_en
         .rd_en(OKfiforead), // input rd_en
         .dout(OKdataout), // output [15 : 0] dout
         .full(fifofull2), // output full
         .empty(fifoem) // output empty
    );
     
    //FrontPanel endpoint instantiations
    okBTPipeIn pipe80(
         .ok1(ok1),
         .ok2(ok2x[0*17 +: 17]),
         .ep_addr(8'h80),
         .ep_write(OKfifowrite),
         .ep_dataout(OKdatain),
         .ep_ready(~fifofull1)
    );
        
    okBTPipeOut pipeA0(
         .ok1(ok1),
         .ok2(ok2x[1*17 +: 17]),
         .ep_addr(8'hA0),
         .ep_read(OKfiforead),
         .ep_datain(OKdataout),
         .ep_ready(~fifoem)
    );

endmodule
