----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.09.2024 10:32:30
-- Design Name: 
-- Module Name: Mem_cache - Behavioral
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

entity Mem_cache is
  Port (DATA_VALID: in STD_LOGIC;
        Din : in STD_LOGIC_VECTOR (7 downto 0);
        CLK : in std_logic;
        RESET : in std_logic;
        Dout: out STD_LOGIC_VECTOR (7 downto 0);
        NB_AVAILABLE : out STD_LOGIC;
        write_fifo_1 : in std_logic;
        write_fifo_2 : in std_logic;
        enable_bascule : in std_logic;
        treshold: in std_logic_vector (9 downto 0));
end Mem_cache;

architecture Behavioral of Mem_cache is

component flip_flop 
    Port ( D : in STD_LOGIC_VECTOR (7 downto 0);
           Q : out STD_LOGIC_VECTOR (7 downto 0);
           Clk : in STD_LOGIC;
           EN : in STD_LOGIC;
           RESET : in STD_LOGIC);
end component;

component fifo_generator_0
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    prog_full_thresh : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC
  );
END component;

--signaux fifos
--signal wr_en_fifo :std_logic;
--signal rd_en_fifo :std_logic;
signal prog_full_thresh_s : std_logic_vector (9 downto 0);
signal full_s : std_logic;
signal empty_s : std_logic;
signal prog_full_s: std_logic;

signal full_2s : std_logic;
signal empty_2s : std_logic;
signal prog_full_2s: std_logic;
--signal wr_en_fifo2 :std_logic;
--signal rd_en_fifo2 :std_logic;
--signaux bascules
-- 72 bits + 24 de transition après les fifos
signal transit : std_logic_vector (95 downto 0);


begin
-------------------------------------------------------------
-- INSTANCIATION COMPOSANTS --
-------------------------------------------------------------
-- 3 premieres bascules--------------------------------------
    FU1:flip_flop  port map(
        din( 7 downto 0 ),     
        transit(7 downto 0),       
        Clk,
        enable_bascule,
        reset);

FF_REG_1: for I in 1 to 2 generate
    FUX:flip_flop  port map(
        transit((I*8)-1 downto (I-1)*8),     
        transit((I*8)+7 downto I*8),       
        Clk,
        enable_bascule,
        reset
        );    
end generate;
-----------------------------------------------------------
-- 2 e vague de bascule (n° 4, 5, 6 )
FF_REG_2: for I in 4 to 6 generate
    FUX2:flip_flop  port map(
        transit((I*8)-1 downto (I-1)*8),     
        transit((I*8)+7 downto I*8),       
        Clk,
        enable_bascule,
        reset
        );    
end generate;

-- 3e vague de bascule (n° 7, 8, 9)
FF_REG_3: for I in 8 to 10 generate
    FUX3:flip_flop  port map(
        transit((I*8)-1 downto (I-1)*8),     
        transit((I*8)+7 downto I*8),       
        Clk,
        enable_bascule,
        reset
        );    
end generate;

-- Les 3 fifo du systeme (pour la troisième, on considere seulement le bus)
    U0:fifo_generator_0 port map(
        clk,
        reset,
        transit(23 downto 16),
        write_fifo_1,
        prog_full_s , --ligne à retard (rd_en)
        treshold(9 downto 0),
        transit(31 downto 24),
        full_s ,
        empty_s,
        prog_full_s
        );

    U1:fifo_generator_0 port map(
        clk,
        reset,
        transit(55 downto 48),
        write_fifo_2,
        prog_full_2s, --ligne à retard (rd_en)
        treshold(9 downto 0),
        transit(63 downto 56),
        full_2s ,
        empty_2s,
        prog_full_2s
        );
-------------------------------------------------------------
-- FIN INSTANCIATION COMPOSANTS --
-------------------------------------------------------------
    --prog_full_thresh_s <= "0001111101"; -- initialisation du seuil des fifo à 125 ( 3 mots stockés dans les bascules)

    dout <= transit(87 downto 80); -- fin du bus de transit de données


end Behavioral;
