`timescale 1ns / 1ps


module APB_Slave(
    
    PCLK,
    PRESET,
    PSEL,
    PENABLE,
    PWRITE,
    PADDR,
    PWDATA,
    PRDATA,
    PREADY
    
);
    
    //Default signal width
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_MEM_SIZE = 16;
    
    input PCLK , PRESET , PSEL;
    input PENABLE , PWRITE;
    input [ADDR_WIDTH-1 : 0]  PADDR;
    input [DATA_WIDTH-1 : 0]  PWDATA;
    output [DATA_WIDTH-1 : 0] PRDATA;
    output reg PREADY;
    
    reg [ADDR_WIDTH-1 : 0] addr;
    reg [DATA_WIDTH-1 : 0] Slave_Mem [SLAVE_MEM_SIZE-1 : 0];
    
    assign PRDATA = Slave_Mem[addr];
    
    always@(posedge PCLK)
    begin
        
        //active low reset
        if(!PRESET)
        begin
        
            PREADY = 1'b0;
        
        end
        
        //There is a read request but the enable signal is low
        else if(PSEL && !PENABLE && !PWRITE) 
        begin
        
            PREADY = 1'b0;
        
        end
        
        //There is a read request and the enable signal is high
        else if(PSEL && PENABLE && !PWRITE) 
        begin
        
            PREADY = 1'b1;
            addr   = PADDR;
        
        end
        
        //There is a write request but the enable signal is low
        else if(PSEL && !PENABLE && PWRITE) 
        begin
        
            PREADY = 1'b0;
        
        end
        
        //There is a write request and the enable signal is high
        else if(PSEL && PENABLE && PWRITE) 
        begin
        
            PREADY = 1'b1;
            Slave_Mem[PADDR] = PWDATA;
            
        end
        
        else
        begin
            
            PREADY = 1'b0;
            
        end
        
    end
    
endmodule
