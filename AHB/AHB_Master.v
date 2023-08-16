`timescale 1ns / 1ps


module AHB_Master(
    
    HCLK,
    HRESETn,
    enable,
    data1,
    data2,
    addr,
    wr,
    hreadyout,
    hresp,
    HRDATA,
    slave_sel,
    
    HSEL,
    HADDR,
    HWRITE,
    HSIZE,
    HBURST,
    HPROT,
    HTRANS,
    HLOCK,
    HREADY,
    HWDATA,
    DOUT
    
);

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter SLAVES_NUM = 4;
    
    input HCLK , HRESETn , enable;
    input [DATA_WIDTH-1 : 0] data1 , data2;
    input [ADDR_WIDTH-1 : 0] addr;
    input wr , hreadyout , hresp;
    input [DATA_WIDTH-1 : 0] HRDATA;
    input [$clog2(SLAVES_NUM)-1 : 0] slave_sel;
    
    
    output reg [$clog2(SLAVES_NUM)-1 : 0] HSEL;
    output reg [ADDR_WIDTH-1 : 0] HADDR;
    output reg HWRITE;
    output reg [2 : 0] HSIZE;
    output reg [2 : 0] HBURST;
    output reg [3 : 0] HPROT;
    output reg [1 : 0] HTRANS;
    output reg HLOCK;
    output reg HREADY;
    output reg [DATA_WIDTH-1 : 0] HWDATA;
    output reg [DATA_WIDTH-1 : 0] DOUT;
    
    
    //------------------------Some State Machine Definations------------------------//
    reg [1 : 0] state , next_state;
    
    parameter IDLE  = 2'd0;
    parameter EVAL  = 2'd1;
    parameter READ  = 2'd2;
    parameter WRITE = 2'd3;
    
    always@(posedge HCLK , negedge HRESETn)
    begin
    
        if(!HRESETn)
        begin
        
            state <= IDLE;
        
        end
        
        else
        begin
        
            state <= next_state;
        
        end
    
    
    end 
    
    always@(*)
    begin
    
        case(state)
            
            IDLE: begin
            
                if(enable == 1'b1)
                begin
                
                    next_state = EVAL;
                
                end
                
                else
                begin
                
                    next_state = IDLE;
                
                end
            
            end
            
            EVAL: begin
            
                if(wr == 1'b1)
                begin
                
                    next_state = WRITE;
                
                end
                
                else
                begin
                
                    next_state = READ;
                
                end
                
            
            end
            
            READ: begin
            
                if(enable == 1'b1)
                begin
                
                    next_state = EVAL;
                
                end
                
                else
                begin
                
                    next_state = IDLE;
                
                end
            
            end
            
            WRITE: begin
            
                if(enable == 1'b1)
                begin
                
                    next_state = EVAL;
                
                end
                
                else
                begin
                
                    next_state = IDLE;
                
                end
            
            end
            
            default: begin
            
                next_state = IDLE;
            
            end 
        
        endcase
    
    end
    
    always@(posedge HCLK , negedge HRESETn)
    begin
    
        if(!HRESETn)
        begin
        
            HSEL   <= 0;
            HADDR  <= {ADDR_WIDTH{1'b0}};
            HWRITE <= 1'b0;
            HSIZE  <= 3'b0;
            HBURST <= 3'b0;
            HPROT  <= 4'b0;
            HTRANS <= 2'b0;
            HLOCK  <= 1'b0;
            HREADY <= 1'b0;
            HWDATA <= {DATA_WIDTH{1'b0}};
            DOUT   <= {DATA_WIDTH{1'b0}};
        
        end
        
        case(next_state)
        
            IDLE: begin
                
                HSEL   <= slave_sel;
                HADDR  <= addr;
                HWRITE <= HWRITE;
                HBURST <= HBURST;
                HREADY <= 1'b0;
                HWDATA <= HWDATA;
                DOUT   <= DOUT;
            
            end
            
            EVAL: begin
            
                HSEL   <= slave_sel;
                HADDR  <= addr;
                HWRITE <= wr;
                HBURST <= 3'b0;
                HREADY <= 1'b1;
                HWDATA <= data1 + data2;
                DOUT   <= DOUT;
                
            end
            
            READ: begin

                HSEL   <= slave_sel;
                HADDR  <= addr;
                HWRITE <= wr;
                HBURST <= 3'b0;
                HREADY <= 1'b1;
                HWDATA <= HWDATA;
                DOUT   <= HRDATA;
            
            end
            
            WRITE: begin

                HSEL   <= slave_sel;
                HADDR  <= addr;
                HWRITE <= wr;
                HBURST <= 3'b0;
                HREADY <= 1'b1;
                HWDATA <= data1 + data2;
                DOUT   <= DOUT;
            
            end
            
            default: begin

                HSEL   <= slave_sel;
                HADDR  <= HADDR;
                HWRITE <= HWRITE;
                HBURST <= HBURST;
                HREADY <= 1'b0;
                HWDATA <= HWDATA;
                DOUT   <= DOUT;
            
            end
        
        endcase
    
    end
    
    

endmodule

