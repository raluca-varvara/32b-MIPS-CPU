----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/05/2021 02:34:07 PM
-- Design Name: 
-- Module Name: InstrFetch - Behavioral
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

entity InstrFetch is
  Port (clk : in STD_LOGIC;
  en : in STD_LOGIC;
  reset : in STD_LOGIC;
  jump : in STD_LOGIC;
  PCSrc : in STD_LOGIC;
  branch_adr: in STD_LOGIC_VECTOR(31 downto 0);
  jump_adr: in STD_LOGIC_VECTOR(31 downto 0);
  instr: out STD_LOGIC_VECTOR(31 downto 0);
  next_instr_adr: out STD_LOGIC_VECTOR(31 downto 0) );
end InstrFetch;

architecture Behavioral of InstrFetch is
type ROM is array (0 to 255) of std_logic_vector(7 downto 0);

signal ROM1: ROM := 
(B"00000000", B"00000000", B"00001000", B"00000000", -- 0 add $1, $0 $0 --0
 B"00000100", B"00000011", B"00000000", B"00001010", --4 addi $3 $0 10  --4
 B"00001000", B"00100100", B"00000000", B"00000000", --8 lw $4 0($1) -- minim --8
 B"00001000", B"00100101", B"00000000", B"00000000", --12 lw $5 0($1) --maxim --C
 B"00001100", B"00000100", B"00000000", B"00001011", --16 sw $4 11($0) --11 minim --10
 B"00001100", B"00000101", B"00000000", B"00001100", --20 sw $5 12($0) --12 maxim --14
 B"00010000", B"00100011", B"00000000", B"00001011",--24 beq $1 $3 11 --if(i==10)jump --18
 B"00001000", B"00100110", B"00000000", B"00000000",--28 lw $6 0($1) --elem curent --1C
 B"00000000", B"10100110", B"00111000", B"00000001", --32 sub $7 $5 $6 --max --20
 B"00011000", B"11100000", B"00000000", B"00000010", --36 bgez $7 2 --24
 B"00000000", B"00000110", B"00101000", B"00000000", --40 add $6 $0 $5 5 = 6+0 --28
 B"00001100", B"00000110", B"00000000", B"00001100", --44 sw $6 12($0) --2C
 B"00000000", B"11000100", B"00111000", B"00000001", --48 sub $7 $6 $4 --min --30
 B"00011000", B"11100000", B"00000000", B"00000010",--52 bgez $7 2 --34
 B"00000000", B"00000110", B"00100000", B"00000000", --56 add $4 $0 $6 4 = 6 + 0 --38
 B"00001100", B"00000100", B"00000000", B"00001011", --60 sw $4 11($0) --3C
 B"00000100", B"00100001", B"00000000", B"00000001", --64 addi $1 1 --40
 B"00100100", B"00000000", B"00000000", B"00000110", --68 j 6 --44
 B"00001000", B"00000100", B"00000000", B"00001011", --72 lw $4 11($0) --48
 B"00001000", B"00000101", B"00000000", B"00001100", --76 lw $5 12($0) --4C
 B"00000000", B"10000101", B"00110000", B"00000000", --80 add $6 $4 $5 --50
 B"00000000", B"11000000", B"00110000", B"01000111", --84 sra $6 1 --54
 others => x"00");

signal prog_counter:  STD_LOGIC_VECTOR(31 downto 0):=x"00000000";
signal prog_counter_sum:  STD_LOGIC_VECTOR(31 downto 0):=x"00000000";
signal mux_jump:  STD_LOGIC_VECTOR(31 downto 0):=x"00000000";
signal mux_branch:  STD_LOGIC_VECTOR(31 downto 0):=x"00000000";

begin
    pc: process(clk, en, reset)
    begin
        if reset = '1' then
            prog_counter <= x"00000000";
        end if;
        if clk'event and clk='1' then
            if en = '1' then
                prog_counter <= mux_jump;
            end if;
        end if;
    end process;
    
    sumator: prog_counter_sum <= prog_counter + 4;
    
    MUX1:process(PCSrc, branch_adr, prog_counter_sum)
    begin
        if PCSrc = '1' then
            mux_branch <= branch_adr;
        else
            mux_branch <= prog_counter_sum;
        end if;
    end process;
    
    MUX2:process(jump, jump_adr, mux_branch)
    begin
        if jump = '1' then
            mux_jump <= jump_adr;
        else
            mux_jump <= mux_branch;
        end if;
    end process;
    
    instr <= ROM1(conv_integer(prog_counter(7 downto 0))) & ROM1(conv_integer(prog_counter(7 downto 0)) + 1) & ROM1(conv_integer(prog_counter(7 downto 0)) + 2) & ROM1(conv_integer(prog_counter(7 downto 0)) + 3);
    next_instr_adr <= prog_counter_sum;

end Behavioral;
