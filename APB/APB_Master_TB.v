`timescale 1ns / 1ps



module APB_Master_TB();
    
    reg clk;
    reg reset;
    reg rw;
    reg transfer;
    reg [7:0] address;
    reg [15 : 0] write_data = 0; 
    reg [1 : 0]  sel;
    
    wire [15 : 0] read_data;
    wire pready;
    wire [3 : 0] psel;
    wire penable;
    wire [7 : 0] paddr;
    wire pwrite;
    wire [15 : 0] pwdata;
    wire [15 : 0] prdata;
    wire error;
    
    wire [15 : 0] read_data1;
    wire [15 : 0] read_data2;
    wire [15 : 0] read_data3;
    wire [15 : 0] read_data4;
    
    wire pready1;
    wire pready2;
    wire pready3;
    wire pready4;
    
    APB_MUX mux(
        
        .sel(sel),
        .input_data1(read_data1),
        .input_data2(read_data2),
        .input_data3(read_data3),
        .input_data4(read_data4),
        .ready1(pready1),
        .ready2(pready2),
        .ready3(pready3),
        .ready4(pready4),
        .out_data(read_data),
        .ready(pready)
        
    );
    
    
    
    
    APB_Master apb_master(
    
        .PCLK(clk),
        .PRESETn(reset),
        .RW(rw),
        .transfer(transfer),
        .PREADY(pready),
        .apb_address(address),
        .apb_write_data(write_data),
        .apb_read_data_out(read_data),
        .SEL(sel),
        .PSEL(psel),
        .PENABLE(penable),
        .PADDR(paddr),
        .PWRITE(pwrite),
        .PWDATA(pwdata),
        .PRDATA(prdata),
        .PSLVERR(error)
        
    );
    
    
    APB_Slave slave1(
    
        .PCLK(clk),
        .PRESET(reset),
        .PSEL(psel[0]),
        .PENABLE(penable),
        .PWRITE(pwrite),
        .PADDR(paddr),
        .PWDATA(pwdata),
        .PRDATA(read_data1),
        .PREADY(pready1)
    
   );
   
   
   APB_Slave slave2(
   
       .PCLK(clk),
       .PRESET(reset),
       .PSEL(psel[1]),
       .PENABLE(penable),
       .PWRITE(pwrite),
       .PADDR(paddr),
       .PWDATA(pwdata),
       .PRDATA(read_data2),
       .PREADY(pready2)
   
  );
  
  
   APB_Slave slave3(
  
      .PCLK(clk),
      .PRESET(reset),
      .PSEL(psel[2]),
      .PENABLE(penable),
      .PWRITE(pwrite),
      .PADDR(paddr),
      .PWDATA(pwdata),
      .PRDATA(read_data3),
      .PREADY(pready3)
  
   );
    
   APB_Slave slave4(
 
     .PCLK(clk),
     .PRESET(reset),
     .PSEL(psel[3]),
     .PENABLE(penable),
     .PWRITE(pwrite),
     .PADDR(paddr),
     .PWDATA(pwdata),
     .PRDATA(read_data4),
     .PREADY(pready4)
 
   );
  
  
    always@(*)
    begin
  
        #5;
        clk <= ~clk;
  
    end
    
    initial
    begin
  
        clk   = 0;
        reset = 0;
        rw    = 0;
        transfer = 0;
        address  = 0;
        write_data = 0;
        sel = 0;
        
        #20;
        
        reset = 1;
        rw    = 1;
        transfer = 1;
        address  = 0;
        write_data = 16'hffff;
        sel = 0;
        
        
        #50
        rw = 0;
        transfer = 1;
        address  = 0;
        sel = 0;       
        
        #50;
        reset = 1;
        rw    = 1;
        transfer = 1;
        address  = 1;
        write_data = 16'hfefe;
        sel = 1;
        
        #50;
        rw = 0;
        transfer = 1;
        address  = 1;
        sel = 1;        
        
        
        #50;
        reset = 1;
        rw    = 1;
        transfer = 1;
        address  = 1;
        write_data = 16'habcd;
        sel = 2;
        
        #50;
        rw = 0;
        transfer = 1;
        address  = 1;
        sel = 2;      
        
        
        #50;
        reset = 1;
        rw    = 1;
        transfer = 1;
        address  = 2;
        write_data = 16'haaaa;
        sel = 3;
        
        #50;
        rw = 0;
        transfer = 1;
        address  = 2;
        sel = 3;      

        
    end
    
endmodule
