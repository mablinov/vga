library ieee;
use ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

-- Important implementation notes:
-- 1). Unused data inputs should be connected Low. Unused address inputs should be connected High.

entity framebuffer36E1x8 is
	generic (
		INIT_FILE: string := "NONE"
	);
	port (
		a_addr: in std_logic_vector(11 downto 0);
		a_clk: in std_logic;

		a_en: in std_logic;
		a_regce: in std_logic;
		a_reset_ram: in std_logic;
		a_reset_reg: in std_logic;
		a_wren: in std_logic;
		
		a_data_out: out std_logic_vector(7 downto 0);
		
		b_addr: in std_logic_vector(11 downto 0);
		b_clk: in std_logic;

		b_en: in std_logic;
		b_regce: in std_logic;
		b_reset_ram: in std_logic;
		b_reset_reg: in std_logic;
		b_wren: in std_logic;

		b_data_in: in std_logic_vector(7 downto 0);
		b_data_out: out std_logic_vector(7 downto 0)
	);
end entity;

architecture behavioural of framebuffer36E1x8 is
	-- A-side interface
	signal ADDRA: std_logic_vector(15 downto 0) := (others => '0');
	signal CLKA: std_logic := '0';
	signal ENA: std_logic := '0'; -- device enable in TDP mode
	signal REGCEA: std_logic := '0'; -- output buffer register clock enable
	signal RSTRAMA: std_logic := '0'; -- reset output latch
	signal RSTREGA: std_logic := '0'; -- reset output buffer register
	signal BYTE_WEA: std_logic_vector(3 downto 0) := (others => '0');

	-- DIADI is unused
	-- DIPADIP is unused
	
	signal DOA: std_logic_vector(31 downto 0) := (others => '0');
	-- DIA is unused

	-- B-side interface
	signal ADDRB: std_logic_vector(15 downto 0) := (others => '0');
	signal CLKB: std_logic := '0';
	signal ENB: std_logic := '0'; -- device enable in TDP mode
	signal REGCEB: std_logic := '0'; -- output buffer register clock enable
	signal RSTRAMB: std_logic := '0'; -- reset output latch
	signal RSTREGB: std_logic := '0'; -- reset output buffer register
	signal BYTE_WEB: std_logic_vector(7 downto 0) := (others => '0');

	signal DIB: std_logic_vector(31 downto 0) := (others => '0');
	-- DIPBDIP is unused
	
	signal DOB: std_logic_vector(31 downto 0) := (others => '0');
	-- DOPBDOP is unused
begin
	-- A-side interface
	ADDRA <= "1" & a_addr & "111";
	CLKA <= a_clk;
	ENA <= a_en;
	REGCEA <= a_regce;
	RSTRAMA <= a_reset_ram;
	RSTREGA <= a_reset_reg;
	BYTE_WEA <= "000" & a_wren;
	
	-- DIADI is unused
	-- DIPADIP is unused
	
	a_data_out <= DOA(7 downto 0);
	
	-- B-side interface
	ADDRB <= "1" & b_addr & "111";
	CLKB <= b_clk;
	ENB <= b_en;
	REGCEB <= b_regce;
	RSTRAMB <= b_reset_ram;
	RSTREGB <= b_reset_reg;
	BYTE_WEB <= "0000000" & b_wren;

	DIB(7 downto 0) <= b_data_in;
	DIB(31 downto 8) <= (others => '0');
	-- DIPBDIP is unused
	
	b_data_out <= DOB(7 downto 0);
	-- DOPBDOP is unused
	
	vram_buffer_1: RAMB36E1
	generic map (
		DOA_REG => 1,
		DOB_REG => 1,
		INIT_FILE => INIT_FILE,
		
		READ_WIDTH_A => 9,
		READ_WIDTH_B => 9,
		WRITE_WIDTH_A => 9,
		WRITE_WIDTH_B => 9
	)
	port map (
		CASCADEOUTA => open,
		CASCADEOUTB => open,
		
		DBITERR => open,
		ECCPARITY => open,
		RDADDRECC => open,
		SBITERR => open,
	
		CASCADEINA => '0',
		CASCADEINB => '0',
		
		INJECTDBITERR => '0',
		INJECTSBITERR => '0',
	
		-- A-side interface
		ADDRARDADDR => ADDRA,
		CLKARDCLK => CLKA,
		ENARDEN => ENA,
		REGCEAREGCE => REGCEA,
		RSTRAMARSTRAM => RSTRAMA,
		RSTREGARSTREG => RSTREGA,
		WEA => BYTE_WEA,
		
		DIADI => (others => '0'),
		DIPADIP => (others => '0'),
	
		DOADO => DOA,
		DOPADOP => open,
		
		-- B-side interface
		ADDRBWRADDR => ADDRB,
		CLKBWRCLK => CLKB,
		ENBWREN => ENB,
		REGCEB => REGCEB,
		RSTRAMB => RSTRAMB,
		RSTREGB => RSTREGB,
		WEBWE => BYTE_WEB,
	
		DIBDI => DIB,
		DIPBDIP => (others => '0'),
	
		DOBDO => DOB,
		DOPBDOP => open
	);
end architecture;
