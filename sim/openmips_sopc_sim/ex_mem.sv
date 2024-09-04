/**************************************
@ filename    : ex_mem.sv
@ author      : yyrwkk
@ create time : 2024/08/14 20:10:05
@ version     : v1.0.0
**************************************/
`include "defines.svh"
module ex_mem (
    input  logic                    i_clk         ,
    input  logic                    i_rst_n       ,

    input  logic                    i_ex_wen      ,
    input  logic [`N_REG-1:0]       i_ex_wdata    ,
    input  logic [`N_REG_ADDR-1:0]  i_ex_waddr    ,

    output logic                    o_mem_wen     ,
    output logic [`N_REG-1:0]       o_mem_wdata   ,
    output logic [`N_REG_ADDR-1:0]  o_mem_waddr   ,

    input  logic                    i_ex_hilo_wen ,
    input  logic [`N_REG-1:0]       i_ex_hi       ,
    input  logic [`N_REG-1:0]       i_ex_lo       ,

    output logic                    o_mem_hilo_wen,
    output logic [`N_REG-1:0]       o_mem_hi      ,
    output logic [`N_REG-1:0]       o_mem_lo     
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if( i_rst_n == `RST_ENABLE ) begin
        o_mem_wen  <= `WRITE_DISABLE; 
        o_mem_wdata<= 'b0;
        o_mem_waddr<= `NOP_REG_ADDR;
        o_mem_hilo_wen <= `WRITE_DISABLE;
        o_mem_hi       <= 'b0;
        o_mem_lo       <= 'b0;
    end else begin
        o_mem_wen  <= i_ex_wen;
        o_mem_wdata<= i_ex_wdata;
        o_mem_waddr<= i_ex_waddr;
        o_mem_hilo_wen <= i_ex_hilo_wen;
        o_mem_hi       <= i_ex_hi;
        o_mem_lo       <= i_ex_lo;
    end
end
endmodule