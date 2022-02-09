----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/06/2021 01:38:45 PM
-- Design Name: 
-- Module Name: MEM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEM is
  Port (clk : in std_logic;
  en: in std_logic;
  memwrite: in std_logic;
  AluRes: in std_logic_vector(31 downto 0);
  rd2: in std_logic_vector(31 downto 0);
  mem_data: out std_logic_vector(31 downto 0);
  AluResOut: out std_logic_vector(31 downto 0) );
end MEM;

architecture Behavioral of MEM is

type ram_type is array (0 to 255) of std_logic_vector (7 downto 0);
signal RAM: ram_type:=(
x"00", x"00", x"00", x"02",
x"00", x"00", x"00", x"05",
x"00", x"00", x"00", x"0C",
x"00", x"00", x"00", x"03",
x"00", x"00", x"00", x"14",
x"00", x"00", x"00", x"09",
x"00", x"00", x"00", x"0B",
x"00", x"00", x"00", x"19",
x"00", x"00", x"00", x"02",
x"00", x"00", x"00", x"01",
others=>x"0000");

begin
    process(clk, en, memwrite, AluRes)
    begin
        mem_data <= RAM(conv_integer(AluRes(6 downto 0))) & RAM(conv_integer(AluRes(6 downto 0)) + 1) & RAM(conv_integer(AluRes(6 downto 0)) + 2) & RAM(conv_integer(AluRes(6 downto 0)) + 3);
        if rising_edge(clk) then
            if memwrite = '1' and en = '1' then
                RAM(conv_integer(AluRes(6 downto 0)) + 3) <= rd2(7 downto 0);
                RAM(conv_integer(AluRes(6 downto 0)) + 2) <= rd2(15 downto 8);
                RAM(conv_integer(AluRes(6 downto 0)) + 1) <= rd2(23 downto 16);
                RAM(conv_integer(AluRes(6 downto 0)) + 0) <= rd2(31 downto 24);
            end if;
        end if;
    end process;
    AluResOut <= AluRes;

end Behavioral;
