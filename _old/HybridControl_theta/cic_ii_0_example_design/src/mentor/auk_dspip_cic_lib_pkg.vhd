-- (C) 2001-2020 Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions and other 
-- software and tools, and its AMPP partner logic functions, and any output 
-- files from any of the foregoing (including device programming or simulation 
-- files), and any associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License Subscription 
-- Agreement, Intel FPGA IP License Agreement, or other applicable 
-- license agreement, including, without limitation, that your use is for the 
-- sole purpose of programming logic devices manufactured by Intel and sold by 
-- Intel or its authorized distributors.  Please refer to the applicable 
-- agreement for further details.


--This file is auto-generated by compile_cic_lib.pl 
--Date:Wed Nov 22 11:02:04 GST 2006

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.auk_dspip_math_pkg.all;

package auk_dspip_cic_lib_pkg is 
--Component names: 
--auk_dspip_differentiator
--auk_dspip_downsample
--auk_dspip_integrator
--auk_dspip_upsample
--auk_dspip_variable_downsample
component auk_dspip_channel_buffer is
	generic 
	(
		DATA_WIDTH : natural := 8;
		ADDR_WIDTH : natural := 6
	);
	port 
	(
		clk			: in std_logic;
		data		: in std_logic_vector((DATA_WIDTH-1) downto 0);
		clr   		: in std_logic;
		wrreq		: in std_logic := '1';
		rdreq		: in std_logic := '1';
		q			: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);
end component auk_dspip_channel_buffer;

component auk_dspip_differentiator is
  generic
    (
      WIDTH_g      : natural := 8;      -- data width
      DEPTH_g      : natural := 1;      -- the number of clock cycles the input
                                        -- will be delayed
      USE_MEMORY_g : boolean := false;  -- map the registers to memory
      LPM_HINT_g   : string  := "AUTO"  -- The memory type that the registers
                                        -- will be mapped onto. Supported
                                        -- types "AUTO", "M512", "M4K"
      );
  port
    (
      clk   : in  std_logic;
      reset : in  std_logic := '0';
      ena   : in  std_logic := '1';
      din   : in  std_logic_vector (WIDTH_g-1 downto 0);
      dout  : out std_logic_vector (WIDTH_g-1 downto 0)
      );
end component auk_dspip_differentiator;

component auk_dspip_downsample is
  generic (
    CHANNEL_SIZE_g  : natural range 1 to integer'high := 1;  -- number of channels
    WIDTH_g         : natural                         := 8;  -- data width
    SAMPLE_FACTOR_g : natural                         := 4  -- decimation factor
    );
  port(
    clk        : in  std_logic;
    ena        : in  std_logic := '1';
    reset      : in  std_logic := '0';
    din        : in  std_logic_vector(WIDTH_g-1 downto 0);
    dout       : out std_logic_vector(WIDTH_g-1 downto 0);
    dout_valid : out std_logic          -- indicate if the output is valid
    );  

end component auk_dspip_downsample;

component auk_dspip_integrator is
  generic
    (
      I_PIPE_LINE_NUMBER: natural := 2;
	  WIDTH_g      : natural := 8;      -- data width                            
      DEPTH_g      : natural := 1;      -- the number of clock cycles the input  
                                        -- will be delayed                       
      USE_MEMORY_g : boolean := false;  -- map the registers to memory           
      LPM_HINT_g   : string  := "AUTO"  -- The memory type that the registers    
      );                                -- will be mapped onto. Supported        
                                        -- types "AUTO", "M512", "M4K"           
  port
    (
      clk   : in  std_logic;
      reset : in  std_logic := '0';
      ena   : in  std_logic := '1';
      din   : in  std_logic_vector (WIDTH_g-1 downto 0);
      dout  : out std_logic_vector (WIDTH_g-1 downto 0)
      );
end component auk_dspip_integrator;

component auk_dspip_upsample is
  generic (
    WIDTH_g : natural := 8              -- data width
    );
  port(
    din       : in  std_logic_vector(WIDTH_g-1 downto 0);
    clk       : in  std_logic;
    ena       : in  std_logic := '1';
    reset     : in  std_logic := '0';
    din_valid : in  std_logic;          -- indicate if the input is valid
    dout      : out std_logic_vector(WIDTH_g-1 downto 0)
    );  

end component auk_dspip_upsample;

component auk_dspip_variable_downsample is
  generic (
    CHANNEL_SIZE_g  : natural range 1 to integer'high := 1;  -- number of channels
    WIDTH_g         : natural                         := 8;  -- data width
    RATE_WIDTH_g    : integer         -- bit width of decimation factor
    );
  port(
    clk        : in  std_logic;
    ena        : in  std_logic := '1';
    reset      : in  std_logic := '0';
    rate       : in  std_logic_vector(RATE_WIDTH_g-1 downto 0);
    din        : in  std_logic_vector(WIDTH_g-1 downto 0);
    dout       : out std_logic_vector(WIDTH_g-1 downto 0);
    dout_valid : out std_logic          -- indicate if the output is valid
    );  

end component auk_dspip_variable_downsample;
end package auk_dspip_cic_lib_pkg;
