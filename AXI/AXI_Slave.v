`timescale 1ns / 1ps


module AXI_Slave#(

parameter DATAW   = 32, 
parameter SIZE    = 3,
parameter BYTEW   = 8,
parameter MEMSIZE = 4096

)
(
    
    input  clk,
    input  reset,
    
    input                        WVALID,
    input                        WLAST,
    input [(DATAW/8)-1 : 0]      WSTRB,
    input [DATAW-1 : 0]          WDATA,
    input [(DATAW/8)-1 : 0]      WID,
    input                        BREADY,
    input                        AWVALID,
    input [SIZE-2 : 0]           AWBURST,
    input [SIZE-1 : 0]           AWSIZE,
    input [(DATAW/8)-1 : 0]      AWLEN,
    input [DATAW-1 : 0]          AWADDR,
    input [(DATAW/8)-1 : 0]      AWID,
    input [(DATAW/8)-1 : 0]      ARID,
    input [DATAW-1 : 0]          ARADDR,
    input [(DATAW/8)-1 : 0]      ARLEN,
    input [SIZE-1 : 0]           ARSIZE,
    input [SIZE-2 : 0]           ARBURST,
    input                        ARVALID,
    input                        RREADY,
    
    output reg                   WREADY,
    output reg [(DATAW/8)-1 : 0] BID,
    output reg [SIZE-2 : 0]      BRESP,
    output reg                   BVALID,
    output reg                   AWREADY,
    output reg                   ARREADY,
    output reg [(DATAW/8)-1 : 0] RID,
    output reg [DATAW-1 : 0]     RDATA,
    output reg [SIZE-2 : 0]      RRESP,
    output reg                   RLAST,
    output reg                   RVALID
    
);
    
    /***********************************************************************
                        States of each channel
    ***********************************************************************/
    
    //Write-Address Channel States
    localparam AWSLAVE_IDLE  = 0;
    localparam AWSLAVE_START = 1;
    localparam AWSLAVE_READY = 2;
    
    reg [1 : 0] AWState , AWState_Next;
    
    //Write-Data Channel States
    localparam DWSLAVE_INIT  = 0;
    localparam DWSLAVE_START = 1; 
    localparam DWSLAVE_READY = 2;
    localparam DWSLAVE_VALID = 3;
    
    reg [1 : 0] DWState , DWState_Next;
    reg [31 : 0] AWADDR_r;
    reg [31 : 0] masteraddress , masteraddress_r , masteraddress_n;
    reg first_time1 , first_time1_next;
    integer wrap_boundary1;
    
    //Write-Response Channel States
    localparam RBSLAVE_IDLE  = 0;
    localparam RBSLAVE_LAST  = 1;
    localparam RBSLAVE_START = 2;
    localparam RBSLAVE_WAIT  = 3;
    localparam RBSLAVE_VALID = 4;
    
    reg [2 : 0] RBState , RBState_Next;
    
    //READ-Address Channel States
    localparam ARSLAVE_IDLE  = 0;
    localparam ARSLAVE_WAIT  = 1;
    localparam ARSLAVE_READY = 2;
    
    reg [1 : 0] ARState , ARState_Next;
    
    //Read-Data Channel States
    localparam DRSLAVE_CLEAR  = 0;
    localparam DRSLAVE_START  = 1;
    localparam DRSLAVE_WAIT   = 2;
    localparam DRSLAVE_VALID  = 3;
    localparam DRSLAVE_ERROR  = 4;
    
    reg [2 : 0] DRState , DRState_Next;
    reg first_time2 , first_time2_next;
    integer wrap_boundary2;
    reg [4  : 0] counter , counter_next;
    reg [31 : 0] ARADDR_r;
    reg [31 : 0] readdata_address , readdata_address_r , readdata_address_n;
    
    //Slave Memory
    reg [BYTEW-1 : 0] slave_memory [MEMSIZE-1 : 0];
    
    /************************* FSM for Write Address Channel *************************/
    always@(posedge clk or negedge reset)
    begin
    
        if(!reset)
        begin
        
            AWState <= AWSLAVE_IDLE;
            
        end
        else begin
        
            AWState <= AWState_Next;
            
        end
        
    end

    always@(*)
    begin
    
        case(AWState)
        
            AWSLAVE_IDLE: begin
                
                AWREADY = 1'b0;
                AWState <= AWSLAVE_START;
                
            end//AWSLAVE_IDLE
            
            AWSLAVE_START: begin
                
                if(AWVALID)
                begin
                    
                    AWState <= AWSLAVE_READY;
                
                end
                else begin
                
                    AWState <= AWSLAVE_START;
                
                end
            
            end//AWSLAVE_START
            
            AWSLAVE_READY: begin
            
                AWREADY = 1'b1;
                AWState <= AWSLAVE_IDLE;
            
            end//AWSLAVE_READY
            
        endcase//AWState end
        
    end
    
    /************************* FSM for Write Data Channel *************************/
    always@(posedge clk or negedge reset)
    begin
    
        if(!reset)
        begin
        
            DWState     <= DWSLAVE_INIT;
            
        end
        else begin
        
            DWState     <= DWState_Next;
            first_time1 <= first_time1_next;
            
        end
        
    end
    
    always@(*)
    begin
    
        if(AWVALID == 1'b1)
        begin
            
            AWADDR_r = AWADDR;
        
        end
        
        case(DWState)
        
            DWSLAVE_INIT: begin
            
                WREADY           = 1'b0;
                first_time1_next = 1'b0;
                masteraddress    = 32'h0;
                masteraddress_r  = 32'h0;
                DWState_Next     = DWSLAVE_START;
                
            end//DWSLAVE_INIT
            
            DWSLAVE_START: begin
            
                if(WVALID)
                begin
                
                    DWState_Next     = DWSLAVE_READY;
                    masteraddress    = masteraddress_r;
                
                end
                else begin
                
                    DWState_Next     = DWSLAVE_START;
                
                end
            
            end//DWSLAVE_START
            
            DWSLAVE_READY: begin
            
                if(WLAST)
                begin
                    
                    DWState_Next     <= DWSLAVE_INIT;
                
                end
                else begin
                
                    DWState_Next     <= DWSLAVE_VALID;
                
                end
                
                WREADY = 1'b1;
                
                case(AWBURST)
                
                    2'b00: begin
                    
                        masteraddress = AWADDR_r;
                        case(WSTRB)
                        
                            4'b0001: begin
                            
                                slave_memory[masteraddress] = WDATA[7 : 0];
                            
                            end
                            
                            4'b0010: begin
                            
                                slave_memory[masteraddress] = WDATA[15 : 8];
                            
                            end
                            
                            4'b0100: begin
                            
                                slave_memory[masteraddress] = WDATA[23 : 16];
                            
                            end
                            
                            4'b1000: begin
                            
                                slave_memory[masteraddress] = WDATA[31 : 24];
                            
                            end
                            
                            4'b0011: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress + 1] = WDATA[15 : 8];
                            
                            end
                            
                            4'b0101: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress + 1] = WDATA[23 : 16];
                            
                            end
                            
                            4'b1001: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress + 1] = WDATA[31 : 24];
                            
                            end
                            
                            4'b0110: begin
                            
                                slave_memory[masteraddress]     = WDATA[15 : 8];
                                slave_memory[masteraddress + 1] = WDATA[23 : 16];
                            
                            end
                            
                            4'b1010: begin
                            
                                slave_memory[masteraddress]     = WDATA[15 : 8];
                                slave_memory[masteraddress + 1] = WDATA[31 : 24];
                            
                            end
                            
                            4'b1100: begin
                            
                                slave_memory[masteraddress]     = WDATA[23 : 16];
                                slave_memory[masteraddress + 1] = WDATA[31 : 24];
                            
                            end
                            
                            4'b0111: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress + 1] = WDATA[15 : 8];
                                slave_memory[masteraddress + 2] = WDATA[23 : 16];
                            
                            end
                            
                            4'b1110: begin
                            
                                slave_memory[masteraddress]     = WDATA[15 : 8];
                                slave_memory[masteraddress + 1] = WDATA[23 : 16];
                                slave_memory[masteraddress + 2] = WDATA[31 : 24];
                            
                            end
                            
                            4'b1011: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress + 1] = WDATA[15 : 8];
                                slave_memory[masteraddress + 2] = WDATA[31 : 24];
                            
                            end
                            
                            4'b1101: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress + 1] = WDATA[23 : 16];
                                slave_memory[masteraddress + 2] = WDATA[31 : 24];
                            
                            end
                            
                            4'b1111: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress]     = WDATA[15 : 8];
                                slave_memory[masteraddress + 1] = WDATA[23 : 16];
                                slave_memory[masteraddress + 2] = WDATA[31 : 24];
                            
                            end
                            
                            default: begin
                            
                            
                            end
                        
                        endcase//WSTRB
                    
                    end//Fixed 
                    
                    2'b01: begin
                    
                        if(first_time1 == 1'b0)
                        begin
                        
                            masteraddress    = AWADDR_r;
                            first_time1_next = 1'b1;
                        
                        end
                        else begin
                        
                            first_time1_next = first_time1;
                            
                        end
                        
                        if(BREADY)
                        begin
                            
                            first_time1_next = 1'b0;
                        
                        end
                        else begin
                        
                            first_time1_next = first_time1;    
                        
                        end
                        
                        case(WSTRB)
                        
                            4'b0001: begin
                            
                                slave_memory[masteraddress] = WDATA[7 : 0];
                                masteraddress_r             = masteraddress + 1'b1;
                            
                            end
                            
                            4'b0010: begin
                            
                                slave_memory[masteraddress] = WDATA[15 : 8];
                                masteraddress_r             = masteraddress + 1'b1;
                            
                            end
                            
                            4'b0100: begin
                            
                                slave_memory[masteraddress] = WDATA[23 : 16];
                                masteraddress_r             = masteraddress + 1'b1;
                            
                            end
                            
                            4'b1000: begin
                            
                                slave_memory[masteraddress] = WDATA[31 : 24];
                                masteraddress_r             = masteraddress + 1'b1;
                            
                            end
                            
                            4'b0011: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress + 1] = WDATA[15 : 8];
                                masteraddress_r                 = masteraddress + 2;
                            
                            end
                            
                            4'b0101: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress + 1] = WDATA[23 : 16];
                                masteraddress_r                 = masteraddress + 2;
                            
                            end
                            
                            4'b1001: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress + 1] = WDATA[31 : 24];
                                masteraddress_r                 = masteraddress + 2;
                            
                            end
                            
                            4'b0110: begin
                            
                                slave_memory[masteraddress]     = WDATA[15 : 8];
                                slave_memory[masteraddress + 1] = WDATA[23 : 16];
                                masteraddress_r                 = masteraddress + 2;
                            
                            end
                            
                            4'b1010: begin
                            
                                slave_memory[masteraddress]     = WDATA[15 : 8];
                                slave_memory[masteraddress + 1] = WDATA[31 : 24];
                                masteraddress_r                 = masteraddress + 2;
                            
                            end
                            
                            4'b1100: begin
                            
                                slave_memory[masteraddress]     = WDATA[23 : 16];
                                slave_memory[masteraddress + 1] = WDATA[31 : 24];
                                masteraddress_r                 = masteraddress + 2;
                            
                            end
                            
                            4'b0111: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress + 1] = WDATA[15 : 8];
                                slave_memory[masteraddress + 2] = WDATA[23 : 16];
                                masteraddress_r                 = masteraddress + 3;
                            
                            end
                            
                            4'b1110: begin
                            
                                slave_memory[masteraddress]     = WDATA[15 : 8];
                                slave_memory[masteraddress + 1] = WDATA[23 : 16];
                                slave_memory[masteraddress + 2] = WDATA[31 : 24];
                                masteraddress_r                 = masteraddress + 3;
                            
                            end
                            
                            4'b1011: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress + 1] = WDATA[15 : 8];
                                slave_memory[masteraddress + 2] = WDATA[31 : 24];
                                masteraddress_r                 = masteraddress + 3;
                            
                            end
                            
                            4'b1101: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress + 1] = WDATA[23 : 16];
                                slave_memory[masteraddress + 2] = WDATA[31 : 24];
                                masteraddress_r                 = masteraddress + 3;
                            
                            end
                            
                            4'b1111: begin
                            
                                slave_memory[masteraddress]     = WDATA[7 : 0];
                                slave_memory[masteraddress]     = WDATA[15 : 8];
                                slave_memory[masteraddress + 1] = WDATA[23 : 16];
                                slave_memory[masteraddress + 2] = WDATA[31 : 24];
                                masteraddress_r                 = masteraddress + 4;
                            
                            end
                            
                            default: begin
                            
                            
                            end
                        
                        endcase//WSTRB
                    
                    end//Inc
                    
                    2'b10: begin
                    
                        if(first_time1 == 1'b0)
                        begin
                        
                            masteraddress    = AWADDR_r;
                            first_time1_next = 1'b1;
                        
                        end
                        else begin
                        
                            first_time1_next = first_time1;
                            
                        end
                        
                        if(BREADY)
                        begin
                            
                            first_time1_next = 1'b0;
                        
                        end
                        else begin
                        
                            first_time1_next = first_time1;    
                        
                        end
                        
                        case(AWLEN)
                        
                            4'b0001: begin
                            
                                case(AWSIZE)
                                    
                                    3'b000: begin
                                    
                                        wrap_boundary1 = 2*1;
                                    
                                    end
                                    
                                    3'b001: begin
                                    
                                        wrap_boundary1 = 2*2;
                                    
                                    end
                                    
                                    3'b010: begin
                                    
                                        wrap_boundary1 = 2*4;
                                    
                                    end
                                
                                endcase//AWSIZE
                                
                            end//2-beat wrap
                            
                            4'b0011: begin
                            
                                case(AWSIZE)
                                    
                                    3'b000: begin
                                    
                                        wrap_boundary1 = 4*1;
                                    
                                    end
                                    
                                    3'b001: begin
                                    
                                        wrap_boundary1 = 4*2;
                                    
                                    end
                                    
                                    3'b010: begin
                                    
                                        wrap_boundary1 = 4*4;
                                    
                                    end
                                
                                endcase//AWSIZE
                                
                            end//4-beat wrap
                            
                            4'b0111: begin
                            
                                case(AWSIZE)
                                    
                                    3'b000: begin
                                    
                                        wrap_boundary1 = 8*1;
                                    
                                    end
                                    
                                    3'b001: begin
                                    
                                        wrap_boundary1 = 8*2;
                                    
                                    end
                                    
                                    3'b010: begin
                                    
                                        wrap_boundary1 = 8*4;
                                    
                                    end
                                
                                endcase//AWSIZE
                                
                            end//8-beat wrap
                            
                            4'b0111: begin
                            
                                case(AWSIZE)
                                    
                                    3'b000: begin
                                    
                                        wrap_boundary1 = 16*1;
                                    
                                    end
                                    
                                    3'b001: begin
                                    
                                        wrap_boundary1 = 16*2;
                                    
                                    end
                                    
                                    3'b010: begin
                                    
                                        wrap_boundary1 = 16*4;
                                    
                                    end
                                
                                endcase//AWSIZE
                                
                            end//16-beat wrap
                        
                        endcase//AWLEN
                        
                        case(WSTRB)
                        
                            4'b0001: begin
                            
                                slave_memory[masteraddress] = WDATA[7 : 0];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b0010: begin
                            
                                slave_memory[masteraddress] = WDATA[15 : 8];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b0100: begin
                            
                                slave_memory[masteraddress] = WDATA[23 : 16];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b1000: begin
                            
                                slave_memory[masteraddress] = WDATA[31 : 24];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b0011: begin
                            
                                slave_memory[masteraddress] = WDATA[7 : 0];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[15 : 8];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b0101: begin
                            
                                slave_memory[masteraddress] = WDATA[7 : 0];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[23 : 16];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b1001: begin
                            
                                slave_memory[masteraddress] = WDATA[7 : 0];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[31 : 24];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b0110: begin
                            
                                slave_memory[masteraddress] = WDATA[15 : 8];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[23 : 16];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b1010: begin
                            
                                slave_memory[masteraddress] = WDATA[15 : 8];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[31 : 24];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b1100: begin
                            
                                slave_memory[masteraddress] = WDATA[23 : 16];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[31 : 24];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b0111: begin
                            
                                slave_memory[masteraddress] = WDATA[7 : 0];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[15 : 8];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[23 : 16];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b1110: begin
                            
                                slave_memory[masteraddress] = WDATA[15 : 8];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[23 : 16];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[31 : 24];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b1011: begin
                            
                                slave_memory[masteraddress] = WDATA[7 : 0];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[15 : 8];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[31 : 24];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b1101: begin
                            
                                slave_memory[masteraddress] = WDATA[7 : 0];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[23 : 16];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[31 : 24];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                            
                            4'b1111: begin
                            
                                slave_memory[masteraddress] = WDATA[7 : 0];
                                masteraddress_n             = masteraddress + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[15 : 8];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[31 : 24];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                                
                                slave_memory[masteraddress_r] = WDATA[23 : 16];
                                masteraddress_n               = masteraddress_r + 1;
                                
                                if(masteraddress_n % wrap_boundary1 == 0)
                                begin
                                
                                    masteraddress_r = masteraddress_n - wrap_boundary1;
                                    
                                end
                                else begin
                                    
                                    masteraddress_r = masteraddress_n;
                                
                                end
                            
                            end
                        
                        endcase//WSTRB
                    
                    end//Wrap
                
                endcase//AWBURST end
            
            end//DWSLAVE_READY
            
            DWSLAVE_VALID: begin
                
                WREADY = 1'b0;
                DWState_Next     = DWSLAVE_START;
            
            end//DWSLAVE_VALID
        
        endcase//DWState end
    
    end
    
    /************************* FSM for Write Response Channel *************************/
    always@(posedge clk or negedge reset)
    begin
    
        if(!reset)
        begin
        
            RBState <= RBSLAVE_IDLE;
        
        end
        else begin
        
            RBState <= RBState_Next;
        
        end
    
    end
    
    always@(*)
    begin
    
        case(RBState)
        
            RBSLAVE_IDLE: begin
            
                BID    = {(DATAW/8){1'b0}};
                BRESP  = {(SIZE-1){1'b0}};
                BVALID = 1'b0;
                RBState_Next = RBSLAVE_LAST;
            
            end
            
            RBSLAVE_LAST: begin
            
                if(WLAST)
                begin
                
                    RBState_Next = RBSLAVE_START;
                
                end
                else begin
                
                   RBState_Next = RBSLAVE_LAST; 
                
                end
            
            end
            
            RBSLAVE_START: begin
            
                BID = AWID;
                
                if(AWADDR > 32'h5ff && AWADDR <= 32'hfff && AWSIZE < 3'b011)
                begin
                
                    //Normal access success. Indicates that a normal access has been successful
                    BRESP = 2'b00;
                
                end
                else if(AWADDR > 32'h1ff && AWADDR <= 32'h5ff || AWSIZE > 3'b010)
                begin
                
                    //Slave error. Used when the access has reached the slave successfully, but the slave address is out of range 
                    BRESP = 2'b10;
                
                end
                else begin
                    
                    //Decode error
                    BRESP = 2'b11;
                
                end
                
                BVALID = 1'b1;
                RBState_Next = RBSLAVE_WAIT;
            
            end
            
            RBSLAVE_WAIT: begin
            
                if(BREADY)
                begin
                
                   RBState_Next = RBSLAVE_IDLE; 
                
                end
            
            end
            
        endcase//RBState
    
    end
    
    /************************* FSM for Read Address Channel *************************/
    always@(posedge clk or negedge reset)
    begin
    
        if(!reset)
        begin
        
            ARState <= ARSLAVE_IDLE;
        
        end
        else begin
        
            ARState <= ARState_Next;
        
        end
    
    end
    
    always@(*)
    begin
    
        case(ARState)
        
            ARSLAVE_IDLE: begin
            
                ARREADY      = 1'b0;
                ARState_Next = ARSLAVE_WAIT; 
            
            end
            
            ARSLAVE_WAIT: begin
                
                if(ARVALID)
                begin
                
                   ARState_Next = ARSLAVE_READY; 
                
                end
                else begin
                    
                   ARState_Next = ARSLAVE_WAIT; 
                
                end
            
            end
            
            ARSLAVE_READY: begin
                
                ARState_Next = ARSLAVE_IDLE;
                ARREADY      = 1'b1;
            
            end
        
        endcase
    
    end
    
    /************************* FSM for Read Data Channel *************************/
    always@(posedge clk or negedge reset)
    begin
    
        if(!reset)
        begin
        
            DRState     <= DRSLAVE_CLEAR;
            counter     <= 5'b0;
        
        end
        else begin
        
            DRState     <= DRState_Next;
            counter     <= counter_next;
            first_time2 <= first_time2_next;
        
        end
    
    end
    
    always@(*)
    begin
    
        if(ARVALID)
        begin
        
            ARADDR_r = ARADDR;
        
        end
        
        case(DRState)
        
            DRSLAVE_CLEAR: begin
            
                RID     = {(DATAW/8){1'b0}};
                RDATA   = {DATAW{1'b0}};
                RRESP   = {(SIZE-1){1'b0}};
                RLAST   = 1'b0;
                
                counter_next       = 5'b0;
                readdata_address   = 32'h0;
                readdata_address_r = 32'h0;
                first_time2_next   = 1'b0;
                
                if(ARVALID)
                begin
                
                   DRState_Next =  DRSLAVE_START;
                
                end
                else begin
                
                    DRState_Next =  DRSLAVE_CLEAR;
                
                end
            
            end//DRSLAVE_CLEAR
            
            DRSLAVE_START: begin
            
                if(ARADDR > 32'h1ff && ARADDR <= 32'hfff && ARSIZE < 3'b100)
                begin
                
                    RID = ARID;
                    case(ARBURST)
                    
                        2'b00: begin
                        
                            readdata_address = ARADDR;
                            case(ARSIZE)
                            
                                3'b000: begin
                                
                                    RDATA[7 : 0] = slave_memory[readdata_address];
                                
                                end
                                
                                3'b001: begin
                                
                                    RDATA[7 : 0]  = slave_memory[readdata_address];
                                    RDATA[15 : 8] = slave_memory[readdata_address + 1];
                                
                                end
                                
                                3'b010: begin
                                
                                    RDATA[7 : 0]   = slave_memory[readdata_address];
                                    RDATA[15 : 8]  = slave_memory[readdata_address + 1];
                                    RDATA[23 : 16] = slave_memory[readdata_address + 2];
                                    RDATA[31 : 24] = slave_memory[readdata_address + 3];
                                
                                end
                            
                            endcase//ARSIZE
                        
                        end//Fixed
                        
                        2'b01: begin
                        
                            
                        
                        end
                    
                    endcase//ARBURST
                
                end//end if
            
            end//DRSLAVE_START
        
        endcase//DRState
    
    end
    
endmodule
