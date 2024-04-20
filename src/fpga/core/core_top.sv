//
//
// User core top-level
//
// Instantiated by the real top-level: apf_top
//

`default_nettype none

module core_top (

//
// physical connections
//

///////////////////////////////////////////////////
// clock inputs 74.25mhz. not phase aligned, so treat these domains as asynchronous

input   wire            clk_74a, // mainclk1
input   wire            clk_74b, // mainclk1 

///////////////////////////////////////////////////
// cartridge interface
// switches between 3.3v and 5v mechanically
// output enable for multibit translators controlled by pic32

// GBA AD[15:8]
inout   wire    [7:0]   cart_tran_bank2,
output  wire            cart_tran_bank2_dir,

// GBA AD[7:0]
inout   wire    [7:0]   cart_tran_bank3,
output  wire            cart_tran_bank3_dir,

// GBA A[23:16]
inout   wire    [7:0]   cart_tran_bank1,
output  wire            cart_tran_bank1_dir,

// GBA [7] PHI#
// GBA [6] WR#
// GBA [5] RD#
// GBA [4] CS1#/CS#
//     [3:0] unwired
inout   wire    [7:4]   cart_tran_bank0,
output  wire            cart_tran_bank0_dir,

// GBA CS2#/RES#
inout   wire            cart_tran_pin30,
output  wire            cart_tran_pin30_dir,
// when GBC cart is inserted, this signal when low or weak will pull GBC /RES low with a special circuit
// the goal is that when unconfigured, the FPGA weak pullups won't interfere.
// thus, if GBC cart is inserted, FPGA must drive this high in order to let the level translators
// and general IO drive this pin.
output  wire            cart_pin30_pwroff_reset,

// GBA IRQ/DRQ
inout   wire            cart_tran_pin31,
output  wire            cart_tran_pin31_dir,

// infrared
input   wire            port_ir_rx,
output  wire            port_ir_tx,
output  wire            port_ir_rx_disable, 

// GBA link port
inout   wire            port_tran_si,
output  wire            port_tran_si_dir,
inout   wire            port_tran_so,
output  wire            port_tran_so_dir,
inout   wire            port_tran_sck,
output  wire            port_tran_sck_dir,
inout   wire            port_tran_sd,
output  wire            port_tran_sd_dir,
 
///////////////////////////////////////////////////
// cellular psram 0 and 1, two chips (64mbit x2 dual die per chip)

output  wire    [21:16] cram0_a,
inout   wire    [15:0]  cram0_dq,
input   wire            cram0_wait,
output  wire            cram0_clk,
output  wire            cram0_adv_n,
output  wire            cram0_cre,
output  wire            cram0_ce0_n,
output  wire            cram0_ce1_n,
output  wire            cram0_oe_n,
output  wire            cram0_we_n,
output  wire            cram0_ub_n,
output  wire            cram0_lb_n,

output  wire    [21:16] cram1_a,
inout   wire    [15:0]  cram1_dq,
input   wire            cram1_wait,
output  wire            cram1_clk,
output  wire            cram1_adv_n,
output  wire            cram1_cre,
output  wire            cram1_ce0_n,
output  wire            cram1_ce1_n,
output  wire            cram1_oe_n,
output  wire            cram1_we_n,
output  wire            cram1_ub_n,
output  wire            cram1_lb_n,

///////////////////////////////////////////////////
// sdram, 512mbit 16bit

output  wire    [12:0]  dram_a,
output  wire    [1:0]   dram_ba,
inout   wire    [15:0]  dram_dq,
output  wire    [1:0]   dram_dqm,
output  wire            dram_clk,
output  wire            dram_cke,
output  wire            dram_ras_n,
output  wire            dram_cas_n,
output  wire            dram_we_n,

///////////////////////////////////////////////////
// sram, 1mbit 16bit

output  wire    [16:0]  sram_a,
inout   wire    [15:0]  sram_dq,
output  wire            sram_oe_n,
output  wire            sram_we_n,
output  wire            sram_ub_n,
output  wire            sram_lb_n,

///////////////////////////////////////////////////
// vblank driven by dock for sync in a certain mode

input   wire            vblank,

///////////////////////////////////////////////////
// i/o to 6515D breakout usb uart

output  wire            dbg_tx,
input   wire            dbg_rx,

///////////////////////////////////////////////////
// i/o pads near jtag connector user can solder to

output  wire            user1,
input   wire            user2,

///////////////////////////////////////////////////
// RFU internal i2c bus 

inout   wire            aux_sda,
output  wire            aux_scl,

///////////////////////////////////////////////////
// RFU, do not use
output  wire            vpll_feed,


//
// logical connections
//

///////////////////////////////////////////////////
// video, audio output to scaler
output  wire    [23:0]  video_rgb,
output  wire            video_rgb_clock,
output  wire            video_rgb_clock_90,
output  wire            video_de,
output  wire            video_skip,
output  wire            video_vs,
output  wire            video_hs,
    
output  wire            audio_mclk,
input   wire            audio_adc,
output  wire            audio_dac,
output  wire            audio_lrck,

///////////////////////////////////////////////////
// bridge bus connection
// synchronous to clk_74a
output  wire            bridge_endian_little,
input   wire    [31:0]  bridge_addr,
input   wire            bridge_rd,
output  reg     [31:0]  bridge_rd_data,
input   wire            bridge_wr,
input   wire    [31:0]  bridge_wr_data,

///////////////////////////////////////////////////
// controller data
// 
// key bitmap:
//   [0]    dpad_up
//   [1]    dpad_down
//   [2]    dpad_left
//   [3]    dpad_right
//   [4]    face_a
//   [5]    face_b
//   [6]    face_x
//   [7]    face_y
//   [8]    trig_l1
//   [9]    trig_r1
//   [10]   trig_l2
//   [11]   trig_r2
//   [12]   trig_l3
//   [13]   trig_r3
//   [14]   face_select
//   [15]   face_start
// joy values - unsigned
//   [ 7: 0] lstick_x
//   [15: 8] lstick_y
//   [23:16] rstick_x
//   [31:24] rstick_y
// trigger values - unsigned
//   [ 7: 0] ltrig
//   [15: 8] rtrig
//
input   wire    [15:0]  cont1_key,
input   wire    [15:0]  cont2_key,
input   wire    [15:0]  cont3_key,
input   wire    [15:0]  cont4_key,
input   wire    [31:0]  cont1_joy,
input   wire    [31:0]  cont2_joy,
input   wire    [31:0]  cont3_joy,
input   wire    [31:0]  cont4_joy,
input   wire    [15:0]  cont1_trig,
input   wire    [15:0]  cont2_trig,
input   wire    [15:0]  cont3_trig,
input   wire    [15:0]  cont4_trig
    
);

// not using the IR port, so turn off both the LED, and
// disable the receive circuit to save power
assign port_ir_tx = 0;
assign port_ir_rx_disable = 1;

// bridge endianness
assign bridge_endian_little = 0;

// cart is unused, so set all level translators accordingly
// directions are 0:IN, 1:OUT
assign cart_tran_bank3 = 8'hzz;
assign cart_tran_bank3_dir = 1'b0;
assign cart_tran_bank2 = 8'hzz;
assign cart_tran_bank2_dir = 1'b0;
assign cart_tran_bank1 = 8'hzz;
assign cart_tran_bank1_dir = 1'b0;
assign cart_tran_bank0 = 4'hf;
assign cart_tran_bank0_dir = 1'b1;
assign cart_tran_pin30 = 1'b0;      // reset or cs2, we let the hw control it by itself
assign cart_tran_pin30_dir = 1'bz;
assign cart_pin30_pwroff_reset = 1'b0;  // hardware can control this
assign cart_tran_pin31 = 1'bz;      // input
assign cart_tran_pin31_dir = 1'b0;  // input

// link port is input only
assign port_tran_so = 1'bz;
assign port_tran_so_dir = 1'b0;     // SO is output only
assign port_tran_si = 1'bz;
assign port_tran_si_dir = 1'b0;     // SI is input only
assign port_tran_sck = 1'bz;
assign port_tran_sck_dir = 1'b0;    // clock direction can change
assign port_tran_sd = 1'bz;
assign port_tran_sd_dir = 1'b0;     // SD is input and not used

// tie off the rest of the pins we are not using
assign cram0_a = 'h0;
assign cram0_dq = {16{1'bZ}};
assign cram0_clk = 0;
assign cram0_adv_n = 1;
assign cram0_cre = 0;
assign cram0_ce0_n = 1;
assign cram0_ce1_n = 1;
assign cram0_oe_n = 1;
assign cram0_we_n = 1;
assign cram0_ub_n = 1;
assign cram0_lb_n = 1;

assign cram1_a = 'h0;
assign cram1_dq = {16{1'bZ}};
assign cram1_clk = 0;
assign cram1_adv_n = 1;
assign cram1_cre = 0;
assign cram1_ce0_n = 1;
assign cram1_ce1_n = 1;
assign cram1_oe_n = 1;
assign cram1_we_n = 1;
assign cram1_ub_n = 1;
assign cram1_lb_n = 1;

assign dram_a = 'h0;
assign dram_ba = 'h0;
assign dram_dq = {16{1'bZ}};
assign dram_dqm = 'h0;
assign dram_clk = 'h0;
assign dram_cke = 'h0;
assign dram_ras_n = 'h1;
assign dram_cas_n = 'h1;
assign dram_we_n = 'h1;

// assign sram_a = 'h0;
// assign sram_dq = {16{1'bZ}};
// assign sram_oe_n  = 1;
// assign sram_we_n  = 1;
// assign sram_ub_n  = 1;
// assign sram_lb_n  = 1;

assign dbg_tx = 1'bZ;
assign user1 = 1'bZ;
assign aux_scl = 1'bZ;
assign vpll_feed = 1'bZ;

// for bridge write data, we just broadcast it to all bus devices
// for bridge read data, we have to mux it
// add your own devices here
always @(*) begin
    casex(bridge_addr)
    default: begin
        bridge_rd_data <= 0;
    end
    32'h10xxxxxx: begin
        // example
        // bridge_rd_data <= example_device_data;
        bridge_rd_data <= 0;
    end
    32'hF8xxxxxx: begin
        bridge_rd_data <= cmd_bridge_rd_data;
    end
    endcase
end


//
// host/target command handler
//
    wire            reset_n;                // driven by host commands, can be used as core-wide reset
    wire    [31:0]  cmd_bridge_rd_data;
    
// bridge host commands
// synchronous to clk_74a
    wire            status_boot_done = pll_core_locked; 
    wire            status_setup_done = pll_core_locked; // rising edge triggers a target command
    wire            status_running = reset_n; // we are running as soon as reset_n goes high

    wire            dataslot_requestread;
    wire    [15:0]  dataslot_requestread_id;
    wire            dataslot_requestread_ack = 1;
    wire            dataslot_requestread_ok = 1;

    wire            dataslot_requestwrite;
    wire    [15:0]  dataslot_requestwrite_id;
    wire            dataslot_requestwrite_ack = 1;
    wire            dataslot_requestwrite_ok = 1;

    wire            dataslot_allcomplete;

    wire            savestate_supported;
    wire    [31:0]  savestate_addr;
    wire    [31:0]  savestate_size;
    wire    [31:0]  savestate_maxloadsize;

    wire            savestate_start;
    wire            savestate_start_ack;
    wire            savestate_start_busy;
    wire            savestate_start_ok;
    wire            savestate_start_err;

    wire            savestate_load;
    wire            savestate_load_ack;
    wire            savestate_load_busy;
    wire            savestate_load_ok;
    wire            savestate_load_err;
    
    wire            osnotify_inmenu;

// bridge target commands
// synchronous to clk_74a


// bridge data slot access

    wire    [9:0]   datatable_addr;
    wire            datatable_wren;
    wire    [31:0]  datatable_data;
    wire    [31:0]  datatable_q;

core_bridge_cmd icb (

    .clk                ( clk_74a ),
    .reset_n            ( reset_n ),

    .bridge_endian_little   ( bridge_endian_little ),
    .bridge_addr            ( bridge_addr ),
    .bridge_rd              ( bridge_rd ),
    .bridge_rd_data         ( cmd_bridge_rd_data ),
    .bridge_wr              ( bridge_wr ),
    .bridge_wr_data         ( bridge_wr_data ),
    
    .status_boot_done       ( status_boot_done ),
    .status_setup_done      ( status_setup_done ),
    .status_running         ( status_running ),

    .dataslot_requestread       ( dataslot_requestread ),
    .dataslot_requestread_id    ( dataslot_requestread_id ),
    .dataslot_requestread_ack   ( dataslot_requestread_ack ),
    .dataslot_requestread_ok    ( dataslot_requestread_ok ),

    .dataslot_requestwrite      ( dataslot_requestwrite ),
    .dataslot_requestwrite_id   ( dataslot_requestwrite_id ),
    .dataslot_requestwrite_ack  ( dataslot_requestwrite_ack ),
    .dataslot_requestwrite_ok   ( dataslot_requestwrite_ok ),

    .dataslot_allcomplete   ( dataslot_allcomplete ),

    .savestate_supported    ( savestate_supported ),
    .savestate_addr         ( savestate_addr ),
    .savestate_size         ( savestate_size ),
    .savestate_maxloadsize  ( savestate_maxloadsize ),

    .savestate_start        ( savestate_start ),
    .savestate_start_ack    ( savestate_start_ack ),
    .savestate_start_busy   ( savestate_start_busy ),
    .savestate_start_ok     ( savestate_start_ok ),
    .savestate_start_err    ( savestate_start_err ),

    .savestate_load         ( savestate_load ),
    .savestate_load_ack     ( savestate_load_ack ),
    .savestate_load_busy    ( savestate_load_busy ),
    .savestate_load_ok      ( savestate_load_ok ),
    .savestate_load_err     ( savestate_load_err ),

    .osnotify_inmenu        ( osnotify_inmenu ),
    
    .datatable_addr         ( datatable_addr ),
    .datatable_wren         ( datatable_wren ),
    .datatable_data         ( datatable_data ),
    .datatable_q            ( datatable_q ),
);

// Game type defines
parameter [1:0] GAME_ID_JOUST2=3'd0;
parameter [1:0] GAME_ID_INFERNO=3'd1;
parameter [1:0] GAME_ID_TURKEY_SHOOT=3'd2;
parameter [1:0] GAME_ID_MYSTIC_MARATHON=3'd3;

reg [1:0] board_variant;
reg inferno_diagonal_control;
reg inferno_auto_fire;

always @(posedge clk_74a) begin
  if(bridge_wr) begin
    casex(bridge_addr)
      32'h80000000: begin 
			board_variant   <= bridge_wr_data[1:0];  
		end
	   32'h90000000: begin 
			inferno_diagonal_control <= bridge_wr_data[0];
		end
		32'hA0000000: begin 
			inferno_auto_fire <= bridge_wr_data[0];
		end
    endcase
  end
end

///////////////////////////////////////////////
// System
///////////////////////////////////////////////

wire osnotify_inmenu_s;

synch_3 OSD_S (osnotify_inmenu, osnotify_inmenu_s, clk_sys);

///////////////////////////////////////////////
// ROM
///////////////////////////////////////////////

reg         ioctl_download = 0;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
reg   [7:0] ioctl_index = 0;

always @(posedge clk_74a) begin
    if (dataslot_requestwrite)     ioctl_download <= 1;
    else if (dataslot_allcomplete) ioctl_download <= 0;
end

data_loader #(
    .ADDRESS_MASK_UPPER_4(0),
    .ADDRESS_SIZE(25)
) rom_loader (
    .clk_74a(clk_74a),
    .clk_memory(clk_sys),

    .bridge_wr(bridge_wr),
    .bridge_endian_little(bridge_endian_little),
    .bridge_addr(bridge_addr),
    .bridge_wr_data(bridge_wr_data),

    .write_en(ioctl_wr),
    .write_addr(ioctl_addr),
    .write_data(ioctl_dout)
);

///////////////////////////////////////////////
// Video
///////////////////////////////////////////////

reg hblank_core, vblank_core;
wire hs_core, vs_core;
wire [3:0] r;
wire [3:0] g;
wire [3:0] b;
wire [3:0] intensity;

wire [7:0] ri;
wire [7:0] gi;
wire [7:0] bi;

wire [7:0] color_lut[256] = '{
    8'd19, 8'd21, 8'd23,  8'd25,  8'd26,  8'd29,  8'd32,  8'd35,  8'd38,  8'd43,  8'd49,  8'd56,  8'd65,  8'd76,  8'd96,  8'd108,
    8'd21, 8'd22, 8'd24,  8'd26,  8'd28,  8'd30,  8'd34,  8'd37,  8'd40,  8'd45,  8'd52,  8'd59,  8'd68,  8'd80,  8'd101, 8'd114,
    8'd22, 8'd24, 8'd26,  8'd28,  8'd30,  8'd33,  8'd36,  8'd39,  8'd43,  8'd48,  8'd55,  8'd63,  8'd73,  8'd86,  8'd107, 8'd121,
    8'd24, 8'd25, 8'd27,  8'd29,  8'd32,  8'd35,  8'd38,  8'd42,  8'd46,  8'd52,  8'd59,  8'd67,  8'd77,  8'd91,  8'd114, 8'd129,
    8'd25, 8'd27, 8'd29,  8'd31,  8'd34,  8'd37,  8'd40,  8'd45,  8'd48,  8'd54,  8'd62,  8'd71,  8'd81,  8'd96,  8'd121, 8'd137,
    8'd27, 8'd28, 8'd31,  8'd34,  8'd36,  8'd39,  8'd44,  8'd48,  8'd52,  8'd58,  8'd66,  8'd76,  8'd87,  8'd103, 8'd129, 8'd146,
    8'd29, 8'd31, 8'd34,  8'd36,  8'd39,  8'd43,  8'd47,  8'd52,  8'd56,  8'd63,  8'd72,  8'd82,  8'd94,  8'd111, 8'd140, 8'd158,
    8'd32, 8'd34, 8'd37,  8'd39,  8'd43,  8'd46,  8'd51,  8'd56,  8'd61,  8'd68,  8'd78,  8'd89,  8'd102, 8'd120, 8'd151, 8'd171,
    8'd32, 8'd35, 8'd38,  8'd41,  8'd44,  8'd48,  8'd53,  8'd59,  8'd64,  8'd72,  8'd83,  8'd94,  8'd109, 8'd129, 8'd161, 8'd182,
    8'd36, 8'd38, 8'd42,  8'd45,  8'd48,  8'd53,  8'd59,  8'd65,  8'd70,  8'd79,  8'd90,  8'd104, 8'd119, 8'd141, 8'd177, 8'd201,
    8'd40, 8'd43, 8'd46,  8'd50,  8'd54,  8'd59,  8'd65,  8'd72,  8'd79,  8'd88,  8'd101, 8'd115, 8'd133, 8'd157, 8'd198, 8'd224,
    8'd45, 8'd48, 8'd52,  8'd57,  8'd61,  8'd66,  8'd74,  8'd81,  8'd88,  8'd98,  8'd113, 8'd129, 8'd149, 8'd176, 8'd221, 8'd249,
    8'd50, 8'd54, 8'd58,  8'd64,  8'd68,  8'd75,  8'd83,  8'd91,  8'd99,  8'd111, 8'd128, 8'd146, 8'd169, 8'd200, 8'd249, 8'd253,
    8'd58, 8'd63, 8'd68,  8'd74,  8'd79,  8'd87,  8'd96,  8'd106, 8'd116, 8'd129, 8'd148, 8'd169, 8'd195, 8'd231, 8'd253, 8'd254,
    8'd71, 8'd76, 8'd83,  8'd89,  8'd96,  8'd105, 8'd116, 8'd128, 8'd139, 8'd156, 8'd179, 8'd205, 8'd236, 8'd252, 8'd254, 8'd254,
    8'd91, 8'd97, 8'd105, 8'd114, 8'd123, 8'd133, 8'd147, 8'd161, 8'd176, 8'd196, 8'd223, 8'd249, 8'd252, 8'd254, 8'd254, 8'd255
};

always @(posedge clk_sys) begin : colorPalette
    ri = ~| intensity ? 8'd0 : color_lut[{r, intensity}];
    gi = ~| intensity ? 8'd0 : color_lut[{g, intensity}];
    bi = ~| intensity ? 8'd0 : color_lut[{b, intensity}];
end

reg video_de_reg;
reg video_hs_reg;
reg video_vs_reg;
reg [23:0] video_rgb_reg;

reg hs_prev;
reg vs_prev;

assign video_rgb_clock = clk_core_6;
assign video_rgb_clock_90 = clk_core_6_90deg;

assign video_de = video_de_reg;
assign video_hs = video_hs_reg;
assign video_vs = video_vs_reg;
assign video_rgb = video_rgb_reg;
assign video_skip = 0;

always @(posedge clk_core_6) begin
    video_de_reg <= 0;

    // Landscape by default, portrait where required.
    video_rgb_reg <= 24'd0;
    if (board_variant == GAME_ID_JOUST2) begin
        video_rgb_reg <= {8'h0, 3'b001, 13'h0};
	end
    else if (board_variant == GAME_ID_TURKEY_SHOOT) begin
        video_rgb_reg <= {8'h0, 3'b010, 13'h0};
    end

    if (~(vblank_core || hblank_core)) begin
        video_de_reg <= 1;
        video_rgb_reg[23:16] <= ri;
        video_rgb_reg[15:8] <= gi;
        video_rgb_reg[7:0] <= bi;
	end    
	
    video_hs_reg <= ~hs_prev && hs_core;
    video_vs_reg <= ~vs_prev && vs_core;
    hs_prev <= hs_core;
    vs_prev <= vs_core;
end


///////////////////////////////////////////////
// Audio
///////////////////////////////////////////////

wire [13:0] audio_l;
wire [13:0] audio_r;
wire [15:0] speech;

reg signed [15:0] signed_audio_l;
reg signed [15:0] signed_audio_r;
reg signed [15:0] signed_speech;

always @(clk_sys) begin
  signed_audio_l <= $signed({2'b0,audio_l}) - 16'sd8192;  
  signed_audio_r <= $signed({2'b0,audio_r}) - 16'sd8192;  
  signed_speech  <= $signed({3'b0,speech[15:3]}) - 16'sd4096;
end

// Apply 3500Hz 2nd-order butterworth low-pass filter to the speech channel
wire signed [15:0] speech_lpf;
iir_2nd_order #(
    .COEFF_WIDTH(22),
    .COEFF_SCALE(15),
    .DATA_WIDTH(16),
    .COUNT_BITS(12)
)  speech_lpf_iir (
	.clk(clk_sys), // 12MHz
	.reset(~reset_n),
	.div(12'd256), // 12MHz / 256 ~= 48kHz.
	.A2(-22'sd54744),
	.A3(22'sd23517),
	.B1(22'sd385),
	.B2(22'sd771),
	.B3(22'sd385),
    .in(signed_speech),
	.out(speech_lpf)
);

sound_i2s #(
    .CHANNEL_WIDTH(15),
    .SIGNED_INPUT(1)
) sound_i2s (
    .clk_74a(clk_74a),
    .clk_audio(clk_sys),
    
    .audio_l( (board_variant == GAME_ID_JOUST2) ? signed_audio_l + speech_lpf : signed_audio_l / 4),
    .audio_r( (board_variant == GAME_ID_JOUST2) ? signed_audio_r + speech_lpf : signed_audio_r / 4),

    .audio_mclk(audio_mclk),
    .audio_lrck(audio_lrck),
    .audio_dac(audio_dac)
);

///////////////////////////////////////////////
// Control
///////////////////////////////////////////////

wire [15:0] joy;

synch_3 #(
    .WIDTH(16)
) cont1_key_s (
    cont1_key,
    joy,
    clk_sys
);

wire [15:0] joy2;

synch_3 #(
    .WIDTH(16)
) cont2_key_s (
    cont2_key,
    joy2,
    clk_sys
);

wire m_up1     = joy[0];
wire m_down1   = joy[1];
wire m_left1   = joy[2];
wire m_right1  = joy[3];
wire m_a1   = joy[4];
wire m_b1   = joy[5];
wire m_x1   = joy[6];
wire m_y1   = joy[7];
wire m_l1   = joy[8];
wire m_r1   = joy[9];

wire m_advance = m_up1 & m_coin1;
wire m_auto_up = m_l1 & m_coin1;
wire m_reset_score = m_r1 & m_coin1;

wire m_start1 =  joy[15];
wire m_coin1   =  joy[14];

wire m_up2     = joy2[0];
wire m_down2   = joy2[1];
wire m_left2   = joy2[2];
wire m_right2  = joy2[3];
wire m_a2   = joy2[4];
wire m_b2   = joy2[5];
wire m_x2   = joy2[6];
wire m_y2   = joy2[7];
wire m_l2   = joy[8];
wire m_r2   = joy[9];

wire m_start2 =  joy2[15];
wire m_coin2   =  joy2[14];

reg m_btn_start1;
reg m_btn_start2;

wire m_btn_coin;
assign m_btn_coin = (m_coin1 | m_coin2);

// analog joysticks -- used by inferno to support better diagonals, treated as digital signals.
reg analog_stick_detected1;
reg analog_stick_detected2;

reg m_left_analog_up1;
reg m_left_analog_down1;
reg m_left_analog_left1;
reg m_left_analog_right1;

reg m_right_analog_up1;
reg m_right_analog_down1;
reg m_right_analog_left1;
reg m_right_analog_right1;

reg m_left_analog_up2;
reg m_left_analog_down2;
reg m_left_analog_left2;
reg m_left_analog_right2;

reg m_right_analog_up2;
reg m_right_analog_down2;
reg m_right_analog_left2;
reg m_right_analog_right2;

always @(*) begin
	analog_stick_detected1 <= cont1_joy[15:0] != 0;
    analog_stick_detected2 <= cont2_joy[15:0] != 0;

    // Analog joystick 1
    m_left_analog_right1 <= analog_stick_detected1 ? (cont1_joy[7:0]   > 192)  : 1'b0; //r
    m_left_analog_left1  <= analog_stick_detected1 ? (cont1_joy[7:0]   < 64)   : 1'b0; //l
    m_left_analog_down1  <= analog_stick_detected1 ? (cont1_joy[15:8]  > 192)  : 1'b0; //d
    m_left_analog_up1    <= analog_stick_detected1 ? (cont1_joy[15:8]  < 64)   : 1'b0; //u            

    m_right_analog_right1 <= analog_stick_detected1 ? (cont1_joy[23:16] > 192)  : 1'b0; //r
    m_right_analog_left1  <= analog_stick_detected1 ? (cont1_joy[23:16] < 64)   : 1'b0; //l
    m_right_analog_down1  <= analog_stick_detected1 ? (cont1_joy[31:24] > 192)  : 1'b0; //d
    m_right_analog_up1    <= analog_stick_detected1 ? (cont1_joy[31:24] < 64)   : 1'b0; //u

    // Analog joystick 2    
    m_left_analog_right2 <= analog_stick_detected2 ? (cont2_joy[7:0]   > 192)  : 1'b0; //r
    m_left_analog_left2  <= analog_stick_detected2 ? (cont2_joy[7:0]   < 64)   : 1'b0; //l
    m_left_analog_down2  <= analog_stick_detected2 ? (cont2_joy[15:8]  > 192)  : 1'b0; //d
    m_left_analog_up2    <= analog_stick_detected2 ? (cont2_joy[15:8]  < 64)   : 1'b0; //u

    m_right_analog_right2 <= analog_stick_detected2 ? (cont2_joy[23:16] > 192)  : 1'b0; //r
    m_right_analog_left2  <= analog_stick_detected2 ? (cont2_joy[23:16] < 64)   : 1'b0; //l
    m_right_analog_down2  <= analog_stick_detected2 ? (cont2_joy[31:24] > 192)  : 1'b0; //d
    m_right_analog_up2    <= analog_stick_detected2 ? (cont2_joy[31:24] < 64)   : 1'b0; //u
end

// -- Joust2 specific control registers
wire m_joust2_btn_left_1;
wire m_joust2_btn_right_1;
wire m_joust2_btn_trigger_1;

wire m_joust2_btn_left_2;
wire m_joust2_btn_right_2;
wire m_joust2_btn_trigger_2;

// -- Inferno specific controls
wire m_inferno_trigger_1;
wire m_inferno_trigger_2;

wire [3:0] m_inferno_run1;
wire [3:0] m_inferno_aim1;
wire [3:0] m_inferno_run2;
wire [3:0] m_inferno_aim2;

wire [3:0] m_inferno_analog_run1;
wire [3:0] m_inferno_analog_aim1;
wire [3:0] m_inferno_analog_run2;
wire [3:0] m_inferno_analog_aim2;

wire [3:0] m_inferno_btn_run1;
wire [3:0] m_inferno_btn_aim1; 
wire [3:0] m_inferno_btn_run2;
wire [3:0] m_inferno_btn_aim2;

wire m_inferno_fire_on_aim;
wire m_inferno_diagonal_controls;

assign m_inferno_fire_on_aim = inferno_auto_fire;
assign m_inferno_diagonal_controls = inferno_diagonal_control;

// -- Turkey-shoot control registers
wire [5:0] m_tshoot_gun_h;
wire [5:0] m_tshoot_gun_v;

wire gun_update_r;
wire left_r, right_r, up_r, down_r;
reg [4:0] div_h, div_v;
reg [5:0] gun_h, gun_v;
reg gun_sub_sample;
wire m_cnt_4ms;

wire m_tshoot_gobble;
wire m_tshoot_grenade;
wire m_tshoot_trigger;
wire m_tshoot_fast_move;

// -- Mystic Marathon control registers

wire m_mysticm_up;
wire m_mysticm_down;
wire m_mysticm_left;
wire m_mysticm_right;
wire m_mysticm_trigger;

always @(*) begin
    m_btn_start1 <= m_start1;
    m_btn_start2 <= m_start2;

	if (board_variant == GAME_ID_JOUST2) begin
        m_btn_start1 <= m_start1 | m_b1;               
        m_btn_start2 <= m_start2 | m_b2;               
    end
end

// -- Joust2 assignments

assign m_joust2_btn_trigger_1 = m_a1;                
assign m_joust2_btn_left_1 = m_left1;
assign m_joust2_btn_right_1 = m_right1;

assign m_joust2_btn_trigger_2 = m_a2;                
assign m_joust2_btn_left_2 = m_left2;
assign m_joust2_btn_right_2 = m_right2;

// -- Inferno assignments
assign m_inferno_trigger_1 = m_inferno_fire_on_aim ? (m_r1 || (m_inferno_btn_aim1 != 4'b0)) : m_r1;
assign m_inferno_trigger_2 = m_inferno_fire_on_aim ? (m_r2 || (m_inferno_btn_aim2 != 4'b0)) : m_r2;

// Digital controls -- either diagonal or 4-way.
assign m_inferno_run1 = m_inferno_diagonal_controls ? { (m_up1 && m_right1), (m_down1 && m_left1), (m_up1 && m_left1), (m_down1 && m_right1) } : { m_up1, m_down1, m_left1, m_right1 };
assign m_inferno_run2 = m_inferno_diagonal_controls ? { (m_up2 && m_right2), (m_down2 && m_left2), (m_up2 && m_left2), (m_down2 && m_right2) } : { m_up2, m_down2, m_left2, m_right2 };

assign m_inferno_aim1 = m_inferno_diagonal_controls ? { (m_x1 && m_a1), (m_b1 && m_y1), (m_y1 && m_x1), (m_b1 && m_a1) } : {m_x1, m_b1, m_y1, m_a1};
assign m_inferno_aim2 = m_inferno_diagonal_controls ? { (m_x2 && m_a2), (m_b2 && m_y2), (m_y2 && m_x2), (m_b2 && m_a2) } : {m_x2, m_b2, m_y2, m_a2};

// Analog controls -- strict diagonal.
assign m_inferno_analog_run1 = analog_stick_detected1 ? { (m_left_analog_up1 && m_left_analog_right1), 
                                                          (m_left_analog_down1 && m_left_analog_left1), 
                                                          (m_left_analog_up1 && m_left_analog_left1), 
                                                          (m_left_analog_down1 && m_left_analog_right1) } : 4'b0;

assign m_inferno_analog_run2 = analog_stick_detected2 ? { (m_left_analog_up2 && m_left_analog_right2), 
                                                          (m_left_analog_down2 && m_left_analog_left2), 
                                                          (m_left_analog_up2 && m_left_analog_left2), 
                                                          (m_left_analog_down2 && m_left_analog_right2) } : 4'b0;
                                                          
assign m_inferno_analog_aim1 = analog_stick_detected1 ? { (m_right_analog_up1 && m_right_analog_right1), 
                                                          (m_right_analog_down1 && m_right_analog_left1), 
                                                          (m_right_analog_up1 && m_right_analog_left1), 
                                                          (m_right_analog_down1 && m_right_analog_right1) } : 4'b0;

assign m_inferno_analog_aim2 = analog_stick_detected2 ? { (m_right_analog_up2 && m_right_analog_right2), 
                                                          (m_right_analog_down2 && m_right_analog_left2), 
                                                          (m_right_analog_up2 && m_right_analog_left2), 
                                                          (m_right_analog_down2 && m_right_analog_right2) } : 4'b0;

// -- reorder outputs, mux analog/digital contols
assign m_inferno_btn_run1 = {m_inferno_run1[2] | m_inferno_analog_run1[2],
                             m_inferno_run1[0] | m_inferno_analog_run1[0], 
                             m_inferno_run1[1] | m_inferno_analog_run1[1],
                             m_inferno_run1[3] | m_inferno_analog_run1[3]};

assign m_inferno_btn_aim1 = {m_inferno_aim1[2] | m_inferno_analog_aim1[2],
                             m_inferno_aim1[0] | m_inferno_analog_aim1[0], 
                             m_inferno_aim1[1] | m_inferno_analog_aim1[1],
                             m_inferno_aim1[3] | m_inferno_analog_aim1[3]};
                             
assign m_inferno_btn_run2 = {m_inferno_run2[2] | m_inferno_analog_run2[2],
                             m_inferno_run2[0] | m_inferno_analog_run2[0], 
                             m_inferno_run2[1] | m_inferno_analog_run2[1],
                             m_inferno_run2[3] | m_inferno_analog_run2[3]};

assign m_inferno_btn_aim2 = {m_inferno_aim2[2] | m_inferno_analog_aim2[2],
                             m_inferno_aim2[0] | m_inferno_analog_aim2[0], 
                             m_inferno_aim2[1] | m_inferno_analog_aim2[1],
                             m_inferno_aim2[3] | m_inferno_analog_aim2[3]};
                             

// -- Mystic Marathon assignments

assign m_mysticm_up = m_up1;
assign m_mysticm_down = m_down1;
assign m_mysticm_left = m_left1;
assign m_mysticm_right = m_right1;
assign m_mysticm_trigger = m_a1;

// -- Turkey Shoot assignments.
assign m_tshoot_gun_h = gun_h;
assign m_tshoot_gun_v = gun_v;
assign m_tshoot_gobble = m_b1;
assign m_tshoot_grenade = m_x1;
assign m_tshoot_trigger = m_a1;
assign m_tshoot_fast_move = m_r1;

always @(posedge clk_sys) begin : gunHV
	gun_update_r <= m_cnt_4ms;
	
	if ((gun_update_r == 1'b0) && (m_cnt_4ms == 1'b1)) begin
		gun_sub_sample <= ~gun_sub_sample;
	end
	
	if ((gun_update_r == 1'b0) && (m_cnt_4ms == 1'b1) && ((gun_sub_sample == 1'b1) || (m_tshoot_fast_move))) begin
		left_r  <= m_left1;
		right_r <= m_right1;
		up_r    <= m_up1;
		down_r  <= m_down1;

		if ((((m_left1 == 1'b1) && (left_r == 1'b1)) || ((m_right1 == 1'b1) && (right_r == 1'b1))) && (div_h < 5'd3)) begin
			div_h <= div_h + 5'b1;
		end else begin
			div_h <= 5'b0;
		end
		if ((m_left1 == 1'b1) && (div_h == 5'd1) && (gun_h > 6'd0)) begin
			gun_h <= gun_h - 6'b1;
		end
		if ((m_right1 == 1'b1) && (div_h == 5'd1) && (gun_h < 6'd63)) begin
			gun_h <= gun_h + 6'b1;
		end

		if ((((m_up1 == 1'b1) && (up_r == 1'b1)) || ((m_down1 == 1'b1) && (down_r == 1'b1))) && (div_v < 5'd3)) begin
			div_v <= div_v + 5'b1;
		end else begin
			div_v <= 5'b0;
		end
		if ((m_up1 == 1'b1) && (div_v == 5'd1) && (gun_v > 6'd0)) begin
			gun_v <= gun_v - 6'b1;
		end
		if ((m_down1 == 1'b1) && (div_v == 5'd1) && (gun_v < 6'd63)) begin
			gun_v <= gun_v + 6'b1;
		end
	end
end

williams2 williams2
(
	.clock_12(clk_sys),
	.reset(~reset_n),

	.dn_addr(ioctl_addr[18:0]),
	.dn_data(ioctl_dout),
	.dn_wr(ioctl_wr),

    .board_variant(board_variant),

	.video_r(r),
	.video_g(g),
	.video_b(b),
	.video_i(intensity),
	.video_hblank(hblank_core),
	.video_vblank(vblank_core),
	.video_hs(hs_core),
	.video_vs(vs_core),

	.audio_l(audio_l),
	.audio_r(audio_r),
    .speech_o(speech),

	.btn_auto_up(m_auto_up),
	.btn_advance(m_advance),
	.btn_high_score_reset(m_reset_score),
	.btn_coin(m_btn_coin),

    // -- Joust2-specific inputs
	.btn_start_1(m_btn_start1),
	.btn_start_2(m_btn_start2),

	.joust2_btn_left_1(m_joust2_btn_left_1),
	.joust2_btn_right_1(m_joust2_btn_right_1),
	.joust2_btn_trigger1_1(m_joust2_btn_trigger_1),

	.joust2_btn_left_2(m_joust2_btn_left_2),
	.joust2_btn_right_2(m_joust2_btn_right_2),
	.joust2_btn_trigger1_2(m_joust2_btn_trigger_2),
    
    // -- Inferno inputs
   	.inferno_btn_trigger_1(m_inferno_trigger_1), 
	.inferno_btn_trigger_2(m_inferno_trigger_2), 
	.inferno_btn_run_1(m_inferno_btn_run1),
	.inferno_btn_run_2(m_inferno_btn_run2),
	.inferno_btn_aim_1(m_inferno_btn_aim1),
	.inferno_btn_aim_2(m_inferno_btn_aim2),

    // -- Turkey Shoot inputs
	.tshoot_btn_gobble(m_tshoot_gobble),
	.tshoot_btn_grenade(m_tshoot_grenade),
	.tshoot_btn_trigger(m_tshoot_trigger),
 
	.tshoot_gun_h(m_tshoot_gun_h),
	.tshoot_gun_v(m_tshoot_gun_v),
 
    // -- Mystic Marathon inputs
    .mysticm_btn_up(m_mysticm_up), 
    .mysticm_btn_down(m_mysticm_down), 
    .mysticm_btn_left(m_mysticm_left), 
    .mysticm_btn_right(m_mysticm_right),
    .mysticm_btn_trigger(m_mysticm_trigger), 

    .cnt_4ms_o(m_cnt_4ms),    
	
    .sram_a(sram_a),
    .sram_dq(sram_dq),
    .sram_oe_n(sram_oe_n),
    .sram_we_n(sram_we_n),
    .sram_ub_n(sram_ub_n),
    .sram_lb_n(sram_lb_n),
);

///////////////////////////////////////////////
// Clocks
///////////////////////////////////////////////

wire    clk_core_6;
wire    clk_core_6_90deg;
wire    clk_sys;  // 12MHz

wire    pll_core_locked;
    
mf_pllbase mp1 (
    .refclk         ( clk_74a ),
    .rst            ( 0 ),

    .outclk_2       ( clk_core_6_90deg ),
	.outclk_1       ( clk_core_6 ),
    .outclk_0       ( clk_sys ),

    .locked         ( pll_core_locked )
);

endmodule
