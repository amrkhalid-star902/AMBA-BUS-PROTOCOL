`timescale 1ns / 1ps


module Fixed_Arbiter(

    requests,
    grant_idx,
    grant_onehot,
    grant_valid

);

    parameter N       = 4;
    parameter MODE    = 0;
    parameter REVERSE = 0;
    
    
    localparam LOGN   = $clog2(N);
    
    input  [N-1 : 0]    requests;
    output [LOGN-1 : 0] grant_idx;
    output [N-1 : 0]    grant_onehot;
    output              grant_valid;
    
    wire [LOGN-1 : 0] index;
    reg  [N-1 : 0]    onehot;
    
    Lazy_counter lzc(
        
        .In_logic(requests),
        .Idx(index),
        .valid(grant_valid) 
        
    );
    
    defparam lzc.N       = N;
    defparam lzc.MODE    = MODE;
    defparam lzc.REVERSE = REVERSE;
        
    assign grant_idx     = index;
    assign grant_onehot  = onehot;
    
    always@(index)
    begin
    
        onehot        = {N{1'b0}};
        onehot[index] = 1'b1;
    
    end
    
    
endmodule
