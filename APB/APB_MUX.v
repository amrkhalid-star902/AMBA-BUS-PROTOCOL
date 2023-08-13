`timescale 1ns / 1ps



module APB_MUX(
    
    sel,
    input_data1,
    input_data2,
    input_data3,
    input_data4,
    ready1,
    ready2,
    ready3,
    ready4,
    out_data,
    ready
    
    
);
    
    parameter DATA_WIDTH = 8;
    
    input [1 : 0] sel;
    input [DATA_WIDTH-1 : 0] input_data1 , input_data2 , input_data3 , input_data4;
    input ready1 , ready2 , ready3 , ready4;
    output reg [DATA_WIDTH-1 : 0] out_data;
    output reg ready;
    
    always@(*)
    begin
    
        
        case(sel)
        
            2'b00: begin
            
                out_data = input_data1;
                ready = ready1;
                
            end
            
            2'b01: begin
            
                out_data = input_data2;
                ready = ready2;
                
            end
            
            2'b10: begin
            
                out_data = input_data3;
                ready = ready3;
                
            end
            
            2'b11: begin
            
                out_data = input_data4;
                ready = ready4;
                
            end
        
        endcase
    
    end
    
endmodule
