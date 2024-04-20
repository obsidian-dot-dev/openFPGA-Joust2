-- -----------------------------------------------------------------------
--
-- Syntiac's generic VHDL support",x"iles.
--
-- -----------------------------------------------------------------------
-- Copyright 2005-2008 by Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
--
-- Modified April 2016 by Dar (darfpga@aol.fr) 
-- http://darfpga.blogspot.fr
--   Remove address register when writing
--
-- Modifies March 2022 by Dar 
--   Add init data with tshoot cmos value
-- -----------------------------------------------------------------------
--
-- gen_rwram.vhd init with tshoot cmos value
--
-- -----------------------------------------------------------------------
--
-- generic ram.
--
-- -----------------------------------------------------------------------
-- mystic_marathon cmos settings --
--
--@00-00: Extra life ?
--@02-03: Men for for 1 credit ?

--@04-05: High score to date       - BCD 00 to 01 - No / Yes
--@06-07: Pricing selection        - BCD 00 to 09 - Custom / free play
--@08-09: Left coin slot units     - BCD 00 to 99 
--@0A-0B: Center coin slot units   - BCD 00 to 99 
--@0C-0D: Right coin slot units    - BCD 00 to 99 
--@0E-0F: Unit for credit          - BCD 01 to 99 
--@10-11: Unit for bonus credit    - BCD 00 to 99 
--@12-13: Min unit                 - BCD 00 to 99 
--@14-15: Difficulty               - BCD 00 to 09 
--@16-17: Letters for High score   - BCD 03 to 20 
--@18-19: Restore factory settings - BCD 00 to 01 - No / Yes
--@1A-1B: Clear bookkeeping        - BCD 00 to 01 - No / Yes
--@1C-1D: High score reset         - BCD 00 to 01 - No / Yes
--@1E-1F: Auto cycle               - BCD 00 to 01 - No / Yes
--@20-21: Set attract mode message - BCD 00 to 01 - No / Yes
--@22-23: Set high score name      - BCD 00 to 01 - No / Yes
--@24-55: Message line 1           - LUT 00 -> '0' / 0B -> 'A' ...
--@56-87: Message line 2           - LUT 00 -> '0' / 0B -> 'A' ...
--@88-89: Position line 1          - HEX x08 to x44
--@8A-8B: Position line 2          - HEX x08 to x44

-- -----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
-- -----------------------------------------------------------------------
entity mystic_marathon_cmos_ram is
	generic (
		dWidth : integer := 8;  -- must be  4",x"or tshoot_cmos_ram
		aWidth : integer := 10  -- must be 10",x"or tshoot_cmos_ram
	);
	port (
		clk : in std_logic;
		we : in std_logic;
		addr : in std_logic_vector((aWidth-1) downto 0);
		d : in std_logic_vector((dWidth-1) downto 0);
		q : out std_logic_vector((dWidth-1) downto 0)
	);
end entity;
-- -----------------------------------------------------------------------
-- mystic_marathon cmos data
-- (ram is 128x4 => only 4 bits/address, that is only 1 hex digit/address)

architecture rtl of mystic_marathon_cmos_ram is
subtype addressRange is integer range 0 to ((2**aWidth)-1);
type ramDef is array(addressRange) of std_logic_vector((dWidth-1) downto 0);
	
signal ram: ramDef := (		
 x"2",x"0",x"0",x"5",x"0",x"1",x"0",x"3",x"0",x"1",x"0",x"4",x"0",x"1",x"0",x"1",
 x"0",x"0",x"0",x"0",x"0",x"3",x"0",x"3",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
 x"0",x"0",x"0",x"0",x"0",x"A",x"0",x"A",x"0",x"A",x"0",x"A",x"0",x"A",x"0",x"A",
 x"0",x"A",x"1",x"A",x"1",x"C",x"0",x"F",x"1",x"D",x"0",x"F",x"1",x"8",x"1",x"E",
 x"0",x"F",x"0",x"E",x"0",x"A",x"0",x"C",x"2",x"3",x"0",x"A",x"0",x"A",x"0",x"A",
 x"0",x"A",x"0",x"A",x"0",x"A",x"1",x"E",x"1",x"2",x"0",x"F",x"0",x"A",x"2",x"1",
 x"1",x"3",x"2",x"4",x"0",x"B",x"1",x"C",x"0",x"E",x"1",x"D",x"0",x"A",x"1",x"9",
 x"1",x"0",x"0",x"A",x"2",x"1",x"1",x"3",x"1",x"6",x"1",x"6",x"1",x"3",x"0",x"B",
 x"1",x"7",x"1",x"D",x"0",x"A",x"0",x"A",x"2",x"5",x"2",x"9",x"4",x"F",x"3",x"8",
 x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
 x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
 x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
 x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
 x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
 x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
 x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
 x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
 x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
 x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
 x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"1",x"E",
 x"1",x"2",x"0",x"F",x"0",x"A",x"2",x"1",x"1",x"3",x"1",x"6",x"1",x"6",x"1",x"3",
 x"0",x"B",x"1",x"7",x"1",x"D",x"0",x"A",x"2",x"1",x"1",x"3",x"2",x"4",x"0",x"B",
 x"1",x"C",x"0",x"E",x"1",x"D",x"2",x"1",x"1",x"3",x"2",x"4",x"A",x"0",x"1",x"0",
 x"9",x"1",x"0",x"2",x"1",x"5",x"2",x"0",x"0",x"E",x"2",x"0",x"0",x"4",x"8",x"4",
 x"9",x"3",x"1",x"4",x"1",x"C",x"1",x"8",x"B",x"0",x"0",x"4",x"7",x"1",x"1",x"3",
 x"0",x"E",x"1",x"C",x"2",x"3",x"7",x"0",x"0",x"4",x"6",x"1",x"7",x"5",x"1",x"A",
 x"1",x"4",x"0",x"A",x"9",x"0",x"0",x"4",x"5",x"2",x"2",x"2",x"1",x"4",x"1",x"3",
 x"1",x"6",x"B",x"0",x"0",x"4",x"4",x"2",x"1",x"0",x"1",x"C",x"1",x"4",x"0",x"E",
 x"1",x"0",x"0",x"4",x"3",x"2",x"1",x"7",x"0",x"C",x"0",x"F",x"1",x"8",x"5",x"0",
 x"0",x"4",x"2",x"9",x"9",x"9",x"0",x"E",x"1",x"9",x"0",x"D",x"C",x"0",x"0",x"4",
 x"1",x"0",x"1",x"1",x"1",x"4",x"0",x"B",x"1",x"8",x"7",x"0",x"0",x"4",x"0",x"5",
 x"2",x"3",x"1",x"5",x"0",x"B",x"1",x"1",x"1",x"0",x"0",x"3",x"9",x"9",x"0",x"9",
 x"1",x"5",x"0",x"F",x"1",x"8",x"B",x"0",x"0",x"3",x"7",x"2",x"1",x"0",x"1",x"1",
 x"1",x"6",x"1",x"8",x"6",x"0",x"0",x"3",x"6",x"1",x"9",x"1",x"1",x"5",x"0",x"B",
 x"2",x"3",x"2",x"0",x"0",x"3",x"8",x"0",x"0",x"1",x"1",x"7",x"1",x"C",x"0",x"A",
 x"9",x"0",x"0",x"3",x"5",x"1",x"0",x"1",x"1",x"5",x"2",x"0",x"1",x"C",x"0",x"0",
 x"0",x"3",x"4",x"2",x"1",x"1",x"1",x"8",x"0",x"F",x"0",x"E",x"E",x"0",x"0",x"3",
 x"3",x"5",x"6",x"7",x"1",x"1",x"1",x"3",x"1",x"6",x"B",x"0",x"0",x"3",x"1",x"9",
 x"0",x"1",x"0",x"A",x"1",x"2",x"0",x"D",x"0",x"0",x"0",x"3",x"2",x"8",x"9",x"0",
 x"2",x"0",x"2",x"3",x"1",x"E",x"6",x"0",x"0",x"3",x"0",x"1",x"5",x"7",x"1",x"6",
 x"1",x"F",x"1",x"8",x"0",x"0",x"0",x"2",x"9",x"2",x"3",x"0",x"1",x"4",x"0",x"A",
 x"0",x"D",x"B",x"0",x"0",x"2",x"8",x"7",x"7",x"7",x"1",x"7",x"1",x"3",x"0",x"B",
 x"8",x"0",x"0",x"2",x"7",x"9",x"8",x"7",x"2",x"1",x"0",x"B",x"1",x"6",x"4",x"0",
 x"0",x"2",x"6",x"9",x"5",x"9",x"0",x"B",x"1",x"6",x"1",x"E",x"0",x"0",x"0",x"2",
 x"5",x"8",x"8",x"8",x"1",x"8",x"0",x"A",x"1",x"0",x"C",x"0",x"0",x"2",x"4",x"6",
 x"7",x"5",x"1",x"5",x"2",x"0",x"0",x"E",x"F",x"0",x"0",x"2",x"3",x"3",x"1",x"0",
 x"1",x"4",x"1",x"C",x"1",x"8",x"0",x"0",x"0",x"2",x"2",x"9",x"1",x"7",x"1",x"A",
 x"0",x"B",x"1",x"7",x"4",x"0",x"0",x"1",x"7",x"6",x"3",x"5",x"1",x"4",x"1",x"3",
 x"1",x"6",x"4",x"0",x"0",x"1",x"6",x"5",x"3",x"5",x"1",x"5",x"0",x"B",x"1",x"1",
 x"3",x"0",x"0",x"2",x"2",x"5",x"5",x"2",x"1",x"4",x"0",x"B",x"1",x"8",x"4",x"0",
 x"0",x"2",x"0",x"5",x"2",x"2",x"0",x"E",x"0",x"B",x"1",x"C",x"6",x"0",x"0",x"1",
 x"5",x"5",x"0",x"5",x"1",x"C",x"2",x"1",x"0",x"A",x"8",x"0",x"0",x"1",x"4",x"3",
 x"1",x"5",x"1",x"A",x"0",x"A",x"1",x"9",x"C",x"0",x"0",x"0",x"8",x"3",x"1",x"1",
 x"0",x"E",x"1",x"4",x"0",x"C",x"D",x"0",x"0",x"1",x"3",x"1",x"0",x"9",x"0",x"D",
 x"0",x"A",x"0",x"C",x"7",x"0",x"0",x"1",x"2",x"0",x"1",x"0",x"0",x"E",x"1",x"3",
 x"1",x"8",x"E",x"0",x"0",x"1",x"1",x"7",x"5",x"5",x"1",x"4",x"1",x"1",x"0",x"A",
 x"9",x"0",x"0",x"1",x"0",x"5",x"0",x"2",x"1",x"7",x"0",x"B",x"2",x"2",x"9",x"0",
 x"0",x"0",x"9",x"4",x"0",x"5",x"0",x"C",x"1",x"F",x"1",x"E",x"3",x"0",x"0",x"0",
 x"7",x"0",x"0",x"1",x"1",x"5",x"2",x"0",x"0",x"E",x"0",x"0",x"0",x"2",x"3",x"3",
 x"1",x"0",x"1",x"4",x"1",x"C",x"1",x"8",x"0",x"0",x"0",x"2",x"2",x"9",x"1",x"7",
 x"1",x"A",x"0",x"B",x"1",x"7",x"0",x"0",x"0",x"1",x"7",x"6",x"3",x"5",x"1",x"4",
 x"1",x"3",x"1",x"6",x"0",x"0",x"0",x"1",x"6",x"5",x"3",x"5",x"1",x"5",x"0",x"B",
 x"1",x"1",x"0",x"0",x"0",x"2",x"2",x"5",x"5",x"2",x"1",x"4",x"0",x"B",x"1",x"8",
 x"0",x"0",x"0",x"2",x"0",x"5",x"2",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0");

signal rAddrReg : std_logic_vector((aWidth-1) downto 0);
signal qReg : std_logic_vector((dWidth-1) downto 0);

begin
-- -----------------------------------------------------------------------
-- Signals to entity interface
-- -----------------------------------------------------------------------
--	q <= qReg;
-- -----------------------------------------------------------------------
-- Memory write
-- -----------------------------------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
			if we = '1' then
				ram(to_integer(unsigned(addr))) <= d;
			end if;
		end if;
	end process;
-- -----------------------------------------------------------------------
-- Memory read
-- -----------------------------------------------------------------------
process(clk)
	begin
		if rising_edge(clk) then
--			qReg <= ram(to_integer(unsigned(rAddrReg)));
--			rAddrReg <= addr;
--			qReg <= ram(to_integer(unsigned(addr)));
			q <= ram(to_integer(unsigned(addr)));
		end if;
	end process;
--q <= ram(to_integer(unsigned(addr)));
end architecture;

