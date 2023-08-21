`timescale 1ns / 1ps



module AHB_Top(
    
    hclk,
    hresetn,
    enable1,
    enable2,
    enable3,
    enable4,
    datain11,
    datain12,
    datain21,
    datain22,
    datain31,
    datain32,
    datain41,
    datain42,
    addr1,
    addr2,
    addr3,
    addr4,
    wr1,
    wr2,
    wr3,
    wr4,
    slave_sel1,
    slave_sel2,
    slave_sel3,
    slave_sel4,
    grant_idx,
    dout
    
);
    
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter SLAVES_NUM = 4;   
    parameter NUM_REQS   = 4;
    
    input hclk , hresetn;
    input enable1 , enable2 , enable3 , enable4;
    input [DATA_WIDTH-1 : 0] datain11 , datain12;
    input [DATA_WIDTH-1 : 0] datain21 , datain22;
    input [DATA_WIDTH-1 : 0] datain31 , datain32;
    input [DATA_WIDTH-1 : 0] datain41 , datain42;
    input [ADDR_WIDTH-1 : 0] addr1 , addr2 , addr3 , addr4;
    input wr1 , wr2 , wr3 , wr4;
    input [$clog2(SLAVES_NUM)-1 : 0] slave_sel1 , slave_sel2 , slave_sel3 , slave_sel4;
    output [$clog2(NUM_REQS)-1 : 0] grant_idx;
    output [DATA_WIDTH-1 : 0] dout;
    
    //Master1
    
    wire [$clog2(SLAVES_NUM)-1 : 0] sel1;
    wire [ADDR_WIDTH-1 : 0] haddr1;
    wire hwrite1;
    wire [2 : 0] hsize1;
    wire [2 : 0] hburst1;
    wire [3 : 0] hprot1;
    wire [1 : 0] htrans1;
    wire lock1;
    wire hreq1;
    wire hready1;
    wire [DATA_WIDTH-1 : 0] hwdata1;
    wire hreadyout1;
    wire hresp1;
    wire [DATA_WIDTH-1 : 0] hrdata1;
    wire [DATA_WIDTH-1 : 0] dout1;
    
    
    //Master2
    
    wire [$clog2(SLAVES_NUM)-1 : 0] sel2;
    wire [ADDR_WIDTH-1 : 0] haddr2;
    wire hwrite2;
    wire [2 : 0] hsize2;
    wire [2 : 0] hburst2;
    wire [3 : 0] hprot2;
    wire [1 : 0] htrans2;
    wire lock2;
    wire hreq2;
    wire hready2;
    wire [DATA_WIDTH-1 : 0] hwdata2;
    wire hreadyout2;
    wire hresp2;
    wire [DATA_WIDTH-1 : 0] hrdata2;
    wire [DATA_WIDTH-1 : 0] dout2;
    
    
    //Master3
    
    wire [$clog2(SLAVES_NUM)-1 : 0] sel3;
    wire [ADDR_WIDTH-1 : 0] haddr3;
    wire hwrite3;
    wire [2 : 0] hsize3;
    wire [2 : 0] hburst3;
    wire [3 : 0] hprot3;
    wire [1 : 0] htrans3;
    wire lock3;
    wire hreq3;
    wire hready3;
    wire [DATA_WIDTH-1 : 0] hwdata3;
    wire hreadyout3;
    wire hresp3;
    wire [DATA_WIDTH-1 : 0] hrdata3;
    wire [DATA_WIDTH-1 : 0] dout3;
    
    
    //Master4
    
    wire [$clog2(SLAVES_NUM)-1 : 0] sel4;
    wire [ADDR_WIDTH-1 : 0] haddr4;
    wire hwrite4;
    wire [2 : 0] hsize4;
    wire [2 : 0] hburst4;
    wire [3 : 0] hprot4;
    wire [1 : 0] htrans4;
    wire lock4;
    wire hreq4;
    wire hready4;
    wire [DATA_WIDTH-1 : 0] hwdata4;
    wire hreadyout4;
    wire hresp4;
    wire [DATA_WIDTH-1 : 0] hrdata4;
    wire [DATA_WIDTH-1 : 0] dout4;
    
    //Master Mux Signals
    
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
    
    //Arbiter Signals
    wire [NUM_REQS-1 : 0] grant_onehot;
    wire grant_valid;

    
    
    AHB_Master ahb_master1(
        
        .HCLK(hclk),
        .HRESETn(hresetn),
        .enable(enable1),
        .data1(datain11),
        .data2(datain12),
        .addr(addr1),
        .wr(wr1),
        .hreadyout(hreadyout1),
        .hresp(hresp1),
        .HRDATA(hrdata1),
        .slave_sel(slave_sel1),
        
        .HSEL(sel1),
        .HADDR(haddr1),
        .HWRITE(hwrite1),
        .HSIZE(hsize1),
        .HBURST(hburst1),
        .HPROT(hprot1),
        .HTRANS(htrans1),
        .HLOCK(lock1),
        .HREQ(hreq1),
        .HREADY(hready1),
        .HWDATA(hwdata1),
        .DOUT(dout1)
        
    );
    
    
    AHB_Master ahb_master2(
        
        .HCLK(hclk),
        .HRESETn(hresetn),
        .enable(enable2),
        .data1(datain21),
        .data2(datain22),
        .addr(addr2),
        .wr(wr2),
        .hreadyout(hreadyout2),
        .hresp(hresp2),
        .HRDATA(hrdata2),
        .slave_sel(slave_sel2),
        
        .HSEL(sel2),
        .HADDR(haddr2),
        .HWRITE(hwrite2),
        .HSIZE(hsize2),
        .HBURST(hburst2),
        .HPROT(hprot2),
        .HTRANS(htrans2),
        .HLOCK(lock2),
        .HREQ(hreq2),
        .HREADY(hready2),
        .HWDATA(hwdata2),
        .DOUT(dout2)
        
    );
    
    
    AHB_Master ahb_master3(
        
        .HCLK(hclk),
        .HRESETn(hresetn),
        .enable(enable3),
        .data1(datain31),
        .data2(datain32),
        .addr(addr3),
        .wr(wr3),
        .hreadyout(hreadyout3),
        .hresp(hresp3),
        .HRDATA(hrdata3),
        .slave_sel(slave_sel3),
        
        .HSEL(sel3),
        .HADDR(haddr3),
        .HWRITE(hwrite3),
        .HSIZE(hsize3),
        .HBURST(hburst3),
        .HPROT(hprot3),
        .HTRANS(htrans3),
        .HLOCK(lock3),
        .HREQ(hreq3),
        .HREADY(hready3),
        .HWDATA(hwdata3),
        .DOUT(dout3)
        
    );
    
    
    AHB_Master ahb_master4(
        
        .HCLK(hclk),
        .HRESETn(hresetn),
        .enable(enable4),
        .data1(datain41),
        .data2(datain42),
        .addr(addr4),
        .wr(wr4),
        .hreadyout(hreadyout4),
        .hresp(hresp4),
        .HRDATA(hrdata4),
        .slave_sel(slave_sel4),
        
        .HSEL(sel4),
        .HADDR(haddr4),
        .HWRITE(hwrite4),
        .HSIZE(hsize4),
        .HBURST(hburst4),
        .HPROT(hprot4),
        .HTRANS(htrans4),
        .HLOCK(lock4),
        .HREQ(hreq4),
        .HREADY(hready4),
        .HWDATA(hwdata4),
        .DOUT(dout4)
        
    );
    
    
    Fixed_Arbiter FXA(
    
        .requests({hreq4 , hreq3 , hreq2 , hreq1}),
        .grant_idx(grant_idx),
        .grant_onehot(grant_onehot),
        .grant_valid(grant_valid)
    
    );
    
    defparam FXA.N       = NUM_REQS;
    defparam FXA.MODE    = 0;
    defparam FXA.REVERSE = 0;
    
    
    Master_Multiplexor MM(
    
        .grant1(grant_onehot[0]),
        .grant2(grant_onehot[1]),
        .grant3(grant_onehot[2]),
        .grant4(grant_onehot[3]),
        
        .haddr1(haddr1),
        .haddr2(haddr3),
        .haddr3(haddr3),
        .haddr4(haddr4),
        
        .hwrite1(hwrite1),
        .hwrite2(hwrite2),
        .hwrite3(hwrite3),
        .hwrite4(hwrite4),
        
        .hsize1(hsize1),
        .hsize2(hsize2),
        .hsize3(hsize3),
        .hsize4(hsize4),
        
        .hburst1(hburst1),
        .hburst2(hburst2),
        .hburst3(hburst3),
        .hburst4(hburst4),
        
        .hprot1(hprot1),
        .hprot2(hprot2),
        .hprot3(hprot3),
        .hprot4(hprot4),
        
        .htrans1(htrans1),
        .htrans2(htrans2),
        .htrans3(htrans3),
        .htrans4(htrans4),
        
        .hlock1(lock1),
        .hlock2(lock2),
        .hlock3(lock3),
        .hlock4(lock4),
        
        .hready1(hready1),
        .hready2(hready2),
        .hready3(hready3),
        .hready4(hready4),
        
        .hwdata1(hwdata1),
        .hwdata2(hwdata2),
        .hwdata3(hwdata3),
        .hwdata4(hwdata4),
        
        .dout1(dout1),
        .dout2(dout2),
        .dout3(dout3),
        .dout4(dout4),
        
        .hsel1(sel1),
        .hsel2(sel2),
        .hsel3(sel3),
        .hsel4(sel4),
        
        .haddr(haddr),
        .hwrite(hwrite),
        .hsize(hsize),
        .hburst(hburst),
        .hprot(hprot),
        .htrans(htrans),
        .hlock(lock),
        .hready(hready),
        .hwdata(hwdata),
        .dout(dout),
        .hsel(sel) 
        
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
    
    
    Master_Decoder master_decoder(
        
        .grant1(grant_onehot[0]),
        .grant2(grant_onehot[1]),
        .grant3(grant_onehot[2]),
        .grant4(grant_onehot[3]),
        
        .hrdata(hrdata),
        .hreadyout(hreadyout),
        .hresp(hresp),
        
        .hrdata1(hrdata1),
        .hrdata2(hrdata2),
        .hrdata3(hrdata3),
        .hrdata4(hrdata4),
        
        .hreadyout1(hreadyout1),
        .hreadyout2(hreadyout2),
        .hreadyout3(hreadyout3),
        .hreadyout4(hreadyout4),
        
        .hresp1(hresp1),
        .hresp2(hresp2),
        .hresp3(hresp3),
        .hresp4(hresp4)
        
    );
    
    
    
endmodule
