//DD Project Verilog Submission
//Batch Number: 43
//Problem Statement: Design a Real Time Clock that displays the output HH:MM on four 7 Segment Displays



//D Flip Flop
module DFlipFlop(output reg Q,input D,clk,R); 
  always @ ( negedge clk or posedge R)
   //Implementing the Reset Condition
   if(R) Q=1'b0; 
   else Q=D;
endmodule

//JK Flip Flop
module JKFlipFlop(output Q,input J,K,clk,R); 
  wire JK;
  assign JK= ((J&~Q)|(~K&Q));
  DFlipFlop jk(Q,JK,clk,R);
endmodule


//Mod 5 counter to use in the 7490 IC Module
module Mod5Counter(input clk,R, output [2:0]Q); 
  JKFlipFlop A(Q[2],Q[1]&Q[0],1'b1,clk,R);
  JKFlipFlop B(Q[1],Q[0],Q[0],clk,R);
  JKFlipFlop C(Q[0],~Q[2],1'b1,clk,R);
endmodule

//Mod 2 counter to use in the 7490 IC module
module Mod2Counter(input clk,R,output Q); 
  JKFlipFlop A(Q,1'b1,1'b1,clk,R);
endmodule

//Mod 6 Counter using 7490 IC module
module Mod6Counter(input clk, R, output [3:0]Q);  
  IC_7490 a(clk, R | (Q[2] & Q[1]), R | (Q[2] & Q[1]),Q); 
endmodule

//Mod 3 Counter using 7490 IC module
module Mod3Counter(input clk, R, output [3:0]Q);  
    IC_7490 w( clk, R | (Q[2] ),R | (Q[2] ),Q); 
endmodule

//7490 IC Decade Counter Module
module  IC_7490(input clk,R1,R2,output [3:0]Q); 
  Mod5Counter a(Q[0], R1&R2, Q[3:1]); 
  Mod2Counter b(clk, R1&R2, Q[0]); 
endmodule  


//7447 Chip, 7 Segment Display Decoder, In behavioral
module SSDDecoder(input [3:0]nIn,output reg [6:0] ssOut);
// ssOut format {g,f,e,d,c,b,a}
  always @(nIn)
    case (nIn)
      4'd0: ssOut = 7'b0000001;
      4'd1: ssOut = 7'b1001111;
      4'd2: ssOut = 7'b0010010;
      4'd3: ssOut = 7'b0000110;
      4'd4: ssOut = 7'b1001100;
      4'd5: ssOut = 7'b0100100;
      4'd6: ssOut = 7'b1100000;
      4'd7: ssOut = 7'b0001111;
      4'd8: ssOut = 7'b0000000;
      4'd9: ssOut = 7'b0001100;
    endcase
endmodule

//The Clock Implementation using 7490 IC and its derivatives
//Time Format is H2H1:M2M1
module MainClockModule(clk, R, M1, M2, H1, H2,SSDM1,SSDM2,SSDH1,SSDH2); 
  input clk, R;
  output [3:0] M1;
  output [3:0] M2;
  output [3:0] H1;
  output [3:0] H2;
  output [6:0] SSDM1,SSDM2,SSDH1,SSDH2;    
  
  //Counters for H2H1:M2M1  
  IC_7490 a(clk, R,R, M1);
  Mod6Counter b (M1[3] & M1[0], R, M2);
  IC_7490 c(M2[2] & M2[0], R | (H1[2] & H2[1]),R|(H1[2] & H2[1]), H1);
  Mod3Counter d(H1[3] & H1[0], R| H1[2] & H2[1], H2); 
  
  //Sending 7 Segment Counter Display Outputs  
  SSDDecoder bcd1(M1, SSDM1);
  SSDDecoder bcd2(M2, SSDM2);
  SSDDecoder bcd3(H1, SSDH1);
  SSDDecoder bcd4(H2, SSDH2); 
                     
endmodule

//Test Bench Module
module TestBench;     
 reg R, clk;               
 wire [3:0] M1,M2,H1,H2;    
 wire [6:0] SSDM1,SSDM2,SSDH1,SSDH2;
 MainClockModule a1(clk, R, M1, M2, H1, H2,SSDM1,SSDM2,SSDH1,SSDH2);
   initial 
    begin
      //Initial Reset for all Counters
      R=1;            
      #50 clk=0;      
      #50 clk=1;
      R=0;
      #50 clk=0;
      //Creating Clock
      forever #50 clk=~clk; 
                          
    end
endmodule    
