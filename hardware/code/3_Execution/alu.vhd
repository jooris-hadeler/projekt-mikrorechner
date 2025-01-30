library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alu_opcode.all;

entity alu is
   port( opA, opB: in signed(31 downto 0);
         result: out  signed(31 downto 0);
		 op: in STD_LOGIC_VECTOR(4 downto 0));
end entity alu;

architecture behaviour of alu is
  begin
    alu_prozess : process (opA, opB, op) is
		variable shift: signed(31 downto 0);
      begin
	
       case op is 
		when alu_mov => result <= opA;
	    when alu_add => result <= opA + opB;
		when alu_sub => result <= opA - opB;
	    when alu_lsl => 
			shift := opA;
			for i in to_integer(opB) downto 1 loop
				shift := shift(30 downto 0) & '0';
			end loop;
			result <= shift;
		when alu_lsr => 
			shift := opA;
			for i in to_Integer(opB) downto 1 loop
				shift := '0' & shift(31 downto 1);
			end loop;
			result <= shift;
		when alu_asr => 
				shift := opA;
			for i in to_integer(opB) downto 1 loop
				shift := shift(31) & shift(31 downto 1);
			end loop;
			result <= shift;
		when alu_and => result <= opA AND opB; --and
		when alu_or => result <= opA OR opB; --or
		when alu_xor => result <= opA XOR opB; --or
		when alu_not => result <= NOT opA; --not
		
		when alu_cmpe => if opA = opB then result <= "00000000000000000000000000000001"; -- cmpe
		else result <= "00000000000000000000000000000000"; -- cmpe else
		end if;

		when alu_cmpne => if opA /= opB then result <= "00000000000000000000000000000001"; -- compne 
		else result <= "00000000000000000000000000000000"; -- compne else
		end if;

		when alu_cmpgt => if opA > opB then result <= "00000000000000000000000000000001"; --cmpgt
		else result <= "00000000000000000000000000000000"; --cmpgt else
		end if;

		when alu_cmpgt_u => if unsigned(opA) > unsigned(opB) then result <= "00000000000000000000000000000001"; --cmpgt
		else result <= "00000000000000000000000000000000"; --cmpgt else
		end if;

		when alu_cmplt => if opA < opB then result <= "00000000000000000000000000000001"; --cmplt
		else result <= "00000000000000000000000000000000"; --cmplt else
		end if;

		when alu_cmplt_u => if unsigned(opA) < unsigned(opB) then result <= "00000000000000000000000000000001"; --cmplt
		else result <= "00000000000000000000000000000000"; --cmplt else
		end if;

	    when others => result <= opA; --default

	end case;
	end process alu_prozess;
end behaviour;		  

	  
-- TODO 
-- input a, input b, input op, output result def
-- prozess intitalisieren aka konstrukt einfach bauen
-- überlegen wie amn logischen shift nach rechts umsetzt
-- imports der library
-- prüfen ob da select hinkommen

-- mux integrieren in die alus -> erster ansatz sonst extern verlagern