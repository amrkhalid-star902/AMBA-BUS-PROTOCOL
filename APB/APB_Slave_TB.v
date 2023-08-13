`timescale 1ns / 1ps



module APB_Slave_TB();

    reg clk;
    reg reset;
    reg psel , penable , pwrite;
    wire pready;
    
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 16;
    
    wire [DATA_WIDTH-1 : 0] read_data; 
    reg [DATA_WIDTH-1 : 0] write_data;
    reg [ADDR_WIDTH-1 : 0] addr;
    
    always@(*)
    begin
        
        #5;
        clk <= ~clk;
    
    end
    
    initial
    begin
    
        clk = 0;
        reset = 0;
        psel = 0;
        penable = 0;
        pwrite = 0;
        write_data = 0;
        addr = 0;
        
        #50;
        
        reset = 1;
        psel = 1;
        penable = 1;
        pwrite = 1;
        write_data = 16'hffff;
        addr = 0;
        
        #50;
        
        reset = 1;
        psel = 1;
        penable = 1;
        pwrite = 0;
        addr = 0;
        
        #50;
        
        reset = 1;
        psel = 1;
        penable = 1;
        pwrite = 1;
        write_data = 16'heacf;
        addr = 1;
        
        #50;
        
        reset = 1;
        psel = 1;
        penable = 1;
        pwrite = 0;
        addr = 1;
        
        #50;
        
        reset = 0;
        
        
        
    
    end


    APB_Slave slave(
    
        .PCLK(clk),
        .PRESET(reset),
        .PSEL(psel),
        .PENABLE(penable),
        .PWRITE(pwrite),
        .PADDR(addr),
        .PWDATA(write_data),
        .PRDATA(read_data),
        .PREADY(pready)
    
   );
    
    
    defparam slave.ADDR_WIDTH = ADDR_WIDTH;
    defparam slave.DATA_WIDTH = DATA_WIDTH;


endmodule
