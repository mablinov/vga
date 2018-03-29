library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

--Done, got best: 25.1748, with:
--	clkfbout_mult_f = 9
--	clkout0_divide_f = 35.75
--	divclk_divide = 1


entity vga_pixel_clock is
	port (
	    clk: in std_logic;
		pixel_clk: out std_logic
	);
end vga_pixel_clock;

architecture Behavioral of vga_pixel_clock is
	signal CLKFB: std_logic;
begin

    MMCME2_BASE_inst : MMCME2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED", -- Jitter programming (OPTIMIZED, HIGH, LOW)
        CLKFBOUT_MULT_F => 9.0,
        -- Multiply value for all CLKOUT (2.000-64.000).
        CLKFBOUT_PHASE => 0.0,
        -- Phase offset in degrees of CLKFB (-360.000-360.000).
        CLKIN1_PERIOD => 10.0,
        -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
        CLKOUT1_DIVIDE => 1,
        CLKOUT2_DIVIDE => 1,
        CLKOUT3_DIVIDE => 1,
        CLKOUT4_DIVIDE => 1,
        CLKOUT5_DIVIDE => 1,
        CLKOUT6_DIVIDE => 1,
        CLKOUT0_DIVIDE_F => 35.750,
        -- Divide amount for CLKOUT0 (1.000-128.000).
        -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
        CLKOUT0_DUTY_CYCLE => 0.5,
        CLKOUT1_DUTY_CYCLE => 0.5,
        CLKOUT2_DUTY_CYCLE => 0.5,
        CLKOUT3_DUTY_CYCLE => 0.5,
        CLKOUT4_DUTY_CYCLE => 0.5,
        CLKOUT5_DUTY_CYCLE => 0.5,
        CLKOUT6_DUTY_CYCLE => 0.5,
        -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
        CLKOUT0_PHASE => 0.0,
        CLKOUT1_PHASE => 0.0,
        CLKOUT2_PHASE => 0.0,
        CLKOUT3_PHASE => 0.0,
        CLKOUT4_PHASE => 0.0,
        CLKOUT5_PHASE => 0.0,
        CLKOUT6_PHASE => 0.0,
        CLKOUT4_CASCADE => FALSE, -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
        DIVCLK_DIVIDE => 1,
        -- Master division value (1-106)
        REF_JITTER1 => 0.0,
        -- Reference input jitter in UI (0.000-0.999).
        STARTUP_WAIT => FALSE
        -- Delays DONE until MMCM is locked (FALSE, TRUE)
    ) port map (
        -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
        CLKOUT0 => pixel_clk,
        -- 1-bit output: CLKOUT0
        CLKOUT0B => open,
        -- 1-bit output: Inverted CLKOUT0
        CLKOUT1 => open,
        -- 1-bit output: CLKOUT1
        CLKOUT1B => open,
        -- 1-bit output: Inverted CLKOUT1
        CLKOUT2 => open,
        -- 1-bit output: CLKOUT2
        CLKOUT2B => open,
        -- 1-bit output: Inverted CLKOUT2
        CLKOUT3 => open,
        -- 1-bit output: CLKOUT3
        CLKOUT3B => open,
        -- 1-bit output: Inverted CLKOUT3
        CLKOUT4 => open,
        -- 1-bit output: CLKOUT4
        CLKOUT5 => open,
        -- 1-bit output: CLKOUT5
        CLKOUT6 => open,
        -- 1-bit output: CLKOUT6
        -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
        CLKFBOUT => CLKFB,
        -- 1-bit output: Feedback clock
        CLKFBOUTB => open, -- 1-bit output: Inverted CLKFBOUT
        -- Status Ports: 1-bit (each) output: MMCM status ports
        LOCKED => open,
        -- 1-bit output: LOCK
        -- Clock Inputs: 1-bit (each) input: Clock input
        CLKIN1 => clk,
        -- 1-bit input: Clock
        -- Control Ports: 1-bit (each) input: MMCM control ports
        PWRDWN => '0',
        -- 1-bit input: Power-down
        RST => '0',
        -- 1-bit input: Reset
        -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
        CLKFBIN => CLKFB
        -- 1-bit input: Feedback clock
    );

end Behavioral;
