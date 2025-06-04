`timescale 1ns / 1ps

module ALU1_tb;
  parameter INPUT = 8;
  
  reg [INPUT-1:0] OPA, OPB;
  reg CIN, CLK, RST, CE, MODE;
  reg [3:0] CMD;
  reg [1:0] VALID;
  wire [(INPUT*2)-1:0] RES;
  wire ERR, OFLOW, COUT, G, L, E;

  ALU1 #(.INPUT(INPUT)) dut (
    .OPA(OPA), .OPB(OPB),
    .CIN(CIN), .CLK(CLK),
    .RST(RST), .CMD(CMD),
    .CE(CE), .MODE(MODE),
    .VALID(VALID),
    .RES(RES), .ERR(ERR),
    .OFLOW(OFLOW), .COUT(COUT),
    .G(G), .L(L), .E(E)
  );

  initial CLK = 0;
  always #5 CLK = ~CLK;  // 10ns clock

  initial begin 
	  $dumpfile("dump.vcd");
	  $dumpvars(0,ALU1_tb);
end





  task reset;
    begin
      RST = 1;
      CE = 0;
      #10;
      RST = 0;
    end
  endtask

  task apply_inputs(input [3:0] cmd_i, input [INPUT-1:0] a, b, input cin_i);
    begin
      @(negedge CLK);
      CMD = cmd_i;
      OPA = a;
      OPB = b;
      CIN = cin_i;
      CE = 1;
    end
  endtask

  initial begin
    $display("Starting ALU Arithmetic Test (neg edge)...");
    reset;
    #30;
    MODE = 1;
    VALID = 2'b00;
    #30;

    apply_inputs(4'b0000,8'd1,8'd1,1'b0);
    @(negedge CLK);
    @(negedge CLK);
     
    VALID = 2'b11;
    apply_inputs(4'b1111,8'd50,8'd25,1'b0);
    
    #10;
    
    VALID = 2'b01;
    apply_inputs(4'b1101,8'd50,8'd25,1'b0);
    
    #10;
    
    VALID = 2'b10;
    apply_inputs(4'b1101,8'd50,8'd25,1'b0);
    
    #10;
    
    MODE = 0;
    #30;
    
    VALID = 2'b00;
    #10;
    
    VALID = 2'b11;
    apply_inputs(4'b1111,8'd50,8'd25,1'b0);
    
     #20;
     
     apply_inputs(4'b1100,8'hF0,8'hC8,1'b0);
     #20;
     apply_inputs(4'b1101,8'hF0,8'h63,1'b0);
     #20;
     
     VALID = 2'b01;

     apply_inputs(4'b0111,8'd50,8'd25,1'b0);
     #20;

     VALID = 2'b10;
     apply_inputs(4'b1000,8'd50,8'd25,1'b0);

     #20;

     CE = 0;
    $display("Arithmetic test complete.");
    #20;
    $finish;
  end

endmodule

