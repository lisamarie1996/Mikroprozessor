LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.definitions.ALL;

ENTITY registers IS
	PORT (
		-- control signals
		clock		: IN std_logic;	-- clock
		rw		: IN std_logic;	-- read / write
		mem_res 	: IN std_logic;	-- write input (data_mem / data_res)
		reg_imm 	: IN std_logic;	-- write address (write_reg / write_imm)

		-- inputs
		read_1		: IN reg_addr;	-- first register address
		read_2		: IN reg_addr;	-- second register address
		write_reg	: IN reg_addr;	-- third register address (write)
		write_imm	: IN reg_addr;	-- second register address (write)
		data_mem	: IN word;	-- data from memory
		data_res	: IN word;	-- data form result

		-- outputs
		data_1		: OUT word;	-- first register data
		data_2		: OUT word	-- second register data
	);
END registers;

ARCHITECTURE behavioural OF registers IS
BEGIN
	PROCESS (clock, read_1, read_2)

		SUBTYPE writecntrl IS std_logic_vector(1 DOWNTO 0);						-- write control

		TYPE register_bank IS ARRAY(0 TO 31) OF word;							-- register bank
		VARIABLE values: register_bank;									-- register values

	BEGIN
		IF clock'event AND clock = '1' THEN
			IF rw = '1' THEN
				CASE writecntrl'(reg_imm & mem_res) IS
					WHEN "00" => values(to_integer(unsigned(write_reg))) := data_mem;	-- 3-register-instruction, data from memory
					WHEN "01" => values(to_integer(unsigned(write_reg))) := data_res;	-- 3-register-instruction, data from result
					WHEN "10" => values(to_integer(unsigned(write_imm))) := data_mem;	-- Immediate-instruction, data from memory
					WHEN "11" => values(to_integer(unsigned(write_imm))) := data_res;	-- Immediate-instruction, data from result
					WHEN OTHERS => NULL;
				END CASE;
			END IF;
		END IF;

		CASE to_integer(unsigned(read_1)) IS								-- first register
			WHEN 30 => data_1 <= (OTHERS => '0');
			WHEN 31 => data_1 <= (0 => '1', OTHERS => '0');
			WHEN OTHERS => data_1 <= values(to_integer(unsigned(read_1)));
		END CASE;

		CASE to_integer(unsigned(read_2)) IS								-- second register
			WHEN 30 => data_2 <= (OTHERS => '0');
			WHEN 31 => data_2 <= (0 => '1', OTHERS => '0');
			WHEN OTHERS => data_2 <= values(to_integer(unsigned(read_2)));
		END CASE;	
	END PROCESS;
END behavioural;