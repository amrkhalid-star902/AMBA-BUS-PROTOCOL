`timescale 1ns / 1ps



module Master_Multiplexor(

    grant1,
    grant2,
    grant3,
    grant4,
    
    haddr1,
    haddr2,
    haddr3,
    haddr4,
    
    hwrite1,
    hwrite2,
    hwrite3,
    hwrite4,
    
    hsize1,
    hsize2,
    hsize3,
    hsize4,
    
    hburst1,
    hburst2,
    hburst3,
    hburst4,
    
    hprot1,
    hprot2,
    hprot3,
    hprot4,
    
    htrans1,
    htrans2,
    htrans3,
    htrans4,
    
    hlock1,
    hlock2,
    hlock3,
    hlock4,
    
    hready1,
    hready2,
    hready3,
    hready4,
    
    hwdata1,
    hwdata2,
    hwdata3,
    hwdata4,
    
    dout1,
    dout2,
    dout3,
    dout4,
    
    hsel1,
    hsel2,
    hsel3,
    hsel4,
    
    haddr,
    hwrite,
    hsize,
    hburst,
    hprot,
    htrans,
    hlock,
    hready,
    hwdata,
    dout,
    hsel
     
);

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter SLAVES_NUM = 4; 
    
    input grant1 , grant2 , grant3 , grant4;
    input [ADDR_WIDTH-1 : 0] haddr1 , haddr2 , haddr3 , haddr4;
    input hwrite1 , hwrite2 , hwrite3 , hwrite4;
    input wire [2 : 0] hsize1 , hsize2 , hsize3 , hsize4;
    input wire [2 : 0] hburst1 , hburst2 , hburst3 , hburst4;
    input wire [3 : 0] hprot1 , hprot2 , hprot3 , hprot4;
    input wire [1 : 0] htrans1 , htrans2 , htrans3 , htrans4;
    input wire hlock1 , hlock2 , hlock3 , hlock4;
    input wire hready1 , hready2 , hready3 , hready4;
    input wire [DATA_WIDTH-1 : 0] hwdata1 , hwdata2 , hwdata3 , hwdata4;
    input wire [DATA_WIDTH-1 : 0] dout1 , dout2 , dout3 , dout4;
    input wire [$clog2(SLAVES_NUM)-1 : 0] hsel1 , hsel2 , hsel3 , hsel4;
    
    output reg [ADDR_WIDTH-1 : 0] haddr;
    output reg hwrite;
    output reg [2 : 0] hsize;
    output reg [2 : 0] hburst;
    output reg [3 : 0] hprot;
    output reg [1 : 0] htrans;
    output reg hlock;
    output reg hready;
    output reg [DATA_WIDTH-1 : 0] hwdata;
    output reg [DATA_WIDTH-1 : 0] dout;
    output reg [$clog2(SLAVES_NUM)-1 : 0] hsel;
    
    always@(*)
    begin
    
        case({grant4 , grant3 , grant2 , grant1})
        
            4'd1: begin
            
                haddr  = haddr1;
                hwrite = hwrite1;
                hsize  = hsize1;
                hburst = hburst1;
                hprot  = hprot1;
                htrans = htrans1;
                hlock  = hlock1;
                hready = hready1;
                hwdata = hwdata1;
                dout   = dout1;
                hsel   = hsel1;
            
            end
            
            4'd2: begin
            
                haddr  = haddr2;
                hwrite = hwrite2;
                hsize  = hsize2;
                hburst = hburst2;
                hprot  = hprot2;
                htrans = htrans2;
                hlock  = hlock2;
                hready = hready2;
                hwdata = hwdata2;
                dout   = dout2;
                hsel   = hsel2;
                
            end
        
            4'd4: begin
            
                haddr  = haddr3;
                hwrite = hwrite3;
                hsize  = hsize3;
                hburst = hburst3;
                hprot  = hprot3;
                htrans = htrans3;
                hlock  = hlock3;
                hready = hready3;
                hwdata = hwdata3;
                dout   = dout3;
                hsel   = hsel3;
            
            end
            
            4'd8: begin
            
                haddr  = haddr4;
                hwrite = hwrite4;
                hsize  = hsize4;
                hburst = hburst4;
                hprot  = hprot4;
                htrans = htrans4;
                hlock  = hlock4;
                hready = hready4;
                hwdata = hwdata4;
                dout   = dout4;
                hsel   = hsel4;
                
            end
            
            default: begin
            
                haddr  = 0;
                hwrite = 0;
                hsize  = 0;
                hburst = 0;
                hprot  = 0;
                htrans = 0;
                hlock  = 0;
                hready = 0;
                hwdata = 0;
                dout   = 0;
                hsel   = 0;
                
            end
        
        endcase
    
    end
    
endmodule
