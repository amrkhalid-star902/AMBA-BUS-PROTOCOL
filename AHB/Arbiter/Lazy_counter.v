`timescale 1ns / 1ps



module Lazy_counter(
    
    In_logic,
    Idx,
    valid 
    
);

    parameter N       = 4;
    parameter MODE    = 0;
    parameter REVERSE = 0;
    
    localparam LOGN   = $clog2(N);
    
    input  [N-1 : 0]    In_logic;
    output [LOGN-1 : 0] Idx;
    output              valid;
    
    wire [N*LOGN-1 : 0] indices;
    
    for (genvar i = 0; i < N; i = i + 1) 
    begin
    
        assign indices[((i+1)*LOGN-1) : (i)*LOGN] = MODE ? N-1-i : i;
    
    end
    
    Find_first find_first(
        
        .Indices(indices),
        .logic_arr(In_logic),
        .index_out(Idx),
        .valid_out(valid)
        
    );
    
    defparam find_first.N       = N;
    defparam find_first.DATAW   = LOGN;
    defparam find_first.REVERSE = REVERSE;

endmodule
