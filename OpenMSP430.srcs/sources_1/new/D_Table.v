//----------------------------------------------------------------------------
//
// *File Name: D_Table.v
//
// *Module Description: Module for Dirty bit Table or D_Table
//
//
// *Author(s): Christabelle Alvares
// Advisors: Dr. Ivan De Oliveira Nunes, Antonio Joia Neto, Adam Caulfield
//
//----------------------------------------------------------------------------
// $Rev: ?
// $LastChangedDate: --
//----------------------------------------------------------------------------

`include "openMSP430_defines.v"

module D_Table(
    //INPUTS
	clk,
	data_addr,
	data_wr,
	//max_counter, ? Q: max counter as input or parameter?
		
	//OUTPUTS
	D_Table,
	irq_chkpnt
);

// PARAMETERs
//============
parameter ADDR_MSB   =  6;         // MSB of the address bus
parameter BLK_SIZE   =  64;       // Memory size in bytes
parameter BLK_SIZE_SHIFT = 6;      // Constant for shift instead of division by 64
parameter [5:0] MAX_COUNTER = 8;         // THRESHOLD VALUE

// OUTPUTs
//============
// ? Size of counter&temp changes based on # of blocks
// output [5:0] counter;
output [15:0] D_Table;
output irq_chkpnt;

// INPUTs
//============

// ? [15:0]?
input [15:0] data_addr;       // RAM address
input clk;        // RAM clock
input data_wr;        // RAM write enable (low active)

// RAM
//============

reg [15:0] i;

// ? Size of D_Table/tmp_table depends on Dmem size
reg [15:0] tmp_table;
reg [5:0] temp;
reg [5:0] counter;

initial begin
    temp = 0;
    i = 0;
    tmp_table = 0;
    counter = 0;

end

always @(posedge clk)
    begin
      i = data_addr >> BLK_SIZE_SHIFT;
      if(i< 16)
      begin
          temp = temp + {{ADDR_MSB-1{1'b0}},{((~tmp_table[i]) & data_wr)}};
          //$display("temp: %b", temp);
          //$display("table: %b", tmp_table);
          //$display("wr: %b", data_wr);
          tmp_table[i] = tmp_table[i] | data_wr;
      end
    end
assign irq_chkpnt = (MAX_COUNTER<=temp);      //Optimize later
assign D_Table = tmp_table;
endmodule

// Interrupt non-maskable - DONE
// SW side - need to put interrupt program in vrased folder
// NOTE: Debug with vrased.lst in tmpbuild folder