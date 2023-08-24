
`timescale 1ns / 1ps

module AXI_Master#(

parameter DATAW   = 32, 
parameter SIZE    = 3,
parameter BYTEW   = 8,
parameter MEMSIZE = 4096

)
(
    
    input clk,
    input reset,
    
    //Signals of the Write Address channels
    input [(DATAW/8)-1 : 0]  AWID,
    input [DATAW-1 : 0]      AWADDR,
    input [(DATAW/8)-1 : 0]  AWLEN,
    input [SIZE-1 : 0]       AWSIZE,
    input [SIZE-2 : 0]       AWBURST,
    input                    AWREADY,
    output reg               AWVALID,
    
    
    //Signals of the Write Data channels
    output reg [(DATAW/8)-1 : 0] WID,
    input [DATAW-1 : 0]      WDATA,
    input [(DATAW/8)-1 : 0]  WSTRB,
    output reg               WLAST,
    input                    WREADY,
    output reg               WVALID,
    
    //Signals of the Write Response channel
    input                    BID,
    input                    BRESP,
    input                    BVALID,
    output reg               BREADY,
    
    //Signals of the Read Address channels
    input [(DATAW/8)-1 : 0]  ARID,
    input [DATAW-1 : 0]      ARADDR,
    input [(DATAW/8)-1 : 0]  ARLEN,
    input [SIZE-1 : 0]       ARSIZE,
    input [SIZE-2 : 0]       ARBURST,
    input                    ARREADY,
    output reg               ARVALID,
    
    
    //Signals of the Read Data channels
    output reg [(DATAW/8)-1 : 0] RID,
    input [DATAW-1 : 0]      RDATA,
    input                    RRESP,
    input                    RLAST,
    input                    RVALID,
    output reg               RREADY,
    
    //Outputs to the AXI-Slave
    output reg [SIZE-2 : 0]      Out_AWBURST,
    output reg [SIZE-1 : 0]      Out_AWSIZE,
    output reg [(DATAW/8)-1 : 0] Out_AWLEN,
    output reg [DATAW-1 : 0]     Out_AWADDR,
    output reg [(DATAW/8)-1 : 0] Out_AWID,
    output reg [(DATAW/8)-1 : 0] Out_WSTRB,
    output reg [DATAW-1 : 0]     Out_WDATA,
    output reg [(DATAW/8)-1 : 0] Out_ARID,
    output reg [DATAW-1 : 0]     Out_ARADDR,
    output reg [(DATAW/8)-1 : 0] Out_ARLEN,
    output reg [SIZE-1 : 0]      Out_ARSIZE,
    output reg [SIZE-2 : 0]      Out_ARBURST
    
);

     /***********************************************************************
                             States of each channel
     ***********************************************************************/
     
     //Write-Address Channel States
     
     localparam  AWRITE_IDLE    = 0;
     localparam  AWRITE_START   = 1;
     localparam  AWRITE_WAIT    = 2;
     localparam  AWRITE_VALID   = 3;
     
     reg [1 : 0] AWState , AWState_Next;
     
     //Write-Data Channel States
     
     localparam DWRITE_INIT     = 0;
     localparam DWRITE_TRANSFER = 1;
     localparam DWRITE_READY    = 2;
     localparam DWRITE_VALID    = 3;
     localparam DWRITE_ERROR    = 4;
     
     reg [2 : 0] DWState , DWState_Next;
     reg [4 : 0] count , count_next;
     
     //Write-Response Channel States
     
     localparam RBWRITE_IDLE    = 0;
     localparam RBWRITE_START   = 1;
     localparam RBWRITE_READY   = 2;
     
     reg [1 : 0] RBState , RBState_Next;    
     
     //READ-Address Channel States
     
     localparam AREAD_IDLE      = 0;
     localparam AREAD_WAIT      = 1;            
     localparam AREAD_READY     = 2;
     localparam AREAD_VALID     = 3;
     localparam AREAD_EXTRA     = 4;
    
     reg [2 : 0] ARState , ARState_Next;
     
     //Read-Data Channel States
     
     reg [31 : 0] slaveaddress , slaveaddress_r , slaveaddress_n , ARADDR_r;
     
     localparam DREAD_CLEAR     = 0;
     localparam DREAD_STARTM    = 1;
     localparam DREAD_READ      = 2;
     localparam DREAD_VALID     = 3;
     
     reg [1  : 0] DRState , DRState_Next;
     reg [31 : 0] wrap_boundary,first_time1, first_time1_next;
     
     //Memory to store read values
     reg [BYTEW-1 : 0] read_memory [MEMSIZE-1 : 0];
     
     
     /************************* FSM for Write Address Channel *************************/
     
     always@(posedge clk or negedge reset)
     begin
     
        if(!reset)
        begin
        
            AWState <= AWRITE_IDLE;
        
        end
        
        else
        begin
        
            AWState <= AWState_Next;
        
        end
     
     end
     
     
     always@(*)
     begin
     
        case(AWState)
        
            AWRITE_IDLE: begin
            
                AWVALID      = 1'b0;
                Out_AWBURST  = {(SIZE-1){1'b0}};
                Out_AWSIZE   = {SIZE{1'b0}};
                Out_AWLEN    = {(DATAW/8){1'b0}};
                Out_AWADDR   = {DATAW{1'b0}};
                Out_AWID     = {(DATAW/8){1'b0}};
                
                AWState_Next = AWRITE_START; 
            
            end
            
            AWRITE_START: begin
            
                if(AWADDR > 32'h0)
                begin
                
                    AWVALID      = 1'b1;
                    Out_AWBURST  = AWBURST;
                    Out_AWSIZE   = AWSIZE;
                    Out_AWLEN    = AWLEN;
                    Out_AWADDR   = AWADDR;
                    Out_AWID     = AWID;
                    
                    AWState_Next = AWRITE_WAIT;
                
                end
                
                else
                begin
                
                    AWState_Next = AWRITE_IDLE;
                
                end
            
            end
            
            AWRITE_WAIT: begin
            
                if(AWREADY)
                begin
                    
                    AWState_Next = AWRITE_VALID;
                
                end
                
                else
                begin
                    
                    AWState_Next = AWRITE_WAIT;
                
                end
            
            end
            
            AWRITE_VALID: begin
            
                AWVALID = 1'b0;
                if(AWREADY)
                begin
                
                    AWState_Next = AWRITE_IDLE;
                
                end
                
                else
                begin
                
                    AWState_Next = AWRITE_VALID;
                
                end
            
            end
        
        endcase
     
     end
     
     
     /************************* FSM for Write Data Channel *************************/
     
     always@(posedge clk or negedge reset)
     begin
     
        if(!reset)
         begin
         
             DWState <= DWRITE_INIT;
             count   <= 5'b0;
         
         end
         
         else
         begin
         
            DWState <= DWState_Next;
            count   <= count_next;
         
         end
     
     end
     
     always@(*)
     begin
     
        case(DWState)
        
            DWRITE_INIT: begin
                
                WID         = {(DATAW/8){1'b0}};
                Out_WDATA   = {DATAW{1'b0}};
                Out_WSTRB   = {(DATAW/8){1'b0}};
                WLAST       = 1'b0;
                WVALID      = 1'b0;
                count_next  = 5'b0;
                
                if(AWREADY)
                begin
                    
                    DWState_Next = DWRITE_TRANSFER;
                
                end
                
                else
                begin
                
                    DWState_Next = DWRITE_INIT;
                
                end
            
            end
            
            DWRITE_TRANSFER: begin
            
                //Check whether the write address within the valid address space
                if(AWADDR > 32'h5ff && AWADDR <= 32'hfff && AWSIZE < 3'b100)
                begin
                
                    WID          = Out_AWID;
                    Out_WDATA    = WDATA;
                    Out_WSTRB    = WSTRB;
                    WVALID       = 1'b1;
                    count_next   = count + 1'b1;  
                    DWState_Next = DWRITE_READY;
                
                end
                
                else
                begin
                
                    count_next   = count + 1'b1;  
                    DWState_Next = DWRITE_ERROR; 
                
                end
            
            end
            
            DWRITE_READY: begin
            
                if(WREADY)
                begin
                
                    if(count_next == (AWLEN + 1'b1))
                    begin
                    
                        WLAST = 1'b1;
                    
                    end
                    
                    else
                    begin
                    
                        WLAST = 1'b0;
                    
                    end
                    
                    DWState_Next = DWRITE_VALID;
                
                end
                
                else
                begin
                
                    DWState_Next = DWRITE_READY;
                
                end
            
            end
            
            DWRITE_VALID: begin
            
                WVALID = 1'b0;
                if(count_next == (AWLEN + 1'b1))
                begin
                
                   DWState_Next = DWRITE_INIT; 
                   WLAST        = 1'b0;
                
                end
                
                else
                begin
                
                    DWState_Next = DWRITE_TRANSFER;
                
                end
            
            end
            
            DWRITE_ERROR: begin
            
                if(count_next == (AWLEN + 1'b1))
                begin
                    
                    WLAST        = 1'b1;
                    DWState_Next = DWRITE_VALID;
                
                end
                
                else
                begin
                
                    WLAST        = 1'b0;
                    DWState_Next = DWRITE_TRANSFER;
                
                end
            
            end
        
        endcase
     
     end
     
     /************************* FSM for Write Response Channel *************************/

     
     always@(posedge clk or negedge reset)
     begin
        
        if(!reset)
        begin
            
            RBState <= RBWRITE_IDLE;
        
        end
        
        else
        begin
        
            RBState <= RBState_Next;
        
        end
          
     end
    
     
    
     always@(*)
     begin
     
        case(RBState)
        
            RBWRITE_IDLE: begin
            
                BREADY = 1'b0;
                RBState_Next = RBWRITE_START;
            
            end
            
            RBWRITE_START: begin
            
                if(BVALID)
                begin
                    
                   RBState_Next =  RBWRITE_READY;
                
                end
            
            end
            
            RBWRITE_READY: begin
            
                BREADY        = 1'b1;
                RBState_Next  = RBWRITE_IDLE;
            
            end
        
        endcase
     
     end
     
     
     /************************* FSM for Read Address Channel *************************/

     
     always@(posedge clk or negedge reset)
     begin
     
        if(!reset)
        begin
        
            ARState <= AREAD_IDLE;
        
        end
        
        else
        begin
        
            ARState <= ARState_Next;
        
        end
     
     end
     
     always@(*)
     begin
     
        case(ARState)
            
            AREAD_IDLE: begin
           
                Out_ARID     = {(DATAW/8){1'b0}};
                Out_ARADDR   = {DATAW{1'b0}};
                Out_ARLEN    = {(DATAW/8){1'b0}}; 
                Out_ARSIZE   = {SIZE{1'b0}};    
                Out_ARBURST  = {(SIZE-1){1'b0}};
                ARVALID      = 1'b0;
                ARState_Next = AREAD_WAIT;
           
            end 
            
            AREAD_WAIT: begin
            
                if(ARADDR > 32'h0)
                begin
                
                    Out_ARID     = ARID;
                    Out_ARADDR   = ARADDR;
                    Out_ARLEN    = ARLEN; 
                    Out_ARSIZE   = ARSIZE;    
                    Out_ARBURST  = ARBURST;
                    ARVALID      = 1'b1;
                    ARState_Next = AREAD_READY; 
                
                end
                
                else
                begin
                
                    ARState_Next = AREAD_IDLE;
                
                end
            
            end
            
            AREAD_READY: begin
            
                if(ARREADY)
                begin
                    
                    ARState_Next = AREAD_VALID;
                
                end
                
                else
                begin
                
                    ARState_Next = AREAD_READY;
                
                end
            
            end
            
            AREAD_VALID: begin
            
                ARVALID = 1'b0;
                if(RLAST)
                begin
                    
                    ARState_Next = AREAD_EXTRA;
                
                end
                
                else
                begin
                    
                    ARState_Next = AREAD_VALID;
                
                end
                
            end
            
            AREAD_EXTRA: begin
            
                ARState_Next = AREAD_IDLE;
            
            end
        
        endcase
     
     end
     
     /************************* FSM for Read Data Channel *************************/
     
     always@(posedge clk or negedge reset)
     begin
     
        if(!reset)
        begin
        
            DRState     <= DREAD_CLEAR;
        
        end
        
        else
        begin
        
            DRState     <= DRState_Next;
            first_time1 <= first_time1_next;
        
        end
     
     end
     
     always@(*)
     begin
     
        if(ARREADY)
        begin
            
            ARADDR_r = ARADDR;
        
        end
        
        case(DRState)
        
            DREAD_CLEAR: begin
            
                RREADY           = 1'b0;
                first_time1_next = 32'b0;
                slaveaddress     = 32'b0;
                slaveaddress_r   = 32'b0;  
                DRState_Next     = DREAD_STARTM;
            
            end
            
            DREAD_STARTM: begin
            
                if(RVALID)
                begin
                
                    DRState_Next  = DREAD_READ;
                    slaveaddress  = slaveaddress_r; 
                
                end
                
                else
                begin
                
                    DRState_Next  = DREAD_STARTM;
                
                end
            
            end
            
            DREAD_READ: begin
            
                DRState_Next  = DREAD_VALID;
                RREADY        = 1'b1;
                
                case(ARBURST)
                    
                    //Fixed Burst
                    2'b00: begin
                    
                        slaveaddress = ARADDR_r;
                        case(ARSIZE)
                        
                            3'b000: begin
                                //1 Byte transfer
                                read_memory[slaveaddress] = RDATA[7:0];
                                
                            end
                            
                            3'b001: begin
                                //2 Byte transfer
                                read_memory[slaveaddress]     = RDATA[7:0];
                                read_memory[slaveaddress + 1] = RDATA[15:8];
                            
                            end
                            
                            3'b010: begin
                                //4 Byte transfer
                                read_memory[slaveaddress]     = RDATA[7:0];
                                read_memory[slaveaddress + 1] = RDATA[15:8];
                                read_memory[slaveaddress + 2] = RDATA[23:16];
                                read_memory[slaveaddress + 3] = RDATA[31:24];
                            
                            end
                            
                        
                        endcase
                    
                    end
                    
                    //Increment Burst
                    2'b01: begin
                    
                        if(first_time1 == 0)
                        begin
                        
                            slaveaddress     = ARADDR_r;
                            first_time1_next = 1;
                        
                        end    
                        
                        else
                        begin
                        
                            first_time1_next = first_time1;
                        
                        end
                        
                        if(RLAST)
                        begin
                        
                            first_time1_next = 0;
                        
                        end
                        
                        else
                        begin
                        
                            first_time1_next = first_time1;
                        
                        end
                        
                        case(ARSIZE)
                        
                            3'b000: begin
                            
                                read_memory[slaveaddress]     = RDATA[7:0];
                            
                            end
                            
                            3'b001: begin
                            
                                read_memory[slaveaddress]         = RDATA[7:0];
                                read_memory[slaveaddress + 1]     = RDATA[15:8];
                                slaveaddress_r = slaveaddress + 2;
                            
                            end
                            
                            3'b010: begin
                            
                                read_memory[slaveaddress]          = RDATA[7:0];
                                read_memory[slaveaddress + 1]      = RDATA[15:8];
                                read_memory[slaveaddress + 2]      = RDATA[23:16];
                                read_memory[slaveaddress + 3]      = RDATA[31:24];
                                slaveaddress_r = slaveaddress + 4;
                                
                            end
                        
                        endcase
                        
                    end
                    
                    //Wrapping Burst
                    2'b10: begin
                    
                        if(first_time1 == 0)
                        begin
                        
                            slaveaddress     = ARADDR_r;
                            first_time1_next = 1;
                        
                        end    
                        
                        else
                        begin
                        
                            first_time1_next = first_time1;
                        
                        end
                        
                        if(RLAST)
                        begin
                        
                            first_time1_next = 0;
                        
                        end
                        
                        else
                        begin
                        
                            first_time1_next = first_time1;
                        
                        end
                        
                        case(ARLEN)
                        
                            //The length of the burst must be 2, 4, 8, or 16 transfers
                            4'b0001: begin
                            
                                case(ARSIZE)
                                
                                    3'b000: begin
                                        //total size of the beat is 1 byte , and there is two beats per burst 
                                        wrap_boundary = 2 * 1;
                                    
                                    end
                                    
                                    3'b001: begin
                                        //total size of the beat is 2 bytes , and there is two beats per burst 
                                        wrap_boundary = 2 * 2;
                                    
                                    end
                                    
                                    3'b010: begin
                                        //total size of the beat is 4 bytes , and there is two beats per burst 
                                        wrap_boundary = 2 * 4;
                                    
                                    end
                                
                                endcase
                            
                            end
                            
                            4'b0011: begin
                            
                                case(ARSIZE)
                                
                                    3'b000: begin
                                        //total size of the beat is 1 byte , and there is four beats per burst 
                                        wrap_boundary = 4 * 1;
                                    
                                    end
                                    
                                    3'b001: begin
                                        //total size of the beat is 2 bytes , and there is four beats per burst 
                                        wrap_boundary = 4 * 2;
                                    
                                    end
                                    
                                    3'b010: begin
                                        //total size of the beat is 4 bytes , and there is four beats per burst 
                                        wrap_boundary = 4 * 4;
                                    
                                    end
                                
                                endcase
                            
                            end
                            
                            4'b0111: begin
                            
                                case(ARSIZE)
                                
                                    3'b000: begin
                                        //total size of the beat is 1 byte , and there is eight beats per burst 
                                        wrap_boundary = 8 * 1;
                                    
                                    end
                                    
                                    3'b001: begin
                                        //total size of the beat is 2 bytes , and there is eight beats per burst 
                                        wrap_boundary = 8 * 2;
                                    
                                    end
                                    
                                    3'b010: begin
                                        //total size of the beat is 4 bytes , and there is eight beats per burst 
                                        wrap_boundary = 8 * 4;
                                    
                                    end
                                
                                endcase
                            
                            end
                            
                            4'b1111: begin
                            
                                case(ARSIZE)
                                
                                    3'b000: begin
                                        //total size of the beat is 1 byte , and there is sixteen beats per burst 
                                        wrap_boundary = 16 * 1;
                                    
                                    end
                                    
                                    3'b001: begin
                                        //total size of the beat is 2 bytes , and there is sixteen beats per burst 
                                        wrap_boundary = 16 * 2;
                                    
                                    end
                                    
                                    3'b010: begin
                                        //total size of the beat is 4 bytes , and there is sixteen beats per burst 
                                        wrap_boundary = 16 * 4;
                                    
                                    end
                                
                                endcase
                            
                            end
                            
                        endcase
                        
                        case(ARSIZE)
                        
                            3'b000: begin
                            
                                read_memory[slaveaddress] = RDATA[7 : 0];
                                slaveaddress_n            = slaveaddress + 1;
                                
                                if(slaveaddress_n % wrap_boundary == 0)
                                begin
                                
                                    slaveaddress_r = slaveaddress_n - wrap_boundary;
                                
                                end
                                
                                else
                                begin
                                
                                    slaveaddress_r = slaveaddress_n;
                                
                                end
                            
                            end
                            
                            3'b001: begin
                            
                                read_memory[slaveaddress] = RDATA[7 : 0];
                                slaveaddress_n            = slaveaddress + 1;  
                                
                                if(slaveaddress_n % wrap_boundary == 0)
                                begin
                                
                                    slaveaddress_r = slaveaddress_n - wrap_boundary;
                                
                                end
                                
                                else
                                begin
                                
                                    slaveaddress_r = slaveaddress_n;
                                
                                end
                                
                                read_memory[slaveaddress_r] = RDATA[15 : 8];
                                slaveaddress_n              = slaveaddress_r + 1;
                                
                                if(slaveaddress_n % wrap_boundary == 0)
                                begin
                                
                                    slaveaddress_r = slaveaddress_n - wrap_boundary;
                                
                                end
                                
                                else
                                begin
                                
                                    slaveaddress_r = slaveaddress_n;
                                
                                end
                                
                            end
                            
                            3'b010: begin
                            
                                read_memory[slaveaddress] = RDATA[7 : 0];
                                slaveaddress_n            = slaveaddress + 1;  
                                
                                if(slaveaddress_n % wrap_boundary == 0)
                                begin
                                
                                    slaveaddress_r = slaveaddress_n - wrap_boundary;
                                
                                end
                                
                                else
                                begin
                                
                                    slaveaddress_r = slaveaddress_n;
                                
                                end
                                
                                read_memory[slaveaddress_r] = RDATA[15 : 8];
                                slaveaddress_n              = slaveaddress_r + 1;
                                
                                if(slaveaddress_n % wrap_boundary == 0)
                                begin
                                
                                    slaveaddress_r = slaveaddress_n - wrap_boundary;
                                
                                end
                                
                                else
                                begin
                                
                                    slaveaddress_r = slaveaddress_n;
                                
                                end
                                
                                read_memory[slaveaddress_r] = RDATA[23 : 16];
                                slaveaddress_n              = slaveaddress_r + 1;
                            
                                if(slaveaddress_n % wrap_boundary == 0)
                                begin
                                
                                    slaveaddress_r = slaveaddress_n - wrap_boundary;
                                
                                end
                                
                                else
                                begin
                                
                                    slaveaddress_r = slaveaddress_n;
                                
                                end
                                
                                read_memory[slaveaddress_r] = RDATA[31 : 24];
                                slaveaddress_n              = slaveaddress_r + 1;
                            
                                if(slaveaddress_n % wrap_boundary == 0)
                                begin
                                
                                    slaveaddress_r = slaveaddress_n - wrap_boundary;
                                
                                end
                                
                                else
                                begin
                                
                                    slaveaddress_r = slaveaddress_n;
                                
                                end
                            
                            end
                        
                        endcase //ARSIZE case end
                    
                    end //wrapping burst case
                    
                endcase//ARBURST 
            
            end//DREAD_READ end
            
            DREAD_VALID: begin
            
                RREADY = 1'b0;
                
                if(RLAST)
                begin
                
                    DRState_Next = DREAD_CLEAR;
                
                end
                
                else
                begin
                    
                    DRState_Next = DREAD_STARTM;
                
                end
            
            end
        
        endcase
     
     end
  
endmodule


