/**************************************
@ filename    : ex.sv
@ author      : yyrwkk
@ create time : 2024/08/14 17:16:43
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module ex (
    input  logic [`N_ALU_SEL-1:0]      i_alu_sel           ,
    input  logic [`N_ALU_OP-1:0]       i_alu_op            ,
    input  logic [`N_REG-1:0]          i_alu_reg_0         ,
    input  logic [`N_REG-1:0]          i_alu_reg_1         ,
       
    input  logic                       i_alu_reg_wen       ,
    input  logic [`N_REG_ADDR-1:0]     i_alu_reg_waddr     ,
           
    output logic                       o_alu_reg_wen       ,
    output logic [`N_REG_ADDR-1:0]     o_alu_reg_waddr     ,
    output logic [`N_REG-1:0]          o_alu_reg_wdata     ,
       
    input  logic [`N_REG-1:0]          i_hi                ,
    input  logic [`N_REG-1:0]          i_lo                ,
       
    input  logic                       i_mem_hilo_wen      ,
    input  logic [`N_REG-1:0]          i_mem_hi            ,
    input  logic [`N_REG-1:0]          i_mem_lo            ,
    input  logic                       i_wb_hilo_wen       ,
    input  logic [`N_REG-1:0]          i_wb_hi             ,
    input  logic [`N_REG-1:0]          i_wb_lo             ,
       
    output logic                       o_hilo_wen          ,
    output logic [`N_REG-1:0]          o_hi                ,
    output logic [`N_REG-1:0]          o_lo                ,
    output logic                       o_streq             ,
    
    input  logic [`N_REG*2-1:0]        i_hilo_temp         ,
    input  logic [1:0]                 i_cnt               ,
    
    output logic [`N_REG*2-1:0]        o_hilo_temp         ,
    output logic [1:0]                 o_cnt               ,
    
    output logic                       o_divsigned         ,
    output logic [`N_REG-1:0]          o_dividend          ,
    output logic [`N_REG-1:0]          o_divisor           ,
    output logic                       o_divstart          ,
    
    input  logic [`N_REG-1:0]          i_quotient          ,
    input  logic [`N_REG-1:0]          i_remainder         ,
    input  logic                       i_div_done          ,
    input  logic                       i_div_ready         ,
    
    input  logic                       i_delayslot_vld     ,
    input  logic [`N_INST_ADDR-1:0]    i_link_addr         ,
    
    input  logic [`N_INST_DATA-1:0]    i_inst              ,
    output logic [`N_ALU_OP-1:0]       o_alu_op            ,
    output logic [`N_MEM_ADDR-1:0]     o_mem_addr          ,
    output logic [`N_MEM_DATA-1:0]     o_mem_data          ,

    input  logic                       i_mem_cp0_reg_wen   ,
    input  logic [`CP0_REG_N_ADDR-1:0] i_mem_cp0_reg_waddr ,
    input  logic [`N_REG-1:0]          i_mem_cp0_reg_data  ,

    input  logic                       i_wb_cp0_reg_wen    ,
    input  logic [`CP0_REG_N_ADDR-1:0] i_wb_cp0_reg_waddr  ,
    input  logic [`N_REG-1:0]          i_wb_cp0_reg_data   ,

    input  logic [`N_REG-1:0]          i_cp0_reg_data      ,
    output logic [`CP0_REG_N_ADDR-1:0] o_cp0_reg_raddr     ,

    output logic                       o_cp0_reg_wen       ,
    output logic [`CP0_REG_N_ADDR-1:0] o_cp0_reg_waddr     ,
    output logic [`N_REG-1:0]          o_cp0_reg_wdata     ,

    input  logic [31:0]                i_except_type       ,
    input  logic [`N_INST_ADDR-1:0]    i_curr_inst_addr    ,

    output logic [31:0]                o_except_type       ,
    output logic [`N_INST_ADDR-1:0]    o_curr_inst_addr    ,
    output logic                       o_delayslot_vld    
);

logic [`N_REG-1:0]     logic_out      ;  // save logic operator result
logic [`N_REG-1:0]     shift_out      ;  // save shift operator result
logic [`N_REG-1:0]     move_out       ;  // save move  operator result
logic [`N_REG-1:0]     arith_out      ;  // save arith operator result
logic [(2*`N_REG)-1:0] m_add_sub_out  ;  // save madd, msub, maddu, msubu operator result
logic                  m_add_sub_streq;  // streq from madd, msub, maddu, msubu 
     
logic [`N_REG-1:0]     hi         ;  // the lastest value of hi
logic [`N_REG-1:0]     lo         ;  // the lastest value of lo
     
logic                  ov_sum     ;  // overflow
logic                  op0_lt_op1 ;  // whether op0 <  op1
logic [`N_REG-1:0]     op1_comp   ;  // op1's complement
logic [`N_REG-1:0]     op0_rever  ;  // op0's reversal
logic [`N_REG-1:0]     sum_result ;  // add result
logic [`N_REG-1:0]     mult_op0   ;  // mult op data0
logic [`N_REG-1:0]     mult_op1   ;  // mult op data1
 
logic [(2*`N_REG)-1:0] hilo_temp  ;  // mult -> temp result
logic [(2*`N_REG)-1:0] mul_result ;  // mul result

logic                  div_streq  ;

logic                  trap_assert;  // whether is trap exception
logic                  ov_assert  ;  // whether is overflow exception 

// ex stage 's exception is id stage 's exception + trap、overflow
// 10 bit : trap exception
// 11 bit : overflow exception
assign o_except_type = { i_except_type[31:12],ov_assert,trap_assert,i_except_type[9:8],8'h00};
// whether is in delayslot
assign o_delayslot_vld = i_delayslot_vld;

// curr stage 's addr
assign o_curr_inst_addr = i_curr_inst_addr;

// alu_op -> calc div
always_comb begin
    div_streq   = `NO_STOP;
    o_divsigned = 'b0;
    o_dividend  = 'b0;
    o_divisor   = 'b0;
    o_divstart  = 'b0;
    case( i_alu_op )
    `EXE_DIV_OP: begin
        if( i_div_ready == 1'b1 ) begin
            o_dividend = i_alu_reg_0;
            o_divisor  = i_alu_reg_1;
            o_divsigned= 1'b1;  
            o_divstart = 1'b1;
            div_streq  = `STOP;
        end else if( i_div_done == 1'b1 ) begin
            o_dividend = 'b0;
            o_divisor  = 'b0;
            o_divsigned= 1'b0;  
            o_divstart = 1'b0;
            div_streq  = `NO_STOP;
        end else begin
            o_dividend = 'b0;
            o_divisor  = 'b0;
            o_divsigned= 1'b0;  
            o_divstart = 1'b0;
            div_streq  = `STOP;
        end
    end
    `EXE_DIVU_OP: begin  
        if( i_div_ready == 1'b1 ) begin
            o_dividend = i_alu_reg_0;
            o_divisor  = i_alu_reg_1;
            o_divsigned= 1'b0;  
            o_divstart = 1'b1;
            div_streq  = `STOP;
        end else if( i_div_done == 1'b1 ) begin
            o_dividend = 'b0;
            o_divisor  = 'b0;
            o_divsigned= 1'b0;  
            o_divstart = 1'b0;
            div_streq  = `NO_STOP;
        end else begin
            o_dividend = 'b0;
            o_divisor  = 'b0;
            o_divsigned= 1'b0;  
            o_divstart = 1'b0;
            div_streq  = `STOP;
        end
    end
    default: begin
    end
    endcase
end

// if sub or ( signed lt )、signed trap, op1_comp is op1's complement,
// else op1_comp is op1
assign op1_comp = ( (i_alu_op == `EXE_SUB_OP) || (i_alu_op == `EXE_SUBU_OP) || (i_alu_op == `EXE_SLT_OP) 
                    || ( i_alu_op == `EXE_TLT_OP ) || (i_alu_op == `EXE_TLTI_OP) || (i_alu_op == `EXE_TGE_OP) || (i_alu_op == `EXE_TGEI_OP)) 
                  ?
                  (( ~i_alu_reg_1 ) + 1'b1 ) 
                  :
                  i_alu_reg_1;
// 1. add, op1_comp <-- op1
// 2. sub, op1_comp <-- op1's complement
// 3. signed lt, op1_comp, signed trap <-- op1's complement, result_sum is also the sub result, conduct result whether less than 0 -> (op0 < op1 ?)
assign sum_result = i_alu_reg_0 + op1_comp;
// overflow,( add,addi )、sub need to judge whether overflow:
// 1. op0 is positive and op1 is also positive , but the result is negative.
// 2. op0 is negative and op1 is also negative , but the result is positive.
assign ov_sum = ((!i_alu_reg_0[31]) && (!op1_comp[31]) && sum_result[31])
                ||
                (i_alu_reg_0[31] && op1_comp[31] && (!sum_result[31]));
// op0 less than op1
// 1. compare、trap: signed operator
//    1.1 op0 is negative, op1 is positive
//    1.2 op0 is positive, op1 is positive , op0 - op1 < 0
//    1.3 op0 is negitive, op1 is positive , op0 - op1 < 0
// 2. unsigned operator -> use " < " operator in direct
assign op0_lt_op1 = ( (i_alu_op == `EXE_SLT_OP) || (i_alu_op == `EXE_TLT_OP) || ( i_alu_op == `EXE_TLTI_OP) || ( i_alu_op == `EXE_TGE_OP) || (i_alu_op == `EXE_TGEI_OP)) 
                    ?
                    ( (i_alu_reg_0[31] && (!i_alu_reg_1[31])) || ((!i_alu_reg_0[31]) && (!i_alu_reg_1[31]) && sum_result[31] ) || (i_alu_reg_0[31] && i_alu_reg_1[31] && sum_result[31]))
                    :
                    (i_alu_reg_0 < i_alu_reg_1);
// op0_rever
assign op0_rever = ~i_alu_reg_0;       

// whether trap assert
always_comb begin 
    trap_assert = `TRAP_NOT_ASSERT;
    case( i_alu_op )
    // teq, teqi 
    `EXE_TEQ_OP,`EXE_TEQI_OP: begin 
        if( i_alu_reg_0 == i_alu_reg_1) begin 
            trap_assert = `TRAP_ASSERT;
        end
    end
    // tge, tgei, tgeiu, tgeu
    `EXE_TGE_OP,`EXE_TGEI_OP,`EXE_TGEIU_OP,`EXE_TGEU_OP: begin 
        if( ~op0_lt_op1 ) begin 
            trap_assert = `TRAP_ASSERT;
        end
    end
    // tlt, tlti, tltiu, tltu 
    `EXE_TLT_OP,`EXE_TLTI_OP, `EXE_TLTIU_OP,`EXE_TLTU_OP: begin 
        if( op0_lt_op1 ) begin
            trap_assert = `TRAP_ASSERT;
        end
    end
    // tne, tnei
    `EXE_TNE_OP,`EXE_TNEI_OP: begin 
        if( i_alu_reg_0 != i_alu_reg_1) begin 
            trap_assert = `TRAP_ASSERT;
        end
    end
    default: begin 
    
    end
    endcase
end

// get the lastest value of hi,lo
always_comb begin
    if(i_mem_hilo_wen == `WRITE_ENABLE) begin
        {hi,lo} = {i_mem_hi,i_mem_lo};
    end else if( i_wb_hilo_wen == `WRITE_ENABLE) begin
        {hi,lo} = {i_wb_hi,i_wb_lo};
    end else begin
        {hi,lo} = {i_hi,i_lo};
    end
end         

// alu_op -> calc arithmetic 
always_comb begin
    case( i_alu_op )
    `EXE_SLT_OP,`EXE_SLTU_OP: begin
        arith_out = op0_lt_op1;
    end
    `EXE_ADD_OP,`EXE_ADDU_OP,`EXE_ADDI_OP,`EXE_ADDIU_OP: begin
        arith_out = sum_result;
    end
    `EXE_SUB_OP,`EXE_SUBU_OP: begin
        arith_out = sum_result;
    end
    `EXE_CLZ_OP: begin
        arith_out = i_alu_reg_0[31] ? 0 : i_alu_reg_0[30]?1 :i_alu_reg_0[29]?2 :i_alu_reg_0[28]?3 :i_alu_reg_0[27]?4 :i_alu_reg_0[26]?5 :
                    i_alu_reg_0[25] ? 6 : i_alu_reg_0[24]?7 :i_alu_reg_0[23]?8 :i_alu_reg_0[22]?9 :i_alu_reg_0[21]?10:i_alu_reg_0[20]?11:
                    i_alu_reg_0[19] ? 12: i_alu_reg_0[18]?13:i_alu_reg_0[17]?14:i_alu_reg_0[16]?15:i_alu_reg_0[15]?16:i_alu_reg_0[14]?17:
                    i_alu_reg_0[13] ? 18: i_alu_reg_0[12]?19:i_alu_reg_0[11]?20:i_alu_reg_0[10]?21:i_alu_reg_0[9] ?22:i_alu_reg_0[8] ?23:
                    i_alu_reg_0[7]  ? 24: i_alu_reg_0[6] ?25:i_alu_reg_0[5] ?26:i_alu_reg_0[4] ?27:i_alu_reg_0[3] ?28:i_alu_reg_0[2] ?29:
                    i_alu_reg_0[1]  ? 30: i_alu_reg_0[0] ?31:32;
    end
    `EXE_CLO_OP: begin
        arith_out = op0_rever[31] ? 0 : op0_rever[30]?1 :op0_rever[29]?2 :op0_rever[28]?3 :op0_rever[27]?4 :op0_rever[26]?5 :
                    op0_rever[25] ? 6 : op0_rever[24]?7 :op0_rever[23]?8 :op0_rever[22]?9 :op0_rever[21]?10:op0_rever[20]?11:
                    op0_rever[19] ? 12: op0_rever[18]?13:op0_rever[17]?14:op0_rever[16]?15:op0_rever[15]?16:op0_rever[14]?17:
                    op0_rever[13] ? 18: op0_rever[12]?19:op0_rever[11]?20:op0_rever[10]?21:op0_rever[9] ?22:op0_rever[8] ?23:
                    op0_rever[7]  ? 24: op0_rever[6] ?25:op0_rever[5] ?26:op0_rever[4] ?27:op0_rever[3] ?28:op0_rever[2] ?29:
                    op0_rever[1]  ? 30: op0_rever[0] ?31:32;
    end
    default: begin
        arith_out = 'b0;
    end
    endcase
end

// mul -> signed and mult_op0 is negative, madd, msub is signed mul
assign mult_op0 = ( (( i_alu_op == `EXE_MUL_OP ) || ( i_alu_op == `EXE_MULT_OP ) || ( i_alu_op == `EXE_MADD_OP )|| ( i_alu_op == `EXE_MSUB_OP ) ) && i_alu_reg_0[31])
                  ? 
                  ( ~i_alu_reg_0 + 1'b1 )
                  :
                  i_alu_reg_0;
// mul -> signed and mult_op1 is negative, madd, msub is signed mul
assign mult_op1 = ( (( i_alu_op == `EXE_MUL_OP ) || ( i_alu_op == `EXE_MULT_OP )|| ( i_alu_op == `EXE_MADD_OP )|| ( i_alu_op == `EXE_MSUB_OP ) ) && i_alu_reg_1[31]) 
                  ? 
                  ( ~i_alu_reg_1 + 1'b1 )
                  : 
                  i_alu_reg_1;
// temp mul result
assign hilo_temp = mult_op0 * mult_op1;
// correct temp mul result -> mul_result
// 1. signed mult、mul, madd, msub, correct temp mul result:
//   1.1 mul_op0, mul_op1 is one negative and one positive, need to get complelment -> mul_result
//   1.2 mul_op0, mul_op1 is both negative or both positive, mul_temp -> mul_result
// 2. unsigned multu, mul_temp , maddu, msubu -> mul_result 
always_comb begin
    if( ( i_alu_op == `EXE_MULT_OP ) || (i_alu_op == `EXE_MUL_OP )|| (i_alu_op == `EXE_MADD_OP )|| (i_alu_op == `EXE_MSUB_OP )) begin
        if( i_alu_reg_0[31] ^ i_alu_reg_1[31] == 1'b1 ) begin
            mul_result = ~hilo_temp + 1'b1;
        end else begin
            mul_result = hilo_temp;
        end
    end else begin
        mul_result = hilo_temp;
    end
end

// alu_op -> calc madd, maddu, msub, msubu
always_comb begin
    case( i_alu_op )
    `EXE_MADD_OP,`EXE_MADDU_OP: begin
        if( i_cnt == 2'b00) begin             // madd, maddu  -> first clk
            o_hilo_temp    = mul_result;
            o_cnt          = 2'b01;
            m_add_sub_out  = 'b0;
            m_add_sub_streq= `STOP;
        end else if( i_cnt == 2'b01 ) begin   // madd, maddu  -> second clk
            o_hilo_temp    = 'b0;
            o_cnt          = 2'b10;           // meaningful, but may be unused...
            m_add_sub_out  = i_hilo_temp + {hi,lo};
            m_add_sub_streq= `NO_STOP;
        end else begin
            o_hilo_temp    = 'b0;
            o_cnt          = 'b0;
            m_add_sub_out  = 'b0;
            m_add_sub_streq= `NO_STOP;
        end
    end
    `EXE_MSUB_OP, `EXE_MSUBU_OP: begin
        if( i_cnt == 2'b00) begin      
            o_hilo_temp    = ~mul_result + 1'b1;
            o_cnt          = 2'b01;
            m_add_sub_out  = 'b0;
            m_add_sub_streq= `STOP;
        end else if( i_cnt == 2'b01 ) begin
            o_hilo_temp    = 'b0;
            o_cnt          = 2'b10;            // meaningful, but may be unused...
            m_add_sub_out  = i_hilo_temp + {hi,lo};
            m_add_sub_streq= `NO_STOP;
        end else begin
            o_hilo_temp    = 'b0;
            o_cnt          = 'b0;
            m_add_sub_out  = 'b0;
            m_add_sub_streq= `NO_STOP;
        end
    end
    default: begin
        o_hilo_temp    = 'b0;
        o_cnt          = 'b0;
        m_add_sub_out  = 'b0;
        m_add_sub_streq= `NO_STOP;
    end
    endcase
end

// pause pipeline
always_comb begin
    o_streq = m_add_sub_streq | div_streq;
end

assign o_cp0_reg_raddr = i_inst[15:11];
// alu_op -> calc move
always_comb begin
    move_out = 'b0;
    case ( i_alu_op )
    `EXE_MFHI_OP: begin
        move_out = hi;
    end
    `EXE_MFLO_OP: begin
        move_out = lo;
    end
    `EXE_MOVZ_OP: begin
        move_out = i_alu_reg_0;
    end
    `EXE_MOVN_OP: begin
        move_out = i_alu_reg_0;                                     //same as MOVZ 
    end
    `EXE_MFC0_OP: begin
        if( i_mem_cp0_reg_wen == `WRITE_ENABLE && i_mem_cp0_reg_waddr == i_inst[15:11] ) begin
            move_out = i_mem_cp0_reg_data;
        end else if( i_wb_cp0_reg_wen == `WRITE_ENABLE && i_wb_cp0_reg_waddr == i_inst[15:11] ) begin
            move_out = i_wb_cp0_reg_data;
        end else begin
            move_out = i_cp0_reg_data;
        end
    end
    default: begin
    end
    endcase
end

// alu_op -> calc logic 
always_comb begin
    case ( i_alu_op ) 
    `EXE_OR_OP: begin
        logic_out = i_alu_reg_0 | i_alu_reg_1;
    end
    `EXE_AND_OP: begin
        logic_out = i_alu_reg_0 & i_alu_reg_1;
    end
    `EXE_NOR_OP: begin
        logic_out = ~(i_alu_reg_0 | i_alu_reg_1);
    end
    `EXE_XOR_OP: begin
        logic_out = i_alu_reg_0 ^ i_alu_reg_1;
    end
    default: begin
        logic_out = 'b0;
    end
    endcase
end

// alu_op -> calc shift
always_comb begin
    case( i_alu_op )
    `EXE_SLL_OP: begin
        shift_out = i_alu_reg_1 << i_alu_reg_0[4:0];
    end
    `EXE_SRL_OP: begin
        shift_out = i_alu_reg_1 >> i_alu_reg_0[4:0];
    end
    `EXE_SRA_OP: begin
        shift_out = ( {32{i_alu_reg_1[31]}} << (6'd32-{1'b0,i_alu_reg_0[4:0]})) | (i_alu_reg_1 >> i_alu_reg_0[4:0]);
    end 
    default: begin
        shift_out = 'b0;
    end
    endcase
end

assign o_alu_reg_waddr = i_alu_reg_waddr;

always_comb begin
    if( ( ( i_alu_op == `EXE_ADD_OP ) || ( i_alu_op == `EXE_ADDI_OP) || ( i_alu_op == `EXE_SUB_OP )) && ( ov_sum == 1'b1 )) begin
        o_alu_reg_wen = `WRITE_DISABLE;
        ov_assert = `TRAP_ASSERT; // overflow exception 
    end else begin
        o_alu_reg_wen   =  i_alu_reg_wen;
        ov_assert = `TRAP_NOT_ASSERT; // overflow not exception 
    end
end

// alu_sel -> output
always_comb begin
    case(i_alu_sel) 
    `EXE_RES_LOGIC: begin
        o_alu_reg_wdata = logic_out ;
    end
    `EXE_RES_SHIFT: begin
        o_alu_reg_wdata = shift_out ;
    end
    `EXE_RES_MOVE: begin
        o_alu_reg_wdata = move_out;
    end
    `EXE_RES_ARITHMETIC: begin
        o_alu_reg_wdata = arith_out;
    end
    `EXE_RES_MUL: begin
        o_alu_reg_wdata = mul_result[31:0];
    end
    `EXE_RES_JUMP_BRANCH: begin
        o_alu_reg_wdata = i_link_addr;
    end
    default: begin
        o_alu_reg_wdata = 'b0;
    end
    endcase
end

// o_hilo_wen、o_hi、o_lo
always_comb begin
    if( (( i_alu_op == `EXE_DIV_OP ) || ( i_alu_op == `EXE_DIVU_OP )) && i_div_done ) begin
        o_hilo_wen = `WRITE_ENABLE;
        o_hi       = i_remainder;
        o_lo       = i_quotient;
    end else if( (( i_alu_op == `EXE_MSUB_OP ) || ( i_alu_op == `EXE_MSUBU_OP )) && ( i_cnt == 2'b01 )) begin
        o_hilo_wen = `WRITE_ENABLE;
        o_hi       = m_add_sub_out[63:32];
        o_lo       = m_add_sub_out[31:0];
    end else if( (( i_alu_op == `EXE_MADD_OP ) || ( i_alu_op == `EXE_MADDU_OP )) && ( i_cnt == 2'b01 )) begin
        o_hilo_wen = `WRITE_ENABLE;
        o_hi       = m_add_sub_out[63:32];
        o_lo       = m_add_sub_out[31:0];
    end else if( (i_alu_op == `EXE_MULT_OP ) || (i_alu_op == `EXE_MULTU_OP) ) begin
        o_hilo_wen = `WRITE_ENABLE;
        o_hi       = mul_result[63:32];
        o_lo       = mul_result[31:0];
    end else if( i_alu_op == `EXE_MTHI_OP ) begin
        o_hilo_wen = `WRITE_ENABLE;
        o_hi       = i_alu_reg_0;
        o_lo       = lo;
    end else if( i_alu_op == `EXE_MTLO_OP ) begin
        o_hilo_wen = `WRITE_ENABLE;
        o_hi       = hi;
        o_lo       = i_alu_reg_0;
    end else begin
        o_hilo_wen = `WRITE_DISABLE;
        o_hi       = hi;
        o_lo       = lo;
    end
end

always_comb begin
    if( i_alu_op == `EXE_MTC0_OP ) begin // mtc0 instruction
        o_cp0_reg_waddr = i_inst[15:11];
        o_cp0_reg_wen   = `WRITE_ENABLE;
        o_cp0_reg_wdata = i_alu_reg_0;
    end else begin
        o_cp0_reg_waddr = 'b0;
        o_cp0_reg_wen   = `WRITE_DISABLE;
        o_cp0_reg_wdata = 'b0;
    end
end

// alu op transer to mem stage to get load/store 's sub type
assign o_alu_op = i_alu_op;
// mem 's addr
// i_alu_reg_0 -> base GPR 's value
// i_inst[15:0] -> offset
assign o_mem_addr = i_alu_reg_0 + {{16{i_inst[15]}},i_inst[15:0]};
// mem 's data, or lwl,lwr 's origin value
assign o_mem_data = i_alu_reg_1;

endmodule