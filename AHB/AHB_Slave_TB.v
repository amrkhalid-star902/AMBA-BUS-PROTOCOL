`timescale 1ns / 1ps


module AHB_Slave_TB();

    reg hclk;
    reg hresetn;
    reg hsel;
    reg [31:0] haddr;
    reg hwrite;
    reg [2:0] hsize;
    reg [2:0] hburst;
    reg [3:0] hprot;
    reg [1:0] htrans;
    reg hmastlock;
    reg hready;
    reg [31:0] hwdata;
    wire hreadyout;
    wire hresp;
    wire [31:0] hrdata;
    
    always@(*)
    begin
        
        #5;
        hclk <= ~hclk;
    
    end
    
    initial begin
       
        hclk = 0;
        hresetn = 1;
        hsel = 0;
        haddr = 32'd0;
        hwrite = 1;
        hburst = 3'b000;
        hprot = 0;
        hsize = 0;
        htrans = 0;
        hmastlock = 0;
        hready = 1;
        hwdata = 32'd0;
          
        #10 hresetn = 0;
        #10 hresetn = 1;
        
        @(posedge hclk)
        hburst = 3'b010;
        hsel = 1'b1;
        hwrite = 1'b1;
        haddr = 32'b0;
        hready = 1'b1;
        @(posedge hclk)
        hwdata = 32'd1;
        @(posedge hclk)
        hwdata = 32'd2;
        @(posedge hclk)
        hwdata = 32'd3;
        @(posedge hclk)
        hwdata = 32'd4;
        @(posedge hclk)
        hwdata = 32'd5;
        @(posedge hclk)
        hwdata = 32'd6;
        @(posedge hclk)
        hsel = 1'b0;
        hwrite = 1'b0;
        hburst = 3'b000;
        
        // read
        @(posedge hclk)
        hburst = 3'b010;
        hsel = 1'b1;
        hwrite = 1'b0;
        haddr = 32'b0;
        hready = 1'b1;
        #100;
        @(posedge hclk)
        hsel = 1'b0;
        @(posedge hclk)
        hsel = 1'b1;
        @(posedge hclk)
        hsel = 1'b0;
        @(posedge hclk)
        hsel = 1'b1;
        @(posedge hclk)
        hsel = 1'b0;
        @(posedge hclk)
        hsel = 1'b1;
        @(posedge hclk)
        hsel = 1'b0;
        @(posedge hclk)
        hsel = 1'b1;
        @(posedge hclk)
        hsel = 1'b0;
        @(posedge hclk)
        hsel = 1'b1;
        @(posedge hclk)
        hsel = 1'b0;
        @(posedge hclk)
        hsel = 1'b1;
        @(posedge hclk)
        hsel = 1'b0;
        hburst = 3'b000;
        
      
    end
    
    AHB_Slave slave(
        
        .HCLK(hclk),
        .HRESETn(hresetn),
        .HSEL(hsel),
        .HADDR(haddr),
        .HWRITE(hwrite),
        .HSIZE(hsize),
        .HBURST(hburst),
        .HPROT(hprot),
        .HTRANS(htrans),
        .HLOCK(),
        .HREADY(hmastlock),
        .HWDATA(hwdata),
        .HREADYOUT(hreadyout),
        .HRESP(hresp),
        .HRDATA(hrdata)
        
    );


endmodule
