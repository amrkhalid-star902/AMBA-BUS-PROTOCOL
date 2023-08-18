`timescale 1ns / 1ps

module AHB_Top(
    
    hclk,
    hresetn,
    enable,
    datain1,
    datain2,
    addr,
    wr,
    slave_sel,
    dout
    
);

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter SLAVES_NUM = 4;
    
    input hclk , hresetn , enable;
    input [DATA_WIDTH-1 : 0] datain1 , datain2;
    input [ADDR_WIDTH-1 : 0] addr;
    input wr;
    input [$clog2(SLAVES_NUM)-1 : 0] slave_sel;
    output [DATA_WIDTH-1 : 0] dout;
    
    //master wires
    
    wire [$clog2(SLAVES_NUM)-1 : 0] sel;
    wire [ADDR_WIDTH-1 : 0] haddr;
    wire hwrite;
    wire [2 : 0] hsize;
    wire [2 : 0] hburst;
    wire [3 : 0] hprot;
    wire [1 : 0] htrans;
    wire lock;
    wire hready;
    wire [DATA_WIDTH-1 : 0] hwdata;
    wire hreadyout;
    wire hresp;
    wire [DATA_WIDTH-1 : 0] hrdata;
    
    //slave1
    wire [DATA_WIDTH-1 : 0] rdata1;
    wire hreadyout_1;
    wire hresp_1;
    
    //slave2
    wire [DATA_WIDTH-1 : 0] rdata2;
    wire hreadyout_2;
    wire hresp_2;
    
    //slave3
    wire [DATA_WIDTH-1 : 0] rdata3;
    wire hreadyout_3;
    wire hresp_3;
    
    //slave4
    wire [DATA_WIDTH-1 : 0] rdata4;
    wire hreadyout_4;
    wire hresp_4;
    
    //decoder signals
    wire hsel_1;
    wire hsel_2;
    wire hsel_3;
    wire hsel_4;
    
    AHB_Master ahb_master(
        
        .HCLK(hclk),
        .HRESETn(hresetn),
        .enable(enable),
        .data1(datain1),
        .data2(datain2),
        .addr(addr),
        .wr(wr),
        .hreadyout(hreadyout),
        .hresp(hresp),
        .HRDATA(hrdata),
        .slave_sel(slave_sel),
        
        .HSEL(sel),
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
    
    
    //slave1
    AHB_Slave slave1(
    
        .HCLK(hclk),
        .HRESETn(hresetn),
        .HSEL(hsel_1),
        .HADDR(haddr),
        .HWRITE(hwrite),
        .HSIZE(hsize),
        .HBURST(hburst),
        .HPROT(hprot),
        .HTRANS(htrans),
        .HLOCK(lock),
        .HREADY(hready),
        .HWDATA(hwdata),
        .HREADYOUT(hreadyout_1),
        .HRESP(hresp_1),
        .HRDATA(rdata1)
        
    );
    
    //slave2
    AHB_Slave slave2(
    
        .HCLK(hclk),
        .HRESETn(hresetn),
        .HSEL(hsel_2),
        .HADDR(haddr),
        .HWRITE(hwrite),
        .HSIZE(hsize),
        .HBURST(hburst),
        .HPROT(hprot),
        .HTRANS(htrans),
        .HLOCK(lock),
        .HREADY(hready),
        .HWDATA(hwdata),
        .HREADYOUT(hreadyout_2),
        .HRESP(hresp_2),
        .HRDATA(rdata2)
        
    );



    //slave3
    AHB_Slave slave3(
    
        .HCLK(hclk),
        .HRESETn(hresetn),
        .HSEL(hsel_3),
        .HADDR(haddr),
        .HWRITE(hwrite),
        .HSIZE(hsize),
        .HBURST(hburst),
        .HPROT(hprot),
        .HTRANS(htrans),
        .HLOCK(lock),
        .HREADY(hready),
        .HWDATA(hwdata),
        .HREADYOUT(hreadyout_3),
        .HRESP(hresp_3),
        .HRDATA(rdata3)
        
    );
    
    //slave4
    AHB_Slave slave4(
    
        .HCLK(hclk),
        .HRESETn(hresetn),
        .HSEL(hsel_4),
        .HADDR(haddr),
        .HWRITE(hwrite),
        .HSIZE(hsize),
        .HBURST(hburst),
        .HPROT(hprot),
        .HTRANS(htrans),
        .HLOCK(lock),
        .HREADY(hready),
        .HWDATA(hwdata),
        .HREADYOUT(hreadyout_4),
        .HRESP(hresp_4),
        .HRDATA(rdata4)
        
    );
    
    Decoder decoder(
        .sel(sel),
        .hsel_1(hsel_1),
        .hsel_2(hsel_2),
        .hsel_3(hsel_3),
        .hsel_4(hsel_4)
        
    );
    
    
    Multiplexor multiplexor(
        
        .hrdata_1(rdata1),
        .hrdata_2(rdata2),
        .hrdata_3(rdata3),
        .hrdata_4(rdata4),
        .hreadyout_1(hreadyout_1),
        .hreadyout_2(hreadyout_2),
        .hreadyout_3(hreadyout_3),
        .hreadyout_4(hreadyout_4),
        .hresp_1(hresp_1),
        .hresp_2(hresp_2),
        .hresp_3(hresp_3),
        .hresp_4(hresp_4),
        .sel(sel),
        .hrdata(hrdata),
        .hreadyout(hreadyout),
        .hresp(hresp)
        
    );
    
endmodule
