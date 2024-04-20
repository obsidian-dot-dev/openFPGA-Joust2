module rom_storage (
  input wire clk,
  input wire cs,
  input wire wr_en,
  
  input wire [14:0] addr,     // 32KB roms
  input wire [1:0] bank,      // 4 banks
  input wire [7:0] din,       // 8-bit input data (for ROM loading)
  
  output wire [7:0] dout,     // 8-bit output data 

  // -- sram bus parameters
  output wire [16:0] sram_a,
  inout wire [15:0] sram_dq,
  output wire sram_oe_n,
  output wire sram_we_n,
  output wire sram_ub_n,
  output wire sram_lb_n
);

assign sram_oe_n     = 1'b1;                    // Output always enabled
assign sram_we_n     = cs ? wr_en : 1'b0;       // write enable only applies when reset not held.
assign sram_ub_n     = 1'b0;                    // Only using the lower 8-bits of SRAM.
assign sram_lb_n     = 1'b1;                    // Only using the lower 8-bits of SRAM.

assign sram_a        = cs ? {bank, addr} : 15'b0;            // Address is zero when deselected.
assign sram_dq[7:0]  = cs ? (wr_en ? din  : 8'bzz) : 8'bzz;  // Write to low word when write-enabled, high-z when not writing or not selected
assign sram_dq[15:8] = cs ? (wr_en ? 8'b0 : 8'bzz) : 8'bzz;  // Write high word as zero when write-enabled

assign dout          = cs ? sram_dq[7:0] : 8'b0;

endmodule
