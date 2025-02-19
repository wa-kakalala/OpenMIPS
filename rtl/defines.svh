/**************************************
@ filename    : defines.sv
@ author      : yyrwkk
@ create time : 2024/08/12 21:46:51
@ version     : v1.0.0
**************************************/

/***************** global defination begin ********************/
`define RST_ENABLE     1'b0       // rst signal enable value, 0->enable or 1->enable
`define RST_DISABLE    1'b1       // rst signal disable value , ~RST_ENABLE

`define ZERO_WORD      32'b0      // 32 bit zero
`define WRITE_ENABLE   1'b1       // enable write
`define WRITE_DISABLE  1'b0       // disalbe write
`define READ_ENABLE    1'b1       // enable read
`define READ_DISABLE   1'b0       // disable read

`define N_INST_OP      6
`define N_INST_SUB_OP  5

`define N_ALU_OP       8          // width of alu_op in id stage
`define N_ALU_SEL      3          // width of alu_sel in id stage

`define INST_VALID     1'b0       // instruct valid
`define INST_INVALID   1'b1       // instruct invalid

`define VALUE_TRUE     1'b1       // logic true
`define VALUE_FALSE    1'b0       // logic false

`define CHIP_ENABLE    1'b1       // chip enable
`define CHIP_DISABLE   1'b0       // chip disable

`define STOP           1'b1       // pause pipeline
`define NO_STOP        1'b0       // no pause pipeline

`define BRANCH         1'b1       // branch
`define NO_BRANCH      1'b0       // no branch

`define DELAY_SLOT     1'b1       // in delayslot 
`define NOT_DELAY_SLOT 1'b0       // not in delayslot

`define INTERRUPT_ASSERT 1'b1
`define TRAP_ASSERT      1'b1 
`define TRAP_NOT_ASSERT  1'b0   
/***************** global defination  end  ********************/

/***************** instruct relatived defination begin ********************/
`define EXE_AND         6'b100100             // instruct and  opcode
`define EXE_OR          6'b100101             // instruct or   opcode
`define EXE_XOR         6'b100110             // instruct xor  opcode
`define EXE_NOR         6'b100111             // instruct nor  opcode
`define EXE_ANDI        6'b001100             // instruct andi opcode
`define EXE_ORI         6'b001101             // instruct ori  opcode
`define EXE_XORI        6'b001110             // instruct xori opcode
`define EXE_LUI         6'b001111             // instruct lui  opcode
`define EXE_NOP         6'b000000             // instruct nop  opcode

`define EXE_SLL         6'b000000             // instruct sll  opcode
`define EXE_SLLV        6'b000100             // instruct sllv opcode
`define EXE_SRL         6'b000010             // instruct sra  opcode
`define EXE_SRLV        6'b000110             // instruct srlv opcode
`define EXE_SRA         6'b000011             // instruct sra  opcode
`define EXE_SRAV        6'b000111             // instruct srav opcode

`define EXE_SYNC        6'b001111             // instruct sync opcode
`define EXE_PREF        6'b110011             // instruct pref opcode

`define EXE_SPECIAL     6'b000000             // instruct special  opcode
`define EXE_SPECIAL2    6'b011100             // instruct special2 opcode
`define EXE_REGIMM      6'b000001             // instruct regimm   opcode

`define EXE_MOVZ        6'b001010             // instruct movz opcode
`define EXE_MOVN        6'b001011             // instruct movn opcode
`define EXE_MFHI        6'b010000             // instruct mfhi opcode
`define EXE_MTHI        6'b010001             // instruct mthi opcode
`define EXE_MFLO        6'b010010             // instruct mflo opcode
`define EXE_MTLO        6'b010011             // instruct mtlo opcode

`define EXE_SLT         6'b101010             // instruct slt   opcode           
`define EXE_SLTU        6'b101011             // instruct sltu  opcode 
`define EXE_SLTI        6'b001010             // instruct slti  opcode 
`define EXE_SLTIU       6'b001011             // instruct sltiu opcode
`define EXE_ADD         6'b100000             // instruct add   opcode 
`define EXE_ADDU        6'b100001             // instruct addu  opcode 
`define EXE_SUB         6'b100010             // instruct sub   opcode
`define EXE_SUBU        6'b100011             // instruct subu  opcode  
`define EXE_ADDI        6'b001000             // instruct addi  opcode   
`define EXE_ADDIU       6'b001001             // instruct addiu opcode 
`define EXE_CLZ         6'b100000             // instruct clz   opcode  
`define EXE_CLO         6'b100001             // instruct clo   opcode
`define EXE_MULT        6'b011000             // instruct mult  opcode
`define EXE_MULTU       6'b011001             // instruct multu opcode
`define EXE_MUL         6'b000010             // instruct mul   opcode

`define EXE_MADD        6'b000000             // instruct madd  opcode
`define EXE_MADDU       6'b000001             // instruct maddu opcode
`define EXE_MSUB        6'b000100             // instruct msub  opcode
`define EXE_MSUBU       6'b000101             // instruct msubu opcode

`define EXE_DIV         6'b011010             // instruct div   opcode
`define EXE_DIVU        6'b011011             // instruct divu  opcode

`define EXE_J           6'b000010             // instruct j      opcode   
`define EXE_JAL         6'b000011             // instruct jal    opcode
`define EXE_JALR        6'b001001             // instruct jalr   opcode
`define EXE_JR          6'b001000             // instruct jr     opcode
`define EXE_BEQ         6'b000100             // instruct beq    opcode
`define EXE_BGEZ        5'b00001              // instruct bgez   opcode         
`define EXE_BGEZAL      5'b10001              // instruct bgezal opcode
`define EXE_BGTZ        6'b000111             // instruct bgtz   opcode
`define EXE_BLEZ        6'b000110             // instruct blez   opcode
`define EXE_BLTZ        5'b00000              // instruct bltz   opcode
`define EXE_BLTZAL      5'b10000              // instruct bltzal opcode     
`define EXE_BNE         6'b000101             // instruct bne    opcode  

`define EXE_LB          6'b100000             // instruct lb     opcode
`define EXE_LBU         6'b100100             // instruct lbu    opcode
`define EXE_LH          6'b100001             // instruct lh     opcode
`define EXE_LHU         6'b100101             // instruct lhu    opcode
`define EXE_LW          6'b100011             // instruct lw     opcode
`define EXE_LWL         6'b100010             // instruct lwl    opcode  
`define EXE_LWR         6'b100110             // instruct lwr    opcode 
`define EXE_SB          6'b101000             // instruct sb     opcode  
`define EXE_SH          6'b101001             // instruct sh     opcode  
`define EXE_SW          6'b101011             // instruct sw     opcode  
`define EXE_SWL         6'b101010             // instruct swl    opcode 
`define EXE_SWR         6'b101110             // instruct swr    opcode

`define EXE_LL          6'b110000             // instruct ll     opcode
`define EXE_SC          6'b111000             // instruct sc     opcode

`define EXE_SYSCALL     6'b001100             // instruct syscall opcode 
`define EXE_TEQ         6'b110100             // instruct teq     opcode 
`define EXE_TEQI        5'b01100              // instruct teqi    opcode
`define EXE_TGE         6'b110000             // instruct tge     opcode 
`define EXE_TGEI        5'b01000              // instruct tgei    opcode
`define EXE_TGEIU       5'b01001              // instruct tgeiu   opcode
`define EXE_TGEU        6'b110001             // instruct tgeu    opcode 
`define EXE_TLT         6'b110010             // instruct tlt     opcode 
`define EXE_TLTI        5'b01010              // instruct tlti    opcode
`define EXE_TLTIU       5'b01011              // instruct tltiu   opcode
`define EXE_TLTU        6'b110011             // instruct tltu    opcode 
`define EXE_TNE         6'b110110             // instruct tne     opcode 
`define EXE_TNEI        5'b01110              // instruct tnei    opcode 

`define EXE_ERET        32'b0100_0010_0000_0000_0000_0000_0001_1000 // instruct eret 

`define EXE_AND_OP      8'b00100100           // alu 's 8 bit nop  opcode
`define EXE_OR_OP       8'b00100101           // alu 's 8 bit or   opcode
`define EXE_XOR_OP      8'b00100110           // alu 's 8 bit xor  opcode
`define EXE_NOR_OP      8'b00100111           // alu 's 8 bit nor  opcode
`define EXE_ANDI_OP     8'b00001100           // alu 's 8 bit andi opcode
`define EXE_ORI_OP      8'b00001101           // alu 's 8 bit ori  opcode
`define EXE_XORI_OP     8'b00001110           // alu 's 8 bit xori opcode
`define EXE_LUI_OP      8'b00001111           // alu 's 8 bit lui  opcode
`define EXE_NOP_OP      8'b00000000           // alu 's 8 bit nop  opcode

`define EXE_SLL_OP      8'b01000000           // alu 's 8 bit sll  opcode
`define EXE_SLLV_OP     8'b00000100           // alu 's 8 bit sllv opcode
`define EXE_SRL_OP      8'b01000010           // alu 's 8 bit sra  opcode
`define EXE_SRLV_OP     8'b00000110           // alu 's 8 bit srlv opcode
`define EXE_SRA_OP      8'b00000011           // alu 's 8 bit sra  opcode
`define EXE_SRAV_OP     8'b00000111           // alu 's 8 bit srav opcode

`define EXE_SYNC_OP     8'b01001111           // alu 's 8 bit sync opcode
`define EXE_PREF_OP     8'b00110011           // alu 's 8 bit pref opcode

`define EXE_MOVZ_OP     8'b01001010           // alu 's 8 bit movz opcode
`define EXE_MOVN_OP     8'b01001011           // alu 's 8 bit movn opcode
`define EXE_MFHI_OP     8'b00010000           // alu 's 8 bit mfhi opcode
`define EXE_MTHI_OP     8'b00010001           // alu 's 8 bit mthi opcode
`define EXE_MFLO_OP     8'b00010010           // alu 's 8 bit mflo opcode
`define EXE_MTLO_OP     8'b00010011           // alu 's 8 bit mtlo opcode

`define EXE_SLT_OP      8'b00101010           // alu 's 8 bit slt   opcode           
`define EXE_SLTU_OP     8'b00101011           // alu 's 8 bit sltu  opcode 
`define EXE_SLTI_OP     8'b00001010           // alu 's 8 bit slti  opcode 
`define EXE_SLTIU_OP    8'b00001011           // alu 's 8 bit sltiu opcode
`define EXE_ADD_OP      8'b01100000           // alu 's 8 bit add   opcode 
`define EXE_ADDU_OP     8'b01100001           // alu 's 8 bit addu  opcode 
`define EXE_SUB_OP      8'b00100010           // alu 's 8 bit sub   opcode
`define EXE_SUBU_OP     8'b00100011           // alu 's 8 bit subu  opcode  
`define EXE_ADDI_OP     8'b00001000           // alu 's 8 bit addi  opcode   
`define EXE_ADDIU_OP    8'b00001001           // alu 's 8 bit addiu opcode 
`define EXE_CLZ_OP      8'b00100000           // alu 's 8 bit clz   opcode  
`define EXE_CLO_OP      8'b00100001           // alu 's 8 bit clo   opcode
`define EXE_MULT_OP     8'b00011000           // alu 's 8 bit mult  opcode
`define EXE_MULTU_OP    8'b00011001           // alu 's 8 bit multu opcode
`define EXE_MUL_OP      8'b00000010           // alu 's 8 bit mul   opcode

`define EXE_MADD_OP     8'b10000000           // alu 's 8 bit madd  opcode
`define EXE_MADDU_OP    8'b01000001           // alu 's 8 bit maddu opcode
`define EXE_MSUB_OP     8'b01000100           // alu 's 8 bit msub  opcode
`define EXE_MSUBU_OP    8'b00000101           // alu 's 8 bit msubu opcode

`define EXE_DIV_OP      8'b00011010           // alu 's 8 bit div   opcode
`define EXE_DIVU_OP     8'b00011011           // alu 's 8 bit divu  opcode

`define EXE_JR_OP       8'b01001000           // alu 's 8 bit jr    opcode
`define EXE_JALR_OP     8'b01001001           // alu 's 8 bit jalr  opcode
`define EXE_J_OP        8'b10000010           // alu 's 8 bit j     opcode
`define EXE_JAL_OP      8'b01000011           // alu 's 8 bit jal   opcode
`define EXE_BEQ_OP      8'b10000100           // alu 's 8 bit beq   opcode
`define EXE_BGTZ_OP     8'b01000111           // alu 's 8 bit bgtz  opcode
`define EXE_BLEZ_OP     8'b01000110           // alu 's 8 bit blez  opcode    
`define EXE_BNE_OP      8'b01000101           // alu 's 8 bit bne   opcode  
`define EXE_BGEZ_OP     8'b00000001           // alu 's 8 bit bgez  opcode          
`define EXE_BGEZAL_OP   8'b01010001           // alu 's 8 bit bgezal opcode
`define EXE_BLTZ_OP     8'b11000000           // alu 's 8 bit bltz  opcode
`define EXE_BLTZAL_OP   8'b01010000           // alu 's 8 bit bltzal opcode

`define EXE_LB_OP       8'b10100000           // alu 's 8 bit lb     opcode
`define EXE_LBU_OP      8'b01100100           // alu 's 8 bit lbu    opcode
`define EXE_LH_OP       8'b10100001           // alu 's 8 bit lh     opcode
`define EXE_LHU_OP      8'b01100101           // alu 's 8 bit lhu    opcode
`define EXE_LW_OP       8'b01100011           // alu 's 8 bit lw     opcode
`define EXE_LWL_OP      8'b01100010           // alu 's 8 bit lwl    opcode  
`define EXE_LWR_OP      8'b10100110           // alu 's 8 bit lwr    opcode 
`define EXE_SB_OP       8'b00101000           // alu 's 8 bit sb     opcode  
`define EXE_SH_OP       8'b00101001           // alu 's 8 bit sh     opcode  
`define EXE_SW_OP       8'b01101011           // alu 's 8 bit sw     opcode  
`define EXE_SWL_OP      8'b00101010           // alu 's 8 bit swl    opcode 
`define EXE_SWR_OP      8'b00101110           // alu 's 8 bit swr    opcode

`define EXE_LL_OP       8'b00110000           // alu 's 8 bit ll     opcode
`define EXE_SC_OP       8'b00111000           // alu 's 8 bit sc     opcode

`define EXE_MFC0_OP     8'b01011101           // alu 's 8 bit mfc0   opcode
`define EXE_MTC0_OP     8'b11100000           // alu 's 8 bit mtc0   opcode

`define EXE_SYSCALL_OP  8'b01001100           // alu 's 8 bit syscall opcode 
`define EXE_TEQ_OP      8'b00110100           // alu 's 8 bit teq     opcode 
`define EXE_TEQI_OP     8'b10001100           // alu 's 8 bit teqi    opcode
`define EXE_TGE_OP      8'b01110000           // alu 's 8 bit tge     opcode 
`define EXE_TGEI_OP     8'b10001000           // alu 's 8 bit tgei    opcode
`define EXE_TGEIU_OP    8'b10001001           // alu 's 8 bit tgeiu   opcode
`define EXE_TGEU_OP     8'b00110001           // alu 's 8 bit tgeu    opcode 
`define EXE_TLT_OP      8'b00110010           // alu 's 8 bit tlt     opcode 
`define EXE_TLTI_OP     8'b10001010           // alu 's 8 bit tlti    opcode
`define EXE_TLTIU_OP    8'b10001011           // alu 's 8 bit tltiu   opcode
`define EXE_TLTU_OP     8'b01110011           // alu 's 8 bit tltu    opcode 
`define EXE_TNE_OP      8'b00110110           // alu 's 8 bit tne     opcode 
`define EXE_TNEI_OP     8'b01001110           // alu 's 8 bit tnei    opcode 

`define EXE_ERET_OP     8'b11111111           // alu 's 8 bit eret    opcode

`define EXE_RES_NOP             3'b000  
`define EXE_RES_LOGIC           3'b001 
`define EXE_RES_SHIFT           3'b010
`define EXE_RES_MOVE            3'b011
`define EXE_RES_ARITHMETIC      3'b100
`define EXE_RES_MUL             3'b101
`define EXE_RES_LOAD_STORE      3'b110
`define EXE_RES_JUMP_BRANCH     3'b111  

/***************** instruct relatived defination  end  ********************/

/***************** instruct rom relatived defination begin ********************/
`define N_INST_ADDR     32                   // instruct rom 's address width
`define N_INST_DATA     32                   // instruct rom 's data width
`define N_MEM_ADDR      32                   // data ram 's address width
`define N_MEM_DATA      32                   // data ram 's data width
`define NUM_INST_MEM    131072               // instruct rom 's space in real --> 128 KB
`define N_INST_ADDR_USE 17                   // instruct rom 's address width in use  [less than N_INST_ADDR]
`define NUM_DATA_MEM    131072               // data ram 's space in real --> 128 KB
/***************** instruct rom relatived defination  end  ********************/

/***************** general registers relatived defination begin ********************/
`define N_REG_ADDR      5                    // registers address 's width
`define N_REG           32                   // register 's width
`define N_DOUBLE_REG    64                   // double register 's width
`define NUM_REG         32                   // total number of registers
`define NOP_REG_ADDR    5'b00000             // nop register 's address [index]
/***************** general registers relatived defination  end  ********************/

/***************** cp relatived defination begin ********************/
`define CP0_REG_COUNT   5'b01001
`define CP0_REG_COMPARE 5'b01011 
`define CP0_REG_STATUS  5'b01100 
`define CP0_REG_CAUSE   5'b01101 
`define CP0_REG_EPC     5'b01110 
`define CP0_REG_PRID    5'b01111 
`define CP0_REG_CONFIG  5'b10000 

`define CP0_REG_N_ADDR   5
`define CP0_REG_N_INT    6
/***************** cp relatived defination  end  ********************/