module ref_model_alu #(parameter INPUT = 8)(
    input  wire [INPUT-1:0]  OPA,
    input  wire [INPUT-1:0]  OPB,
    input  wire              CIN,
    input  wire              CLK,
    input  wire              RST,
    input  wire [3:0]        CMD,
    input  wire              CE,
    input  wire              MODE,
    input  wire [1:0]        VALID,

    output reg              EX_ERR,
    output reg [(INPUT*2)-1:0] EX_RES,
    output reg              EX_OFLOW,
    output reg              EX_COUT,
    output reg              EX_G,
    output reg              EX_L,
    output reg              EX_E
);

task automatic compute_results;
  input  [INPUT-1:0]  OPA;
  input  [INPUT-1:0]  OPB;
  input               CIN;
  input               RST;
  input  [3:0]        CMD;
  input               CE;
  input               MODE;
  input  [1:0]        VALID;

  output reg               ERR;
  output reg [(INPUT*2)-1:0] RES;
  output reg               OFLOW;
  output reg               COUT;
  output reg               G;
  output reg               L;
  output reg               E;

  reg signed [INPUT-1:0] signed_reg_OPA;
  reg signed [INPUT-1:0] signed_reg_OPB;
  reg [INPUT:0] temp_res;

  begin
    if (CE) begin
      if (RST) begin
        RES   = 0;
        ERR   = 0;
        OFLOW = 0;
        COUT  = 0;
        G     = 0;
        L     = 0;
        E     = 0;
        signed_reg_OPA = 0;
        signed_reg_OPB = 0;
      end else begin
        signed_reg_OPA = OPA;
        signed_reg_OPB = OPB;
	RES   = 0;
        ERR   = 0;
        OFLOW = 0;
        COUT  = 0;
        G     = 0;
        L     = 0;
        E     = 0;
	 if (MODE == 1'b1) begin // Arithmetic / Compare mode
          case (VALID)
            2'b11: begin
              case (CMD)
                4'b0000: begin
                  temp_res = OPA + OPB;
                  RES = temp_res;
                  COUT = temp_res[INPUT];
                end
                4'b0001: begin
                  temp_res = OPA - OPB;
                  RES = temp_res;
                  OFLOW = (OPA < OPB);
                end
                4'b0010: begin
                  temp_res = OPA + OPB + CIN;
                  RES = temp_res;
                  COUT = temp_res[INPUT];
                end
                4'b0011: begin
                  temp_res = OPA - OPB - CIN;
                  RES = temp_res;
                  OFLOW = ((OPA < OPB) || ((OPA == OPB) && (CIN == 1))) ? 1 : 0;
                end
                4'b1000: begin // Unsigned compare
                  E = (OPA == OPB);
                  G = (OPA > OPB);
                  L = (OPA < OPB);
                end
                4'b1001: RES = (OPA + 1) * (OPB + 1);
                4'b1010: RES = (OPA * 2) * OPB;
                4'b1011: begin // Signed add compare
                  RES[INPUT-1:0] = signed_reg_OPA + signed_reg_OPB;
                  OFLOW = (~signed_reg_OPA[INPUT-1] & ~signed_reg_OPB[INPUT-1] & RES[INPUT-1]) |
                          ( signed_reg_OPA[INPUT-1] &  signed_reg_OPB[INPUT-1] & ~RES[INPUT-1]);
                  E = (signed_reg_OPA == signed_reg_OPB);
                  G = (signed_reg_OPA > signed_reg_OPB);
                  L = (signed_reg_OPA < signed_reg_OPB);
                end
                4'b1100: begin // Signed subtract compare
                  RES[INPUT-1:0] = signed_reg_OPA - signed_reg_OPB;
                  OFLOW = ((signed_reg_OPA[INPUT-1] != signed_reg_OPB[INPUT-1]) &&
                           (RES[INPUT-1] != signed_reg_OPA[INPUT-1]));
                  E = (signed_reg_OPA == signed_reg_OPB);
                  G = (signed_reg_OPA > signed_reg_OPB);
                  L = (signed_reg_OPA < signed_reg_OPB);
                end
                default: begin
                  RES = 0;
                  OFLOW = 0;
                  ERR = 1;
                end
              endcase
            end

            2'b01: begin
              case (CMD)
                4'b0100: begin
                  temp_res = OPA + 1;
                  RES = temp_res;
                  COUT = temp_res[INPUT];
                end
                4'b0101: begin
                  temp_res = OPA - 1;
                  RES = temp_res;
                  OFLOW = (OPA == 0);
                end
                default: begin
                  RES = 0;
                  OFLOW = 0;
                  ERR = 1;
                end
              endcase
            end

            2'b10: begin
              case (CMD)
                4'b0110: begin
                  temp_res = OPB + 1;
                  RES = temp_res;
                  COUT = temp_res[INPUT];
                end
                4'b0111: begin
                  temp_res = OPB - 1;
                  RES = temp_res;
                  OFLOW = (OPB == 0);
                end
                default: begin
                  RES = 0;
                  OFLOW = 0;
                  ERR = 1;
                end
              endcase
            end

            default: begin
              RES = 0;
              ERR = 1;
            end
          endcase
        end else begin
	 // Logical / Bitwise mode
	 RES   = 0;
        ERR   = 0;
        OFLOW =0;
        COUT  = 0;
        G     = 0;
        L     = 0;
        E     = 0;
          case (VALID)
            2'b11: begin
              case (CMD)
                4'b0000: RES[INPUT-1:0] = OPA & OPB;
                4'b0001: RES[INPUT-1:0] = ~(OPA & OPB);
                4'b0010: RES[INPUT-1:0] = OPA | OPB;
                4'b0011: RES[INPUT-1:0] = ~(OPA | OPB);
                4'b0100: RES[INPUT-1:0] = OPA ^ OPB;
                4'b0101: RES[INPUT-1:0] = ~(OPA ^ OPB);
                4'b1100: begin
                  if (OPB[INPUT-1:$clog2(INPUT)+1] == 0)
                    ERR = 0;
                  else
                    ERR = 1;
                  RES[INPUT-1:0] = (OPA << OPB[$clog2(INPUT)-1:0]) |
                                   (OPA >> (INPUT - OPB[$clog2(INPUT)-1:0]));
                end
                4'b1101: begin
                  if (OPB[INPUT-1:$clog2(INPUT)+1] == 0)
                    ERR = 0;
                  else
                    ERR = 1;
                  RES[INPUT-1:0] = (OPA >> OPB[$clog2(INPUT)-1:0]) |
                                   (OPA << (INPUT - OPB[$clog2(INPUT)-1:0]));
                end
                default: begin
                  RES = 0;
                  ERR = 1;
                end
              endcase
            end

            2'b01: begin
              case (CMD)
                4'b0110: RES[INPUT-1:0] = ~OPA;
                4'b1000: RES[INPUT-1:0] = OPA >> 1;
                4'b1001: RES[INPUT-1:0] = OPA << 1;
                default: begin
                  RES = 0;
                  ERR = 1;
                end
              endcase
            end

            2'b10: begin
              case (CMD)
                4'b0111: RES[INPUT-1:0] = ~OPB;
                4'b1010: RES[INPUT-1:0] = OPB >> 1;
                4'b1011: RES[INPUT-1:0] = OPB << 1;
                default: begin
                  RES = 0;
                  ERR = 1;
                end
              endcase
            end

            default: begin
              RES = 0;
              ERR = 1;
            end
          endcase
        end
      end
    end
  end
endtask

always @(*) begin
        compute_results(
            OPA, OPB, CIN, RST, CMD, CE, MODE, VALID,
            EX_ERR, EX_RES, EX_OFLOW, EX_COUT, EX_G, EX_L, EX_E
        );
end

endmodule 

