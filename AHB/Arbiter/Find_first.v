`timescale 1ns / 1ps


module Find_first(
    
    Indices,
    logic_arr,
    index_out,
    valid_out
    
);
    
    parameter N       = 4;
    parameter DATAW   = 2;
    parameter REVERSE = 0;
    localparam LOGN   = $clog2(N);
    
    input  [N*DATAW-1 : 0]        Indices;
    input  [N-1 : 0]              logic_arr;
    output [DATAW-1 : 0]          index_out;
    output                        valid_out;
    
    localparam TL = (1 << LOGN) - 1;
    localparam TN = (1 << (LOGN+1)) - 1;
    
    wire [TN-1 : 0] logic_value;
    wire [DATAW-1 : 0]index_value[TN-1 : 0];
    
    
    /*for(genvar i = 0 ; i < TL ; i = i + 1)
    begin
    
        assign logic_value[i] = 0;
        assign index_value[i] = {DATAW{1'b0}};
    
    end
    */
    
    for(genvar i = 0 ; i < N ; i = i + 1)
    begin
    
        assign logic_value[TL + i] = REVERSE ? logic_arr[N-1-i] : logic_arr[i];
        assign index_value[TL + i] = REVERSE ? Indices[((N-i)*DATAW-1) : (N-i-1)*DATAW] : Indices[((i+1)*DATAW-1) : (i)*DATAW];
    
    end
    
    for(genvar i = TL + N ; i < TN ; i = i + 1)
    begin
        
        assign logic_value[i] = 0;
        assign index_value[i] = {DATAW{1'b0}};
    
    end
    
    
    for(genvar j = 0 ; j < LOGN ; j = j + 1)begin
        for(genvar i = 0 ; i < (2**j) ; i = i + 1)begin
            
            assign logic_value[2**j-1+i] = logic_value[2**(j+1)-1+2*i] | logic_value[2**(j+1)-1+2*i+1];
            assign index_value[2**j-1+i] = logic_value[2**(j+1)-1+2*i] ? index_value[2**(j+1)-1+2*i] : index_value[2**(j+1)-1+2*i+1];
        
        end
    end
    
    
    assign valid_out = logic_value[0];
    assign index_out = index_value[0];
    
endmodule
