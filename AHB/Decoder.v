`timescale 1ns / 1ps


module Decoder(
    sel,
    hsel_1,
    hsel_2,
    hsel_3,
    hsel_4
    
);
    
    input [1 : 0] sel;
    output reg hsel_1;
    output reg hsel_2;
    output reg hsel_3;
    output reg hsel_4;
    
    always@(*)
    begin
    
        case(sel)
        
            2'b00: begin
            
                hsel_1 = 1;
                hsel_2 = 0;
                hsel_3 = 0;
                hsel_4 = 0;
            
            end
            
            2'b01: begin
            
                hsel_1 = 0;
                hsel_2 = 1;
                hsel_3 = 0;
                hsel_4 = 0;
            
            end
            
            2'b10: begin
            
                hsel_1 = 0;
                hsel_2 = 0;
                hsel_3 = 1;
                hsel_4 = 0;
            
            end
            
            2'b11: begin
            
                hsel_1 = 0;
                hsel_2 = 0;
                hsel_3 = 0;
                hsel_4 = 1;
            
            end
            
            default: begin
            
                hsel_1 = 0;
                hsel_2 = 0;
                hsel_3 = 0;
                hsel_4 = 0;
            
            end
        
        endcase
    
    end
    
    
endmodule
