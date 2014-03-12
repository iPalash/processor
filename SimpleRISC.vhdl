 -------------------------------------------------------
 --! @file SimpleRISC.vhdl
 --! @author Kunal Singhal and Swapnil Palash
 --! @brief This is compilation of all the components of the processor
 -------------------------------------------------------
Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! This is empty shell for the main compilation of all the other components in the processor
entity SimpleRISC is
end entity SimpleRISC;

--! This is main assembly of all the components of the prcessor.
--! This is also responsible for generation of clock signal which is sent to all the other components.
--! Further, program counter is also updated in this architecure description only.
architecture main of SimpleRISC is
	--! Instruciton Fetch Unit
	component IFUnit is
		port (PC: in std_logic_vector(31 downto 0); instruction: out std_logic_vector (31 downto 0));
	end component IFUnit;

	--! Constrol Unit
	component CUnit is
		port(Instruction: in std_logic_vector(31 downto 0);
		     isMov, isSt, isLd, isBeq, isBgt, isImmediate, isWb, isUBranch,isRet,isCall: out boolean; aluS: out std_logic_vector(2 downto 0));
	end component CUnit;

	--! Operand Fetch Unit and Register Write Unit
	component OFUnit is
		port(clk: in std_logic; Instruction, PC, aluR, ldR: in std_logic_vector(31 downto 0); isSt, isLd, isWb,isRet,isCall: in boolean;
		     immediate, branchTarget, op1, op2: out std_logic_vector(31 downto 0));
	end component OFUnit;

	--! Execute Unit
	component EXUnit is
		port(op1, op2, immediate: in std_logic_vector(31 downto 0); aluS: in std_logic_vector(2 downto 0); aluR: out std_logic_vector(31 downto 0);
	     	     isMov, isBeq, isBgt, isUBranch, isImmediate: in boolean; isBranchTaken: out boolean);
	end component EXUnit;

	--! Memory access unit
	component MAUnit is
		port(clk: in std_logic; op2, aluR: in std_logic_vector(31 downto 0); isSt, isLd: in boolean; ldResult: out std_logic_vector(31 downto 0));
	end component MAUnit;

	--! Clock Signal initialed with 0
	signal clk: std_logic:='0';
	--! Program Counter initialized with -4
	signal PC: std_logic_vector(31 downto 0):=X"FFFFFFFC";
	--! The instruction signal
	signal instruction: std_logic_vector(31 downto 0);
	
	--! boolean for mov statement
	signal isMov: boolean:=false;
	
	--! boolean for store statement 
	signal isSt: boolean:=false;
	
	--! boolean for load statement
	signal isLd: boolean:=false;
	
	--! boolean for branch if equal statement 
	signal isBeq: boolean:=false;
	
	--! boolean for branch if greater statement
	signal isBgt: boolean:=false;
	
	--! boolean for the statements whre second operand is an immediate
	signal isImmediate: boolean:=false;
	
	--! boolean for the statements involving writing into register
	signal isWb: boolean:=false;
	
	--! boolean for call, ret, b, bgt, beq instructions
	signal isUbranch: boolean:=false;
	
	--! boolean which is true when branch is taken by call, ret, b, bgt, beq instructions
	signal isBranchTaken: boolean:=false;
	
	--! boolean for ret instruction
	signal isRet: boolean:=false;
	
	--! boolean for call instruction
	signal isCall: boolean:=false;
	
	--! ALU Signals generated by the Control Unit for ALU to perform adequate operation
	signal aluS: std_logic_vector(2 downto 0);
	
	--! Result of the operation by ALU
	signal aluR: std_logic_vector(31 downto 0):=X"00000000"; 
	
	--! value read from register file
	signal ldR: std_logic_vector(31 downto 0):=X"00000000";
	
	--! immediate computer after applying modifiers and bit extension 
	signal immediate: std_logic_vector(31 downto 0):=X"00000000";
	
	--! brach target computed after adding offset to the program counter
	signal branchTarget: std_logic_vector(31 downto 0):=X"00000000";
	
	--! Fisrt Operand
	signal op1: std_logic_vector(31 downto 0):=X"00000000";
	
	--! Second Operand
	signal op2: std_logic_vector(31 downto 0):=X"00000000";

begin

	--! maps the signals to the ports of IFUnit
	iif: IFUnit port map(PC, instruction);
	--! maps the signals to the ports of CUnit
	icu: CUnit port map (instruction, isMov, isSt, isLd, isBeq, isBgt, isImmediate, isWb, isUBranch,isRet,isCall, aluS);
	--! maps the signals to the ports of OFUnit
	iof: OFUnit port map(clk, instruction, PC, aluR, ldR, isSt, isLd, isWb,isRet,isCall, immediate, branchTarget, op1, op2);
	--! maps the signals to the ports of EXUnit
	iex: EXUnit port map(op1, op2, immediate, aluS, aluR, isMov, isBeq, isBgt, isUBranch, isImmediate, isBranchTaken);
	--! maps the signals to the ports of MAUnit
	ima: MAUnit port map(clk, op2, aluR, isSt, isLd, ldR);

	--! clock impelentation
	clk<= not clk after 6 ns;

	--! program counter being updated
	PC<= std_logic_vector(unsigned(PC)+4) when (clk'event and clk='1' and (not isBranchTaken)) else
	     branchTarget when (clk'event and clk='1' and isBranchTaken);

end main;