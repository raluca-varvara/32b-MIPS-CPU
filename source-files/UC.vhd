----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/27/2021 07:24:58 PM
-- Design Name: 
-- Module Name: UC - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UC is
  Port (opcode: in std_logic_vector(5 downto 0);
  funct: in std_logic_vector(5 downto 0);
  regdst: out std_logic;
  regwrite: out std_logic;
  ALUsrc: out std_logic;
  extop: out std_logic;
  ALUop: out std_logic_vector(1 downto 0);
  memwrite: out std_logic;
  memtoreg: out std_logic;
  branch: out std_logic;
  branch_grt: out std_logic;
  branch_not_eq: out std_logic;
  slt: out std_logic;
  movi: out std_logic;
  movd: out std_logic;
  jump: out std_logic);
end UC;

architecture Behavioral of UC is

begin
    process(opcode)
    begin
        regdst <= '0';
        regwrite <= '0';
        ALUsrc <= '0';
        extop <= '0';
        ALUop <= "00";
        memwrite <= '0';
        memtoreg <= '0';
        branch <= '0';
        branch_grt <= '0';
        branch_not_eq <= '0';
        slt <= '0';
        movi <= '0';
        movd <= '0';
        jump <= '0';
        
        case opcode is
            when "000000" => regdst <= '1'; regwrite <= '1'; ALUop <= "10"; --tip r
                            if funct = "001001" then
                                slt <= '1';
                            end if;
            when "000001" => regwrite <= '1'; ALUsrc <= '1'; extop <= '1'; --addi
            when "000010" => regwrite <= '1'; ALUsrc <= '1'; extop <= '1'; memtoreg <= '1'; --lw
            when "000011" => ALUsrc <= '1'; extop <= '1'; memwrite <= '1'; --sw
            when "000100" => extop <= '1'; ALUop <= "01"; branch <= '1'; --beq
            when "000101" => extop <= '1'; ALUop <= "01"; branch_not_eq <= '1'; --bne
            when "000110" => extop <= '1'; branch_grt <= '1'; --bgez
            when "000111" => extop <= '1';  movi <= '1'; regwrite <= '1'; --movi
            when "001000" =>  movd <= '1'; regwrite <= '1'; --movd
            when others => jump <= '1';
        end case;
        
    end process;

end Behavioral;
