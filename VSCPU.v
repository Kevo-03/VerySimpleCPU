`timescale 1ns / 1ps

module VSCPU (clk, rst, data_fromRAM, wrEn, addr_toRAM, data_toRAM);
  input clk, rst;
  output reg wrEn;
  input [31:0] data_fromRAM;
  output reg [31:0] data_toRAM;
  output reg [13:0] addr_toRAM;
  
  reg [2:0] st, stN;
  reg [13:0] PC, PCN;
  reg [31:0] IW, IWN;
  reg [31:0] R1, R1N;
  
  always @(posedge clk) begin
    st <= stN;
    PC <= PCN;
    IW <= IWN;
    R1 <= R1N;
  end
  
  always @ * begin
   if (rst) begin
     stN = 3'd0;
     PCN = 14'd0;
   end
   else begin
     wrEn = 1'b0;
     PCN = PC;
     IWN = IW;
     stN = 3'dx;
     addr_toRAM= 14'hX;
     data_toRAM= 32'hX;
     R1N= 32'hX;

     case (st) 
     3'd0: begin // S0: Fetch State
       addr_toRAM = PC;
       stN = 3'd1;
     end
     3'd1: begin // S1: Decode State
       IWN = data_fromRAM;
       if(data_fromRAM[31:28] == 4'b0000)//ADD
       begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
       end
       if(data_fromRAM[31:28] == 4'b0001)//ADDi
       begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
       end
       if(data_fromRAM[31:28] == 4'b1000)//CP
       begin
         addr_toRAM = data_fromRAM[13:0];
         stN = 3'd2;
       end
       if(data_fromRAM[31:28] == 4'b1001)//CPi only 1 state needed except fetch state
       begin
         wrEn = 1'b1;
         addr_toRAM = data_fromRAM[27:14];
         data_toRAM = data_fromRAM[13:0];
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if(data_fromRAM[31:28] == 4'b1010)//CPI
       begin
         addr_toRAM = data_fromRAM[13:0];
         stN = 3'd2;
       end
       if(data_fromRAM[31:28] == 4'b1011)//CPIi
       begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
       end
       if(data_fromRAM[31:28] == 4'b1100)//BZJ
       begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
       end
       if(data_fromRAM[31:28] == 4'b1101)//BZJi
       begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
       end
       if(data_fromRAM[31:28] == 4'b0011)//NANDi
       begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
       end
       if(data_fromRAM[31:28] == 4'b0010)//NAND
       begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
       end
       if(data_fromRAM[31:28] == 4'b0100)//SRL
       begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
       end
       if(data_fromRAM[31:28] == 4'b0101)//SRLi
       begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
       end
       if(data_fromRAM[31:28] == 4'b0110)//LT
        begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
        end
       if(data_fromRAM[31:28] == 4'b0111)//LTi
        begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
        end
       if(data_fromRAM[31:28] == 4'b1110)//MUL
       begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
       end
       if(data_fromRAM[31:28] == 4'b1111)//MULi
       begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
       end
     end
     3'd2: begin // S2: Decode/Execute State
       if(IW[31:28] == 4'b0000)//ADD
       begin
         R1N = data_fromRAM;
         addr_toRAM = IW[13:0];
         stN = 3'd3;
       end
       if (IW[31:28]==4'b0001) begin // ADDi
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = data_fromRAM + IW[13:0];
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if (IW[31:28]==4'b1000) begin // CP
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = data_fromRAM;
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if(IW[31:28] == 4'b1010)// CPI
       begin
         addr_toRAM = data_fromRAM;
         stN=3'd3;
       end
       if(IW[31:28] == 4'b1011)// CPIi
       begin
         R1N = data_fromRAM;
         addr_toRAM = IW[13:0];
         stN = 3'd3;
       end
       if (IW[31:28]==4'b1100) begin // BZJ
         R1N=data_fromRAM;
         addr_toRAM = IW[13:0];
         stN = 3'd3;
       end
       if (IW[31:28]==4'b1101) begin // BZJi
         PCN = (data_fromRAM + IW[13:0]);
         stN = 3'd0;
       end
       if(IW[31:28] == 4'b0011)//NANDi
       begin
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = ~(data_fromRAM & IW[13:0]);
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if(IW[31:28] == 4'b0010)//NAND
       begin
         R1N = data_fromRAM;
         addr_toRAM = IW[13:0];
         stN = 3'd3;
       end
       if(IW[31:28] == 4'b0100)//SRL
       begin
         R1N = data_fromRAM;
         addr_toRAM = IW[13:0];
         stN = 3'd3;
       end
       if(IW[31:28] == 4'b0101)//SRLi
       begin
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = (IW[13:0] < 6'd32) ? (data_fromRAM >> IW[13:0]) : (data_fromRAM << (IW[13:0] - 6'd32));
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if(IW[31:28] == 4'b0110)//LT
        begin
         R1N = data_fromRAM;
         addr_toRAM = IW[13:0];
         stN = 3'd3;
        end
       if(IW[31:28] == 4'b0111)//LTi
       begin
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = (data_fromRAM < IW[13:0]) ? 32'd1 : 32'd0;
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if(IW[31:28] == 4'b1110)//MUL
       begin
         R1N = data_fromRAM;
         addr_toRAM = IW[13:0];
         stN = 3'd3;
       end
       if(IW[31:28] == 4'b1111)//MULi
       begin
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = (data_fromRAM * IW[13:0]);
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
     end
     3'd3: begin // S3: Execute State
       if(IW[31:28] == 4'b0000)//ADD
       begin
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = data_fromRAM + R1;
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if (IW[31:28]==4'b1100) begin // BZJ
         if (data_fromRAM == 0)
            PCN=R1;
         else
            PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if(IW[31:28] == 4'b0010)//NAND
       begin
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = ~(data_fromRAM & R1);
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if(IW[31:28] == 4'b0100)//SRL
       begin
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = (data_fromRAM < 6'd32) ? (R1 >> data_fromRAM) : (R1 << (data_fromRAM - 6'd32));
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if(IW[31:28] == 4'b0110)//LT
       begin
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = (R1 < data_fromRAM) ? 32'd1 : 32'd0;
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if(IW[31:28] == 4'b1110)//MUL
       begin
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = (R1 * data_fromRAM);
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if(IW[31:28] == 4'b1010)// CPI
       begin
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = data_fromRAM;
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       if(IW[31:28] == 4'b1011)// CPIi
       begin
         wrEn = 1'b1;
         addr_toRAM = R1;
         data_toRAM = data_fromRAM;
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
     end
     endcase
   end // else
 end // always 	
endmodule

module blram(clk, rst, we, addr, din, dout);
  parameter SIZE = 14, DEPTH = 2**SIZE;

  input clk;
  input rst;
  input we;
  input [SIZE-1:0] addr;
  input [31:0] din;
  output reg [31:0] dout;

  reg [31:0] mem [DEPTH-1:0];

  always @(posedge clk) begin
    dout <= #1 mem[addr[SIZE-1:0]];
    if (we)
      mem[addr[SIZE-1:0]] <= #1 din;
  end 
endmodule

