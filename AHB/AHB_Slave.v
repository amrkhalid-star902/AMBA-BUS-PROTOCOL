`timescale 1ns / 1ps



module AHB_Slave(
    
    HCLK,
    HRESETn,
    HSEL,
    HADDR,
    HWRITE,
    HSIZE,
    HBURST,
    HPROT,
    HTRANS,
    HLOCK,
    HREADY,
    HWDATA,
    HREADYOUT,
    HRESP,
    HRDATA
    
);
    
    
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    
    input HCLK , HRESETn , HSEL;
    input [ADDR_WIDTH-1 : 0] HADDR;
    input HWRITE;
    input [2 : 0] HSIZE;
    input [2 : 0] HBURST;
    input [3 : 0] HPROT;
    input [1 : 0] HTRANS;
    input HLOCK , HREADY;
    input [DATA_WIDTH-1 : 0] HWDATA;
    output reg HREADYOUT;
    output reg HRESP;
    output reg [DATA_WIDTH-1 : 0] HRDATA;
    
    reg [DATA_WIDTH-1 : 0] slave_mem [31 : 0];
    reg [ADDR_WIDTH-1 : 0] waddr;
    reg [ADDR_WIDTH-1 : 0] raddr;
    
    reg [1 : 0] state , next_state;
    
    localparam IDLE  = 2'd0;
    localparam EVAL  = 2'd1;
    localparam WRITE = 2'd2;
    localparam READ  = 2'd3;
    
    //Burst mode flags
    
    reg single_flag;
    reg incr_flag;
    reg wrap4_flag;
    reg incr4_flag;
    reg wrap8_flag;
    reg incr8_flag;
    reg wrap16_flag;
    reg incr16_flag;
    
    wire [7 : 0] mode;
    
    assign mode = {single_flag , incr_flag , wrap4_flag , incr4_flag , wrap8_flag , incr8_flag , wrap16_flag , incr16_flag};
    
    always@(posedge HCLK , negedge HRESETn)
    begin
    
        if(!HRESETn)
        begin
        
            state <= IDLE;
        
        end
        
        else
        begin
        
            state <= next_state;
        
        end
        
    end 
    
    always@(*)
    begin
    
        case(state)
        
            IDLE: begin
            
                single_flag = 1'b0;
                incr_flag   = 1'b0;
                wrap4_flag  = 1'b0;
                incr4_flag  = 1'b0;
                wrap8_flag  = 1'b0;
                incr8_flag  = 1'b0;
                wrap16_flag = 1'b0;
                incr16_flag = 1'b0;
                
                if(HSEL == 1'b1)
                begin
                
                    next_state = EVAL;
                
                end
                
                else
                begin
                
                    next_state = IDLE;
                
                end
            
            end
            
            EVAL: begin
            
                case(HBURST)
                
                    3'b000: begin
                        
                        //Single transfer burst
                        single_flag = 1'b1;
                        incr_flag   = 1'b0;
                        wrap4_flag  = 1'b0;
                        incr4_flag  = 1'b0;
                        wrap8_flag  = 1'b0;
                        incr8_flag  = 1'b0;
                        wrap16_flag = 1'b0;
                        incr16_flag = 1'b0;
                    
                    end
                    
                    3'b001: begin
                        
                        //Incrementing burst of undefined length
                        single_flag = 1'b0;
                        incr_flag   = 1'b1;
                        wrap4_flag  = 1'b0;
                        incr4_flag  = 1'b0;
                        wrap8_flag  = 1'b0;
                        incr8_flag  = 1'b0;
                        wrap16_flag = 1'b0;
                        incr16_flag = 1'b0;
                        
                    end
                    
                    3'b010: begin
                        
                        //4-beat wrapping burst
                        single_flag = 1'b0;
                        incr_flag   = 1'b0;
                        wrap4_flag  = 1'b1;
                        incr4_flag  = 1'b0;
                        wrap8_flag  = 1'b0;
                        incr8_flag  = 1'b0;
                        wrap16_flag = 1'b0;
                        incr16_flag = 1'b0;    
                    
                    end
                    
                    3'b011: begin
                        
                        // 4-beat incrementing burst
                        single_flag = 1'b0;
                        incr_flag   = 1'b0;
                        wrap4_flag  = 1'b0;
                        incr4_flag  = 1'b1;
                        wrap8_flag  = 1'b0;
                        incr8_flag  = 1'b0;
                        wrap16_flag = 1'b0;
                        incr16_flag = 1'b0;  
                    
                    end
                    
                    3'b100: begin
                        
                        // 8-beat wrapping burst
                        single_flag = 1'b0;
                        incr_flag   = 1'b0;
                        wrap4_flag  = 1'b0;
                        incr4_flag  = 1'b0;
                        wrap8_flag  = 1'b1;
                        incr8_flag  = 1'b0;
                        wrap16_flag = 1'b0;
                        incr16_flag = 1'b0;  
                    
                    end
                    
                    3'b101: begin
                        
                        // 8-beat incrementing burst
                        single_flag = 1'b0;
                        incr_flag   = 1'b0;
                        wrap4_flag  = 1'b0;
                        incr4_flag  = 1'b0;
                        wrap8_flag  = 1'b0;
                        incr8_flag  = 1'b1;
                        wrap16_flag = 1'b0;
                        incr16_flag = 1'b0;  
                    
                    end
                    
                    3'b110: begin
                        
                        //16-beat wrapping burst
                        single_flag = 1'b0;
                        incr_flag   = 1'b0;
                        wrap4_flag  = 1'b0;
                        incr4_flag  = 1'b0;
                        wrap8_flag  = 1'b0;
                        incr8_flag  = 1'b0;
                        wrap16_flag = 1'b1;
                        incr16_flag = 1'b0;
                    
                    end
                    
                    3'b111: begin
                    
                        // 16-beat incrementing burst
                        single_flag = 1'b0;
                        incr_flag   = 1'b0;
                        wrap4_flag  = 1'b0;
                        incr4_flag  = 1'b0;
                        wrap8_flag  = 1'b0;
                        incr8_flag  = 1'b0;
                        wrap16_flag = 1'b0;
                        incr16_flag = 1'b1;
                    
                    end
                    
                    default: begin
                        
                        single_flag = 1'b0;
                        incr_flag   = 1'b0;
                        wrap4_flag  = 1'b0;
                        incr4_flag  = 1'b0;
                        wrap8_flag  = 1'b0;
                        incr8_flag  = 1'b0;
                        wrap16_flag = 1'b0;
                        incr16_flag = 1'b0;
                    
                    end
                
                endcase
                
                if((HWRITE == 1'b1) && (HREADY == 1'b1))
                begin
                
                    next_state = WRITE;
                
                end
                
                else if((HWRITE == 1'b0) && (HREADY == 1'b1))
                begin
                
                    next_state = READ;
                
                end 
                
                else
                begin
                
                    next_state = EVAL;
                
                end
            
            end
            
            WRITE: begin
            
                case(HBURST)
                
                    3'b000: begin
                    
                        if(HSEL == 1'b1)
                        begin
                        
                            next_state = EVAL;
                        
                        end
                        
                        else begin
                        
                            next_state = IDLE;
                        
                        end
                    
                    end
                    
                    3'b001: begin
                    
                        next_state = WRITE;
                    
                    end
                    
                    3'b010: begin
                    
                        next_state = WRITE;
                    
                    end
                    
                    3'b011: begin
                    
                        next_state = WRITE;
                    
                    end                    
                    
                    3'b100: begin
                    
                        next_state = WRITE;
                    
                    end
                    
                    3'b101: begin
                    
                        next_state = WRITE;
                    
                    end
                    
                    3'b110: begin
                    
                        next_state = WRITE;
                    
                    end
                    
                    3'b111: begin
                    
                        next_state = WRITE;
                    
                    end
                    
                    default: begin
                    
                        if(HSEL == 1'b1)
                        begin
                        
                            next_state = EVAL;
                        
                        end
                    
                        else begin
                        
                            next_state = IDLE;
                        
                        end
                    
                    end
                
                endcase
            
            end
            
            READ: begin
            
                case(HBURST)
                
                    3'b000: begin
                    
                        if(HSEL == 1'b1)
                        begin
                        
                            next_state = EVAL;
                        
                        end
                        
                        else begin
                        
                            next_state = IDLE;
                        
                        end
                    
                    end
                    
                    3'b001: begin
                    
                        next_state = READ;
                    
                    end
                    
                    3'b010: begin
                    
                        next_state = READ;
                    
                    end
                    
                    3'b011: begin
                    
                        next_state = READ;
                    
                    end                    
                    
                    3'b100: begin
                    
                        next_state = READ;
                    
                    end
                    
                    3'b101: begin
                    
                        next_state = READ;
                    
                    end
                    
                    3'b110: begin
                    
                        next_state = READ;
                    
                    end
                    
                    3'b111: begin
                    
                        next_state = READ;
                    
                    end
                    
                    default: begin
                    
                        if(HSEL == 1'b1)
                        begin
                        
                            next_state = EVAL;
                        
                        end
                    
                        else begin
                        
                            next_state = IDLE;
                        
                        end
                    
                    end
                
                endcase
            
            end
            
            default: begin
            
                next_state = IDLE;
            
            end
        
        endcase
    
    end
    
    always@(posedge HCLK , negedge HRESETn)
    begin
    
        if(!HRESETn)
        begin
        
            HREADYOUT <= 1'b0;
            HRESP     <= 1'b0;
            HRDATA    <= {DATA_WIDTH{1'b0}};
            waddr     <= {ADDR_WIDTH{1'b0}};
            raddr     <= {ADDR_WIDTH{1'b0}};
        
        end
        
        else
        begin
        
            case(next_state)
            
                IDLE: begin
                
                    HREADYOUT <= 1'b0;
                    HRESP     <= 1'b0;
                    HRDATA    <= HRDATA;
                    waddr     <= waddr;
                    raddr     <= raddr;
                
                end
                
                EVAL: begin
                
                    HREADYOUT <= 1'b0;
                    HRESP     <= 1'b0;
                    HRDATA    <= HRDATA;
                    waddr     <= HADDR;
                    raddr     <= HADDR;
                    
                end
                
                WRITE: begin
                
                    case(mode)
                        
                        //Single transfer burst
                        8'd128: begin
                        
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            slave_mem[waddr] <= HWDATA;
                        
                        end
                        
                        8'd64: begin
                            
                            // Incrementing burst of undefined length
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            slave_mem[waddr] <= HWDATA;
                            waddr            <= waddr + 1'b1;
                        
                        end
                        
                        8'd32: begin
                            
                            // 4-beat wrapping burst
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            
                            if(waddr < (HADDR + 2'd3))
                            begin
                            
                                slave_mem[waddr] <= HWDATA;
                                waddr            <= waddr + 1'b1;
                                
                            end
                            
                            else
                            begin
                            
                                slave_mem[waddr] <= HWDATA;
                                waddr            <= HADDR;
                                
                            end
                        
                        end
                        
                        8'd16: begin
                            
                            //4-beat incrementing burst
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            slave_mem[waddr] <= HWDATA;
                            waddr            <= waddr + 1'b1;
                            
                        end
                        
                        8'd8: begin
                            
                            // 8-beat wrapping burst
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            
                            if(waddr < (HADDR + 3'd7))
                            begin
                            
                                slave_mem[waddr] <= HWDATA;
                                waddr            <= waddr + 1'b1;
                                
                            end
                            
                            else
                            begin
                            
                                slave_mem[waddr] <= HWDATA;
                                waddr            <= HADDR;
                                
                            end
                        
                        end
                        
                        8'd4: begin
                            
                            //8-beat incrementing burst
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            slave_mem[waddr] <= HWDATA;
                            waddr            <= waddr + 1'b1;
                            
                        end
                        
                        8'd2: begin
                        
                            // 16-beat wrapping burst
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            
                            if(waddr < (HADDR + 4'd15))
                            begin
                            
                                slave_mem[waddr] <= HWDATA;
                                waddr            <= waddr + 1'b1;
                                
                            end
                            
                            else
                            begin
                            
                                slave_mem[waddr] <= HWDATA;
                                waddr            <= HADDR;
                                
                            end
                        
                        end
                        
                        8'd1: begin
                            
                            //16-beat incrementing burst
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            slave_mem[waddr] <= HWDATA;
                            waddr            <= waddr + 1'b1;
                            
                        end
                        
                        default: begin
                        
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            
                        end
                        
                    endcase
                
                end
                
                READ: begin
                
                    case(mode)
                        
                        //Single transfer burst
                        8'd128: begin
                        
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            HRDATA           <= slave_mem[raddr] ;
                        
                        end
                        
                        8'd64: begin
                            
                            // Incrementing burst of undefined length
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            HRDATA           <= slave_mem[raddr] ;
                            raddr            <= raddr + 1'b1;
                        
                        end
                        
                        8'd32: begin
                            
                            // 4-beat wrapping burst
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            
                            if(raddr < (HADDR + 2'd3))
                            begin
                            
                                HRDATA           <= slave_mem[raddr] ;
                                raddr            <= raddr + 1'b1;
                                
                            end
                            
                            else
                            begin
                            
                                HRDATA           <= slave_mem[raddr] ;
                                raddr            <= HADDR;
                                
                            end
                        
                        end
                        
                        8'd16: begin
                            
                            //4-beat incrementing burst
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            HRDATA           <= slave_mem[raddr] ;
                            raddr            <= raddr + 1'b1;
                            
                        end
                        
                        8'd8: begin
                            
                            // 8-beat wrapping burst
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            
                            if(raddr < (HADDR + 3'd7))
                            begin
                            
                                HRDATA           <= slave_mem[raddr] ;
                                raddr            <= raddr + 1'b1;
                                
                            end
                            
                            else
                            begin
                            
                                HRDATA           <= slave_mem[raddr] ;
                                raddr            <= HADDR;
                                
                            end
                        
                        end
                        
                        8'd4: begin
                            
                            //8-beat incrementing burst
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            HRDATA           <= slave_mem[raddr] ;
                            raddr            <= raddr + 1'b1;
                            
                        end
                        
                        8'd2: begin
                        
                            // 16-beat wrapping burst
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            
                            if(raddr < (HADDR + 4'd15))
                            begin
                            
                                HRDATA           <= slave_mem[raddr] ;
                                raddr            <= raddr + 1'b1;
                                
                            end
                            
                            else
                            begin
                            
                                HRDATA           <= slave_mem[raddr] ;
                                raddr            <= HADDR;
                                
                            end
                        
                        end
                        
                        8'd1: begin
                            
                            //16-beat incrementing burst
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            HRDATA           <= slave_mem[raddr] ;
                            raddr            <= raddr + 1'b1;
                            
                        end
                        
                        default: begin
                        
                            HREADYOUT        <= 1'b1;
                            HRESP            <= 1'b0;
                            
                        end
                        
                    endcase
                
                end
                
                default: begin
                
                    HREADYOUT        <= 1'b0;
                    HRESP            <= 1'b0;
                    HRDATA           <= HRDATA;
                    waddr            <= waddr;
                    raddr            <= raddr;
                    
                end
                
            
            endcase
        
        end
    
    end
    
    
endmodule
