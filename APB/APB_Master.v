`timescale 1ns / 1ps



module APB_Master(

    PCLK,
    PRESETn,
    RW,
    transfer,
    PREADY,
    apb_address,
    apb_write_data,
    apb_read_data_out,
    SEL,
    PSEL,
    PENABLE,
    PADDR,
    PWRITE,
    PWDATA,
    PRDATA,
    PSLVERR
    
);



    //Default signal width
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 16;
    parameter SLAVES_NUM = 4;
    
    input PCLK , PRESETn , RW , transfer , PREADY;
    input [ADDR_WIDTH-1 : 0]  apb_address;
    input [DATA_WIDTH-1 : 0]  apb_write_data;
    input [DATA_WIDTH-1 : 0]  apb_read_data_out;
    input [$clog2(SLAVES_NUM)-1 : 0]  SEL;
    
    output [SLAVES_NUM-1 : 0] PSEL;
    output reg PENABLE;
    output reg [ADDR_WIDTH-1 : 0] PADDR;
    output reg PWRITE;
    output reg [DATA_WIDTH-1 : 0] PWDATA , PRDATA;
    output PSLVERR;
    
    reg [1:0] state , next_state;
    
    localparam IDLE   = 0;
    localparam SETUP  = 1;
    localparam ACCESS = 2;
    
    reg invalid_setup_error,setup_error,
        invalid_read_paddr,invalid_write_paddr,
        invalid_write_data ;
        
    
    assign PSEL    = (1 << SEL);
    assign PSLVERR = invalid_setup_error;
    
    always@(posedge PCLK)
    begin
    
        if(!PRESETn)
        begin
        
            state <= IDLE;
            
        end
        
        else
        begin
        
            state <= next_state;
        
        end
    
    end
    
    
    always@(state , transfer , PREADY)
    begin
    
        if(!PRESETn)
        begin
    
            state <= IDLE;
             
        end
        
        else
        begin
        
            PWRITE = RW;
            case(state)
            
                IDLE: begin
                
                    PENABLE = 1'b0;
                    
                    if(!transfer)
                    begin
                    
                        next_state = IDLE;
                    
                    end
                    
                    else
                    begin
                    
                        next_state <= SETUP;
                    
                    end
                
                end
                
                SETUP: begin
                
                    PENABLE = 1'b0;
                    
                    if(!RW)
                    begin
                    
                        PADDR = apb_address;
                        
                    end
                    
                    else
                    begin
                        
                        PADDR  = apb_address;
                        PWDATA = apb_write_data;
                    
                    end
                    
                    if(transfer && !PSLVERR)
                    begin
                        
                        next_state = ACCESS;
                    
                    end
                    
                    else
                    begin
                    
                        next_state = IDLE;
                        
                    end
                
                end
                
                ACCESS: begin
                    
                    //find whether at least ther is one selected element
                    if(|PSEL)
                    begin
                    
                        PENABLE = 1'b1;
                        if(transfer && !PSLVERR)
                        begin
                        
                            if(PREADY)
                            begin
                            
                                if(RW)
                                begin
                                    //Return to setup and wait for another transaction
                                    next_state = SETUP;
                                
                                end
                                
                                else
                                begin
                                    
                                    //Return to setup and wait for another transaction
                                    next_state = SETUP;
                                    PRDATA     = apb_read_data_out; 
                                    
                                end                            
                            
                            end
                            
                            else
                            begin
                            
                                next_state = ACCESS;
                            
                            end
                        
                        end
                        
                        else
                        begin
                            
                            //No transfer detected
                            next_state = IDLE;
                        
                        end
                        
                    end
                    
                    else
                    begin
                        
                        
                        next_state = IDLE;
                    
                    end
                    
                end
                
                default: begin
                    
                    next_state = IDLE;
                
                end
            
            endcase
        
        end
    
    
    end
      
      
    //Error checking logic
    always@(*)
    begin
        
        if(!PRESETn)
        begin
        
            setup_error = 0;
            invalid_read_paddr  = 0;
            invalid_write_paddr = 0;
            invalid_write_data  = 0;            
        
        end
        
        else
        begin
        
            if(state == IDLE && next_state == ACCESS)
            begin
            
                setup_error = 1'b1;
            
            end
            
            else
            begin
            
                setup_error = 1'b0;
            
            end
            
            if((apb_write_data === {DATA_WIDTH{1'dx}})&& RW && (state == SETUP || state == ACCESS))
            begin
            
                
                invalid_write_data = 1'b1;
            
            end
            
            else
            begin
            
                invalid_write_data = 1'b0;
            
            end
            
            if((apb_address === {DATA_WIDTH{1'dx}})&& !RW && (state == SETUP || state == ACCESS))
            begin
                
                invalid_read_paddr = 1'b1;
            
            end
            
            else
            begin
            
                invalid_read_paddr = 1'b0;
            
            end
            
            if((apb_address === {DATA_WIDTH{1'dx}})&& RW && (state == SETUP || state == ACCESS))
            begin
            
                invalid_write_paddr = 1'b1;
            
            end
            
            else
            begin
            
                 invalid_write_paddr = 1'b0;
            
            end
            
            if(state == SETUP)
            begin
            
                if(PWRITE)
                begin
                
                    if(PADDR == apb_address && PWDATA == apb_write_data)
                    begin
                        
                        setup_error = 1'b0;
                    
                    end
                    
                    else
                    begin
                    
                        setup_error = 1'b1;    
                    
                    end
                    
                end
                else
                begin
                
                    if(PADDR == apb_address)
                    begin
                    
                        setup_error = 1'b0;
                    
                    end
                    
                    else 
                    begin
                    
                        setup_error = 1'b1;
                    
                    end
                
                end
            
            end
            
            else
            begin
            
                setup_error = 1'b0;
            
            end
            
            
        end
        
        invalid_setup_error = setup_error ||  invalid_read_paddr || invalid_write_data || invalid_write_paddr;
    
    end


endmodule
