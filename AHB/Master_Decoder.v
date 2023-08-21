`timescale 1ns / 1ps



module Master_Decoder(
    
    grant1,
    grant2,
    grant3,
    grant4,
    
    hrdata,
    hreadyout,
    hresp,
    
    hrdata1,
    hrdata2,
    hrdata3,
    hrdata4,
    
    hreadyout1,
    hreadyout2,
    hreadyout3,
    hreadyout4,
    
    hresp1,
    hresp2,
    hresp3,
    hresp4
    
);

    parameter DATA_WIDTH = 32;
    
    input grant1 , grant2 , grant3 , grant4;
    input [DATA_WIDTH-1 : 0] hrdata;
    input hreadyout;
    input hresp;
    
    output reg [DATA_WIDTH-1 : 0] hrdata1 , hrdata2 , hrdata3 , hrdata4;
    output reg hreadyout1 , hreadyout2 , hreadyout3 , hreadyout4;
    output reg hresp1 , hresp2 , hresp3 , hresp4;
    
    always@(*)
    begin
    
        case({grant4 , grant3 , grant2 , grant1})
        
            4'd1: begin
            
                hrdata1    = hrdata;
                hrdata2    = 0;
                hrdata3    = 0;
                hrdata4    = 0;
                
                hreadyout1 = hreadyout;
                hreadyout2 = 0;
                hreadyout3 = 0;
                hreadyout4 = 0;
                
                hresp1     = hresp;
                hresp2     = 0;
                hresp3     = 0;
                hresp4     = 0;
            
            end
            
            4'd2: begin
            
                hrdata1    = 0;
                hrdata2    = hrdata;
                hrdata3    = 0;
                hrdata4    = 0;
                
                hreadyout1 = 0;
                hreadyout2 = hreadyout;
                hreadyout3 = 0;
                hreadyout4 = 0;
                
                hresp1     = 0;
                hresp2     = hresp;
                hresp3     = 0;
                hresp4     = 0;
            
            end
            
            4'd4: begin
            
                hrdata1    = 0;
                hrdata2    = 0;
                hrdata3    = hrdata;
                hrdata4    = 0;
                
                hreadyout1 = 0;
                hreadyout2 = 0;
                hreadyout3 = hreadyout;
                hreadyout4 = 0;
                
                hresp1     = 0;
                hresp2     = 0;
                hresp3     = hresp;
                hresp4     = 0;
            
            end
            
            4'd8: begin
            
                hrdata1    = 0;
                hrdata2    = 0;
                hrdata3    = 0;
                hrdata4    = hrdata;
                
                hreadyout1 = 0;
                hreadyout2 = 0;
                hreadyout3 = 0;
                hreadyout4 = hreadyout;
                
                hresp1     = 0;
                hresp2     = 0;
                hresp3     = 0;
                hresp4     = hresp;
            
            end
            
            default: begin
            
                hrdata1    = 0;
                hrdata2    = 0;
                hrdata3    = 0;
                hrdata4    = 0;
                
                hreadyout1 = 0;
                hreadyout2 = 0;
                hreadyout3 = 0;
                hreadyout4 = 0;
                
                hresp1     = 0;
                hresp2     = 0;
                hresp3     = 0;
                hresp4     = 0;
            
            end
        
        endcase
    
    end
    
endmodule
