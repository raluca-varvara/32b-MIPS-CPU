----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/19/2021 03:54:28 PM
-- Design Name: 
-- Module Name: EX - Behavioral
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

entity EX is
  Port (next_instr_adr: in STD_LOGIC_VECTOR(31 downto 0);
    rd1: in std_logic_vector(31 downto 0);
    rd2: in std_logic_vector(31 downto 0);
    ext_imm: in std_logic_vector(31 downto 0);
    funct: in std_logic_vector(5 downto 0);
    sa: in std_logic_vector(4 downto 0);
    ALUsrc: in std_logic;
    ALUop: in std_logic_vector(1 downto 0);
    AluRes: out std_logic_vector(31 downto 0);
    branch_adr: out std_logic_vector(31 downto 0);
    zero: out std_logic;
    bgtez: out std_logic);
end EX;

architecture Behavioral of EX is

signal b: std_logic_vector(31 downto 0);
signal alu_out: std_logic_vector(31 downto 0);
signal alu_ctrl: std_logic_vector(3 downto 0);

begin
    
    mux1:process(AluSrc, rd2, ext_imm)
    begin
    
        if ALUsrc = '0' then
            b <= rd2;
        else
            b <= ext_imm;
        end if;
    
    end process;
    
    ALUControl:process(AluOp, funct)
    begin
    
        case ALUop is
        when "00" => alu_ctrl <= "0000";
        when "01" => alu_ctrl <= "0001";
        when "10" => alu_ctrl <= funct(3 downto 0); -- am gandit astfel incat aluctrl sa fie funct
        when others => alu_ctrl <= "0100";
        end case;
    
    end process;
    
    ALU:process(rd1, b, alu_ctrl, sa)
    begin
        case alu_ctrl is
        when "0000" => alu_out <= rd1 + b;
        when "0001" => alu_out <= rd1 - b;
        when "0010" =>
            if sa = "00000" then
                alu_out <= rd1;
            else
                alu_out <= rd1(30 downto 0) & '0';
            end if;
        when "0011" =>
            if sa = "00000" then
                alu_out <= rd1;
            else
                alu_out <= '0' & rd1(31 downto 1) ;
            end if;
        when "0100" => alu_out <= rd1 and b;
        when "0101" => alu_out <= rd1 or b;
        when "0110" => alu_out <= rd1 xor b;
        when "0111" =>
            if sa = "00000" then
                alu_out <= rd1;
            else
                if rd1(31) = '0' then
                    alu_out <= '0' & rd1(31 downto 1) ;
                else
                    alu_out <= '1' & rd1(31 downto 1) ;
                end if;
            end if;
        when others => alu_out <= not rd1;
        end case;
    
    end process;
    
    flaguri:process(rd1, b)
    begin
        if alu_out = x"0000" then
            zero <= '1';
        else
            zero <= '0';
        end if;
        bgtez <= not rd1(15);
    end process;
    
    branch_address: branch_adr <= next_instr_adr + (ext_imm(29 downto 0)&"00");
    AluRes <= alu_out;
    

end Behavioral;
