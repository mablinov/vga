library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vga_util.all;

entity vga_simple_grid_tb is
end entity;

architecture behavioural of vga_simple_grid_tb is
    component vga_simple_grid is
        port (
            clk: in std_logic;
        
            vga_r: out std_logic_vector(3 downto 0);
            vga_g: out std_logic_vector(3 downto 0);
            vga_b: out std_logic_vector(3 downto 0);
            vga_hs: out std_logic;
            vga_vs: out std_logic
        );
    end component;

    signal clk: std_logic := '0';
    signal vga_hs, vga_vs: std_logic;
    signal vga_r, vga_g, vga_b: std_logic_vector(3 downto 0);
begin

    clk <= not clk after 5 ns;

    uut: vga_simple_grid
    port map (
        clk => clk,
        vga_r => vga_r,
        vga_g => vga_g,
        vga_b => vga_b,
        vga_hs => vga_hs,
        vga_vs => vga_vs
    );

end architecture;

