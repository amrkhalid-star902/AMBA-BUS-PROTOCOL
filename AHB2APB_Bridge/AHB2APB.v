`timescale 1ns / 1ps



module AHB2APB(
    
    HCLK,
    HRESETn,
    HSEL,
    HADDR,
    HWRITE,
    HREADY,
    HWDATA,
    HRDATA,
    PCLK,
    PRESETn,
    RW,
    ABP_ADDR,
    APB_WDATA,
    APB_RDATA,
    TRANSFER,
    SEL    
    
);

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter SLAVES_NUM = 4;
    
    //Inputs from AHB master
    input HCLK , HRESETn;
    input [$clog2(SLAVES_NUM)-1 : 0] HSEL;
    input [ADDR_WIDTH-1 : 0] HADDR;
    input HWRITE , HREADY;
    input [DATA_WIDTH-1 : 0] HWDATA;
    input [DATA_WIDTH-1 : 0] HRDATA;
    
    //Outputs to APB master
    output PCLK , PRESETn , RW;
    output [ADDR_WIDTH-1 : 0] ABP_ADDR;
    output [DATA_WIDTH-1 : 0] APB_WDATA;
    output [DATA_WIDTH-1 : 0] APB_RDATA;
    output TRANSFER;
    output [$clog2(SLAVES_NUM)-1 : 0] SEL;
    
    //Internal signals
    reg rw_reg;
    reg [ADDR_WIDTH-1 : 0] abp_addr;
    reg [DATA_WIDTH-1 : 0] abp_write_data;
    reg [DATA_WIDTH-1 : 0] abp_read_data;
    reg transfer_reg;
    reg [$clog2(SLAVES_NUM)-1 : 0] apb_sel;
    
    //output signals assigment
    assign PCLK      = HCLK;
    assign PRESETn   = HRESETn;
    assign RW        = rw_reg;
    assign ABP_ADDR  = abp_addr;
    assign APB_WDATA = abp_write_data;
    assign APB_RDATA = abp_read_data;
    assign TRANSFER  = transfer_reg;
    assign SEL       = apb_sel;
    
    always@(*)
    begin
    
        if(!HRESETn)
        begin
        
            rw_reg   = 1'b0;
            abp_addr = {ADDR_WIDTH{1'b0}};
            abp_write_data = {DATA_WIDTH{1'b0}};
            abp_read_data  = {DATA_WIDTH{1'b0}};
            apb_sel        = {$clog2(SLAVES_NUM){1'b0}};
            transfer_reg   = 1'b0;
        
        end
        
        else
        begin
            
            if(HREADY)
            begin
                
                abp_addr     = HADDR;
                apb_sel      = HSEL;
                transfer_reg = 1'b1;
                
                if(HWRITE)
                begin
                
                    rw_reg         = 1'b1;
                    abp_write_data = HWDATA;
                
                end
                else
                begin
                
                   rw_reg         = 1'b0;
                   abp_read_data  = HRDATA;
                    
                end
            
            
            end
        
        end
    
    end
    
    
endmodule
