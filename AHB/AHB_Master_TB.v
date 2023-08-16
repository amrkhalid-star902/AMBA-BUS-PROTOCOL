`timescale 1ns / 1ps


module AHB_Master_TB();

    reg clk;
    reg reset;
    reg enable;
    reg [31 : 0] d1;
    reg [31 : 0] d2;
    reg [31 : 0] addr;
    reg wr;
    reg hreadyout;
    reg hresp;
    reg [31 : 0] rdata;
    reg [1 : 0]  sel;
    
    wire [1 : 0] hsel;
    wire [31 : 0] haddr;
    wire hwrite;
    wire [2 : 0] hsize;
    wire [2 : 0] hburst;
    wire [3 : 0] hprot;
    wire [1 : 0] htrans;
    wire lock;
    wire hready;
    wire [31 : 0] hwdata;
    wire [31 : 0] dout;
    
    AHB_Master ahb_master(
        
        .HCLK(clk),
        .HRESETn(reset),
        .enable(enable),
        .data1(d1),
        .data2(d2),
        .addr(addr),
        .wr(wr),
        .hreadyout(hreadyout),
        .hresp(hresp),
        .HRDATA(rdata),
        .slave_sel(sel),
        
        .HSEL(hsel),
        .HADDR(haddr),
        .HWRITE(hwrite),
        .HSIZE(hsize),
        .HBURST(hburst),
        .HPROT(hprot),
        .HTRANS(htrans),
        .HLOCK(lock),
        .HREADY(hready),
        .HWDATA(hwdata),
        .DOUT(dout)
        
    );
    
    always@(*)
    begin
    
        #5;
        clk <= ~clk;
    
    end

    
    initial
    begin
    
        clk    = 0;
        reset  = 0;
        enable = 0;
        d1 = 32'd0;
        d2 = 32'd0;
        addr = 32'd0;
        wr   = 0;
        hreadyout = 0;
        hresp     = 0;
        rdata     = 32'd0;
        sel       = 0;
        
        #20;
        
        reset  = 1;
        enable = 1;
        d1 = 32'd345;
        d2 = 32'd567;
        addr = 32'habcdef12;
        wr   = 1;
        hreadyout = 1;
        hresp     = 1;
        rdata     = 32'd12345678;
        sel       = 0;
        
        #50;
        wr = 0;
        
        #50;
        
        reset  = 1;
        enable = 1;
        d1 = 32'd10;
        d2 = 32'd10;
        addr = 32'heac123df;
        wr   = 1;
        hreadyout = 1;
        hresp     = 1;
        rdata     = 32'haaaaaaaa;
        sel       = 2;
        
        #50;
        wr = 0;
        
    end
    
endmodule
