library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity data_mem is
    port (
	clk 	 : in std_logic;
        MemRW    : in std_logic;
	Mem2Reg  : in std_logic;
	alu_out  : in std_logic_vector(31 downto 0);
	data_in  : in std_logic_vector(31 downto 0);
	
	data_out : out std_logic_vector(31 downto 0);
	io_out 	: out std_logic_vector(31 downto 0)
    );
end entity data_mem;

architecture data_mem_behav of data_mem is
    -- subtype mem_word of length word/byte
    subtype mem_word is std_logic_vector(7 downto 0);
    -- type storage defined as array of Bytes
    type storage is array(0 to 100) of mem_word;
    -- initialize mem of type storage
   
--    impure function init_data_mem return storage is
--	file text_file       : text;
--	variable text_line   : line;
--	variable machinecode : std_logic_vector(31 downto 0);
--	variable mem_content : storage := (others => (others => '0'));
--	variable i           : integer := 0;
--    begin
--	file_open(text_file, "C:\Massenspeicher\Studium\Semester 5\Projekt Chipdesign\Chipdesign\fibonacci_memory.txt", read_mode);
--	while not endfile(text_file) loop
--	    readline(text_file, text_line);
--	    read(text_line, machinecode);
--	    mem_content(i)   := machinecode(31 downto 24);
--	    mem_content(i+1) := machinecode(23 downto 16);
--	    mem_content(i+2) := machinecode(15 downto 8);
--	    mem_content(i+3) := machinecode(7 downto 0);
--	    i := i+4;
--	end loop;
--
--	return mem_content;
--    end function;
	
    signal mem : storage := (
	 7 => ("00010100"),
	 11 => ("00000100"),
	 19 => ("00000001"),
	 others =>(others=>'0'));
begin
    process(clk, Mem2Reg, MemRW, alu_out, data_in)
	variable idx  : integer := 0;	-- index as integer
	variable data : std_logic_vector(31 downto 0);	-- buffer for selected data
	
    begin
	idx := to_integer(unsigned(alu_out));	-- get index
	
	data := alu_out;
	
	if(Mem2Reg = '0') then	   
           data(31 downto 24) := mem(idx);	-- iterate through next 4 Bytes to get 32-Bit Data
	    data(23 downto 16) := mem(idx+1);
	    data(15 downto 8)  := mem(idx+2);
	    data(7 downto 0)   := mem(idx+3);
	end if;
	
	if (clk'event and clk='0') then
	    if (MemRW = '1') then	-- if memory set into write mode
	        mem(idx)   <= data_in(31 downto 24);	-- save data over next 4 Bytes
	        mem(idx+1) <= data_in(23 downto 16);
	        mem(idx+2) <= data_in(15 downto 8);
	        mem(idx+3) <= data_in(7 downto 0);
	    end if;
	end if;

	data_out <= data;
    end process;    
	 process(clk)
	 
	 variable idx_io  : integer := 0;	-- index as integer
	 begin
	 
	    idx_io := 20;								-- adress for io output is 100 
       io_out(31 downto 24) <= mem(idx_io);	-- iterate through next 4 Bytes to get 32-Bit Data
	    io_out(23 downto 16) <= mem(idx_io+1);
	    io_out(15 downto 8)  <= mem(idx_io+2);
	    io_out(7 downto 0)   <= mem(idx_io+3);
	 end process; 
end data_mem_behav;