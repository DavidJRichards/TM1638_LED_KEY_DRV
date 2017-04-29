// TM1638_LED_KEY_DRV.v
// TM1638_LED_KEY_DRV()
//
// TM1638 LED KEY BOARD using driver
// mainly aitendo board
//
// twitter:@manga_koji
// hatena: id:mangakoji http://mangakoji.hatenablog.com/
// GitHub :@mangakoji
//2017-04-30sa  :1st

module TM1638_LED_KEY_DRV #(
      parameter C_FCK = 48_000_000  // Hz
    , parameter C_FSCLK = 1_000     // Hz
    , parameter C_FPS   =   250     // cycle(Hz)
)(
      input                 CK_i
    , input tri1            XARST_i
    , input tri0 [ 6 :0]    DAT0_SEGS_i
    , input tri0 [ 6 :0]    DAT1_SEGS_i
    , input tri0 [ 6 :0]    DAT2_SEGS_i
    , input tri0 [ 6 :0]    DAT3_SEGS_i
    , input tri0 [ 6 :0]    DAT4_SEGS_i
    , input tri0 [ 6 :0]    DAT5_SEGS_i
    , input tri0 [ 6 :0]    DAT6_SEGS_i
    , input tri0 [ 6 :0]    DAT7_SEGS_i
    , input tri0 [ 7 :0]    DOTS_i
    , input tri0 [ 7 :0]    LEDS_i
    , input tri0 [31 :0]    DAT_i
    , input tri0 [ 7 :0]    SUP_DIGITS_i
    , input tri0            DAT_XDATSEG_i
    , input tri0            MISO_i
    , output                MOSI_o
    , output                MOSI_EN_o
    , output                SCLK_o
    , output                SS_o
    , output    [ 7:0]      KEYS_o
) ;
    function time log2;             //time is reg unsigned [63:0]
        input time value ;
    begin
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end endfunction


    //
    // ctl part
    //

    // clock divider
    //
    // if there is remainder ,round up
    localparam C_HALF_DIV_LEN = 
        C_FCK / (C_FSCLK * 2) 
        + 
        ((C_FCK % (C_FSCLK * 2)) ? 1 : 0) 
    ;
    localparam C_HALF_DIV_W = log2( C_HALF_DIV_LEN ) ;
    reg EN_HSCLK ;
    reg EN_SCLK ;
    reg EN_XSCLK ;
    wire EN_CK ;
    reg [C_HALF_DIV_W-1 :0] H_DIV_CTR ;
    reg                     DIV_CTR ;
    wire    H_DIV_CTR_cy ;
    assign H_DIV_CTE_cy = &(H_DIV_CTR | ~(C_HALF_DIV_LEN-1)) ;
    always @(posedge CK_i or negedge XARST_i) 
        if (~ XARST_i) begin
            H_DIV_CTR <= 'd0 ;
            DIV_CTR  <= 1'd0 ;
            EN_HSCLK <= '1b0 ;
            EN_SCLK  <= '1b0 ;
            EN_XSCLK <= '1b0 ;
        end else begin
            EN_HSCLK <= H_DIV_CTR_cy ;
            EN_SCLK  <= H_DIV_CTR_cy & ~ DIV_CTR ;
            EN_XSCLK <= H_DIV_CTR_cy &   DIV_CTR ;
            if (H_DIV_CTR_cy) begin
                H_DIV_CTR <= 'd0  ;
                DIV_CTR  <= ~ DIV_CTR ;
            end else begin
                H_DIV_CTR <= H_DIV_CTR + 'd1 ;
            end 
        end
    assign EN_CK = EN_XSCLK ;

    // gen cyclic FRAME_request
    //
    // fps define
    // SCLK CK count = C_HALF_DIV_LEN * 2
    // FCK / SCLK / FPS = SCLK clocks
    localparam C_FRAME_SCLK_N = C_FCK / (C_HALF_DIV_LEN * C_FPS) ;
    localparam C_F_CTR_W = log2( C_FRAME_SCLK_N ) ;
    reg [C_F_CTR_W-1:0] F_CTR ;
    reg                 FRAME_REQ ;
    wire                F_CTR_cy ;
    assign F_CTR_cy = &(F_CTR | ~( C_FRAME_SCLK_N-1)) ;
    always @(posedge CK_i or negedge XARST_i) 
        if (~ XARST_i) begin
            F_CTR <= 'd0 ;
            FRAME_REQ ;
        end else if (EN_CK) begin
            FRAME_REQ <= F_CTR_cy ;
            if (F_CTR_cy)
                F_CTR<= 'd0 ;
            else
                F_CTR <= F_CTR + 1 ;
        end


    // inter byte seqenser
    //
    wire BYTE_req ;//??
    localparam S_STARTUP    = 'hFF ;
    localparam S_IDLE       =   0 ;
    localparam S_LOAD       =   1 ;
    localparam S_BIT0       = 'h20 ;
    localparam S_BIT1       = 'h20 ;
    localparam S_BIT2       = 'h20 ;
    localparam S_BIT3       = 'h20 ;
    localparam S_BIT4       = 'h20 ;
    localparam S_BIT5       = 'h20 ;
    localparam S_BIT6       = 'h20 ;
    localparam S_BIT7       = 'h20 ;
    localparam S_FINISH     = 'h3F ;


    reg [7:0]   BYTE_STATE ;
    always @(posedge CK_i or negedge XARST_i) 
        if (~ XARST_i) begin
            BYTE_STATE <= S_STARTUP ;
        end else if (EN_CK) begin
    


    // frame sequenser
    //
//    localparam S_STARTUP    = 'hFF ;
//    localparam S_IDLE       =   0 ;
//    localparam S_LOAD       =   1 ;
    localparam S_SEND_SET   =   2 ;
    localparam S_LED_ADR_SET=   4
    localparam S_LED_0L     = 'h10 ;
    localparam S_LED_0H     = 'h11 ;
    localparam S_LED_1L     = 'h12 ;
    localparam S_LED_1H     = 'h13 ;
    localparam S_LED_2L     = 'h14 ;
    localparam S_LED_2H     = 'h15 ;
    localparam S_LED_3L     = 'h16 ;
    localparam S_LED_2H     = 'h17 ;
    localparam S_LED_2L     = 'h18 ;
    localparam S_LED_4H     = 'h19 ;
    localparam S_LED_4L     = 'h1A ;
    localparam S_LED_5H     = 'h1B ;
    localparam S_LED_5L     = 'h1C ;
    localparam S_LED_6H     = 'h1D ;
    localparam S_LED_7L     = 'h1E ;
    localparam S_LED_7H     = 'h1F ;
    localparam S_KEY_ADR_SET = 'h05 ;
    localparam S_KEY0      = 'h20 ;
    localparam S_KEY1      = 'h21 ;
    localparam S_KEY2      = 'h22 ;
    localparam S_KEY3      = 'h23 ;
    
    reg [7:0]   FRAME_STATE ;
    always @(posedge CK_i or negedge XARST_i) 
        if (~ XARST_i) begin
            FRAME_STATE <= S_STARTUP ;
        end else if (EN_CK) begin
            case (FRAME_STATE)
                S_STARTUP    : begin
                    FRAME_STATE <= S_IDLE
                end
                S_IDLE       : begin
                    if ( FRAME_REQ ) begin
                        FRAME_STATE <= S_LOAD ;
                    end 
                end
                S_LOAD       : begin
                    if ( 
                end
               S_SEND_SET   : begin
                
            end
               S_LED_ADR_SET: begin
                
                end
                S_LED_0L     : begin
                
            end
               S_LED_0H     : begin
                
            end
               S_LED_1L     : begin
                
            end
               S_LED_1H     : begin
                
            end
               S_LED_2L     : begin
                
            end
               S_LED_2H     : begin
                
            end
               S_LED_3L     : begin
                
            end
               S_LED_2H     : begin
                
            end
               S_LED_2L     : begin
                
            end
               S_LED_4H     : begin
                
            end
               S_LED_4L     : begin
                
            end
               S_LED_5H     : begin
                
            end
               S_LED_5L     : begin
                
            end
               S_LED_6H     : begin
                
            end
               S_LED_7L     : begin
                
            end
               S_LED_7H     : begin
                
            end
               S_KEY_ADR_SET : begin
                
            end
               S_KEY0      : begin
                
            end
               S_KEY1      : begin
                
            end
               S_KEY2      : begin
                
            end
               S_KEY3     : begin
                
            end
               S_FINISH     : begin
                
            end
            endcase
        end
    
    
    
    // main data part
    //
    //


    // endcoder for  LED7-segment
    //   a 
   // f     b
   //    g
   // e     c
   //    d
    function [6:0] f_seg_enc ;
        input sup_now ;
        input [3:0] octet;
    begin
        if (sup_now)
            f_seg_enc = 7'b1000000 ;
        else
          case( octet )
                              //  gfedcba
            4'h0 : f_seg_enc = 7'b0111111 ; //0
            4'h1 : f_seg_enc = 7'b0000110 ; //1
            4'h2 : f_seg_enc = 7'b1011011 ; //2
            4'h3 : f_seg_enc = 7'b1001111 ; //3
            4'h4 : f_seg_enc = 7'b1100110 ; //4
            4'h5 : f_seg_enc = 7'b1101101 ; //5
            4'h6 : f_seg_enc = 7'b1111101 ; //6
            4'h7 : f_seg_enc = 7'b0100111 ; //7
            4'h8 : f_seg_enc = 7'b1111111 ; //8
            4'h9 : f_seg_enc = 7'b1101111 ; //9
            4'hA : f_seg_enc = 7'b1110111 ; //a
            4'hB : f_seg_enc = 7'b1111100 ; //b
            4'hC : f_seg_enc = 7'b0111001 ; //c
            4'hD : f_seg_enc = 7'b1011110 ; //d
            4'hE : f_seg_enc = 7'b1111001 ; //e
            4'hF : f_seg_enc = 7'b1110001 ; //f
            default : f_seg_enc = 7'b1000000 ; //-
          endcase
    end endfunction
    
    assign = f_seg_enc(sup_now , octet_seled ) ;




    reg [ 7 :0] KEYS ;
    always @(posedge CK_i or negedge XARST_i) 
        KEYS <= 8'd0 ;
        else if ( EN_SCLK_D )
            case (FRAME_STATE)
                S_KEY0 : 
                    if ( BYTE_STATE == S_BIT0)
                        KEYS[7] <= MISO_i ;
                    else if(BYTE_STATE == S_BIT1)
                        KEYS[3] <= MISO_i ;
                S_KEY1 : 
                    if ( BYTE_STATE == S_BIT0)
                        KEYS[6] <= MISO_i ;
                    else if(BYTE_STATE == S_BIT1)
                        KEYS[2] <= MISO_i ;
                S_KEY2 : 
                    if ( BYTE_STATE == S_BIT0)
                        KEYS[5] <= MISO_i ;
                    else if(BYTE_STATE == S_BIT1)
                        KEYS[1] <= MISO_i ;
                S_KEY3 : 
                    if ( BYTE_STATE == S_BIT0)
                        KEYS[4] <= MISO_i ;
                    else if(BYTE_STATE == S_BIT1)
                        KEYS[0] <= MISO_i ;
            endcase
    assign KEYS_o = KEYS ;

endmodule
