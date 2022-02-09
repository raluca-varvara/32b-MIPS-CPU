----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/19/2021 02:47:10 PM
-- Design Name: 
-- Module Name: main - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
  Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR(4 downto 0);
           sw : in STD_LOGIC_VECTOR(15 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end main;

architecture Behavioral of main is


-- generale
signal en: std_logic;
signal reset: std_logic;
signal digits: std_logic_vector(15 downto 0) := x"0000";
signal instr:  STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal next_instr_adr: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";

--IF
signal branch_adr: std_logic_vector(31 downto 0);
signal jump_adr: std_logic_vector(31 downto 0);

--ID
signal  wd: std_logic_vector(31 downto 0);
signal  rd1: std_logic_vector(31 downto 0);
signal  rd2: std_logic_vector(31 downto 0);
signal  ext_imm: std_logic_vector(31 downto 0);
signal  funct: std_logic_vector(5 downto 0);
signal  sa: std_logic_vector(4 downto 0);

-- semnale de control UC
signal regdst: std_logic;
signal regwrite: std_logic;
signal ALUsrc: std_logic;
signal extop: std_logic;
signal ALUop: std_logic_vector(1 downto 0);
signal memwrite: std_logic;
signal memtoreg: std_logic;
signal branch: std_logic;
signal branch_grt: std_logic;
signal branch_not_eq: std_logic;
signal  slt: std_logic;
signal  movi:  std_logic;
signal  movd: std_logic;
signal jump: std_logic;
signal PCSrc: std_logic;

--semnale ALU EX
signal zero: std_logic;
signal bgtez: std_logic;
signal AluRes: std_logic_vector(31 downto 0);

--semnale MEM
signal mem_data: std_logic_vector(31 downto 0);
signal AluResOut: std_logic_vector(31 downto 0);

--semnale WB
signal slt_data: std_logic_vector(31 downto 0) := x"00000000";
signal slt_or_mem: std_logic_vector(31 downto 0) := x"00000000";
signal movi_data: std_logic_vector(31 downto 0) := x"00000000";
signal memtoreg_data: std_logic_vector(31 downto 0) := x"00000000";


component MPG is
  Port (en: out  STD_LOGIC;
    input: in STD_LOGIC;
    clk : in  STD_LOGIC);
end component;

component SSD is
  Port (digits: in STD_LOGIC_VECTOR(15 downto 0);
     clk: in STD_LOGIC;
     an : out STD_LOGIC_VECTOR(3 downto 0);
     cat : out STD_LOGIC_VECTOR(6 downto 0) );
end component;

component InstrFetch is
  Port (clk : in STD_LOGIC;
  en : in STD_LOGIC;
  reset : in STD_LOGIC;
  jump : in STD_LOGIC;
  PCSrc : in STD_LOGIC;
  branch_adr: in STD_LOGIC_VECTOR(31 downto 0);
  jump_adr: in STD_LOGIC_VECTOR(31 downto 0);
  instr: out STD_LOGIC_VECTOR(31 downto 0);
  next_instr_adr: out STD_LOGIC_VECTOR(31 downto 0) );
end component;

component ID is
  Port ( clk: in std_logic;
  en: in std_logic;
  regwrite: in std_logic;
  regdst: in std_logic;
  extop: in std_logic;
  instr: in std_logic_vector(31 downto 0);
  wd: in std_logic_vector(31 downto 0);
  rd1: out std_logic_vector(31 downto 0);
  rd2: out std_logic_vector(31 downto 0);
  ext_imm: out std_logic_vector(31 downto 0);
  funct: out std_logic_vector(5 downto 0);
  sa: out std_logic_vector(4 downto 0)  );
end component;

component EX is
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
end component;

component MEM is
  Port (clk : in std_logic;
  en: in std_logic;
  memwrite: in std_logic;
  AluRes: in std_logic_vector(31 downto 0);
  rd2: in std_logic_vector(31 downto 0);
  mem_data: out std_logic_vector(31 downto 0);
  AluResOut: out std_logic_vector(31 downto 0) );
end component;

component UC is
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
end component;

begin
    
    MPG1: MPG port map (en => en, input => btn(0), clk => clk);
    MPG2: MPG port map (en => reset, input => btn(1), clk => clk);
    SSD1: SSD port map(digits => digits, clk => clk, an => an, cat => cat);
    InstrF: InstrFetch port map (clk => clk, en => en, reset => reset, jump => jump, PCSrc => PCSrc, branch_adr => branch_adr, jump_adr => jump_adr, instr => instr, next_instr_adr => next_instr_adr);
    ID1: ID port map (clk => clk, en => en, regwrite => regwrite, regdst => regdst, extop => extop, instr => instr, wd => wd, rd1 => rd1, rd2 => rd2, ext_imm => ext_imm, funct => funct, sa => sa);
    EX1: EX port map (next_instr_adr => next_instr_adr, rd1 => rd1, rd2 => rd2, ext_imm => ext_imm, funct => funct, sa => sa, AluSrc => Alusrc, aluop => aluop, alures => alures, branch_adr => branch_adr, zero => zero, bgtez => bgtez);
    MEM1: MEM port map (clk => clk, en => en, memwrite => memwrite, alures => alures, aluresout => aluresout, rd2 => rd2, mem_data => mem_data);
    UC1: UC port map(opcode => instr(31 downto 26), funct => funct, regwrite => regwrite, regdst => regdst, ALUsrc => ALUsrc, extop => extop, ALUop => ALUop, memwrite => memwrite, memtoreg => memtoreg, branch => branch, branch_grt => branch_grt, branch_not_eq => branch_not_eq, slt => slt, movi => movi, movd => movd, jump => jump);
    
    JUMP_ADDRESS: jump_adr <= next_instr_adr(31 downto 28) & instr(25 downto 0) & "00";
    PC_SRC1: PCSrc <= (zero and branch) or ( (not zero) and branch_not_eq) or (branch_grt and bgtez);
    
    SLT1:process(bgtez)
    begin
    
        if bgtez = '0' then
            slt_data <= x"00000000";
        else
            slt_data <= x"00000001";
        end if;
    
    end process;
    
    Memtoreg1:process(memtoreg, mem_data, AluResOut)
    begin
    
        if memtoreg = '0' then
            memtoreg_data <= AluResOut;
        else
            memtoreg_data <= mem_data;
        end if;   
    end process;
    
    slt_mem:process(slt, slt_data, memtoreg_data)
    begin  
        if slt = '0' then
            slt_or_mem <= memtoreg_data;
        else
            slt_or_mem <= slt_data;
        end if;
    end process;
    
    movi_d:process(movi, ext_imm, slt_or_mem)
    begin  
        if movi = '0' then
            movi_data <= slt_or_mem;
        else
            movi_data <= ext_imm;
        end if;
    end process;
    
    movd_d:process(movd, movi_data, rd2)
    begin  
        if movd = '0' then
            wd <= movi_data;
        else
            wd <= rd2;
        end if;
    end process;
    
    MUX: process(sw(7 downto 5), instr, next_instr_adr, rd1, rd2, wd)
    begin
    
        case sw(8 downto 5) is
        when "0000" => digits <= instr(15 downto 0);
        when "0001" => digits <= next_instr_adr(15 downto 0);
        when "0010" => digits <= rd1(15 downto 0);
        when "0011" => digits <= rd2(15 downto 0);
        when "0100" => digits <= ext_imm(15 downto 0);
        when "0101" => digits <= AluRes(15 downto 0);
        when "0110" => digits <= mem_data(15 downto 0);
        when "0111" => digits <= wd(15 downto 0);
        when others => digits <= instr(31 downto 16);
        end case;
    
    end process;
    
    led(5 downto 0) <= instr(31 downto 26);
    
end Behavioral;
