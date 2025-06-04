module ALU1 #(parameter INPUT = 8)(input  wire [INPUT-1:0]  OPA,
    input  wire [INPUT-1:0]  OPB,
    input  wire              CIN,
    input  wire              CLK,
    input  wire              RST,
    input  wire [3:0]        CMD,
    input  wire              CE,
    input  wire              MODE,
    input  wire [1:0]        VALID,

    output reg               ERR,
    output reg [(INPUT*2)-1:0]  RES,
    output reg               OFLOW,
    output reg               COUT,
    output reg               G,
    output reg               L,
    output reg               E
);

reg signed [INPUT-1:0] signed_reg_OPA;
reg signed [INPUT-1:0] signed_reg_OPB;

//input temp reg 
reg [INPUT-1:0] temp_OPA;
reg [INPUT-1:0] temp_OPB;
reg temp_CIN;
reg [3:0] temp_CMD;
reg temp_MODE;
reg [1:0] temp_VALID;
reg [(INPUT*2)-1:0] buff1;  //buff for mul

always @(posedge CLK or posedge RST)begin 
	if(RST)begin 
		RES <= 16'b0;
		ERR <= 1'b0;
		OFLOW <= 1'b0;
		COUT <= 1'b0;
		G <= 1'b0;
		L <= 1'b0;
		E <= 1'b0;
		signed_reg_OPA <= 'd0;
		signed_reg_OPB <= 'd0;
		temp_OPA <= 'd0;
		temp_OPB <= 'd0;
		temp_CIN <= 'd0;
		temp_CMD <= 'd0;
		temp_MODE <= 'd0;
		temp_VALID <= 'd0;
		buff1 <= 'd0;
	end
	else begin 
		temp_OPA <= OPA;
		temp_OPB <= OPB;
		temp_CIN <= CIN;
		temp_CMD <= CMD;
		temp_MODE <= MODE;
		temp_VALID <= VALID;
		signed_reg_OPA <= OPA;
		signed_reg_OPB <= OPB;
	end
end

always @(posedge CLK)begin 
	if(CE)begin 
		if(temp_MODE == 1)begin
                	RES <= 0;
			ERR <= 1'b0;
			OFLOW <= 1'b0;
                	G <= 1'b0;
                	L <= 1'b0;
               		E <= 1'b0;	
			case(temp_VALID)
				2'b11:begin 
					case(temp_CMD)
					 4'b0000:begin
                               			 RES[(INPUT):0] <= temp_OPA + temp_OPB;
						end
					4'b0001:begin 
						 RES[(INPUT):0] <= temp_OPA - temp_OPB;
                               			 OFLOW <= (temp_OPA<temp_OPB) ? 1:0;
						end
					4'b0010:begin 
						RES[(INPUT):0] <= temp_OPA + temp_OPB + temp_CIN;
						end
					4'b0011:begin 
						 RES[(INPUT):0] <= temp_OPA - temp_OPB - temp_CIN;
                               			 OFLOW <= ((temp_OPA < temp_OPB) || ((temp_OPA == temp_OPB)&&(temp_CIN == 1))) ? 1: 0;
						end
					4'b1000:begin 
						if(temp_OPA == temp_OPB)begin
                                       		E <= 1;
                                       		G <= 0;
                                        	L <= 0;
                               		 end
                               			else if(temp_OPA > temp_OPB)begin
                                        	E <= 0;
                                        	G <= 1;
                                        	L <= 0;
                                	end
                                		else begin
                                       		 E <= 0;
                                        	 G <= 0;
                                        	 L <= 1;

                                	end
                       		 end
					4'b1001:begin 
						buff1 <= ((temp_OPA+1) * (temp_OPB+1));
						RES <= buff1;
                        			end
					4'b1010:begin 
						 buff1 <= ((temp_OPA << 1)*temp_OPB);
						 RES <= buff1;
                        			end
					4'b1011:begin 
						RES[INPUT-1:0] <= signed_reg_OPA + signed_reg_OPB;
                               			 if(signed_reg_OPA == signed_reg_OPB)begin
                                       		 E <= 1;
                                       		 G <= 0;
                                       		 L <= 0;
                               		 end
                                		else if(signed_reg_OPA > signed_reg_OPB)begin
                                        E <= 0;
                                        G <= 1;
                                        L <= 0;
                                end
                                else begin
                                        E <= 0;
                                        G <= 0;
                                        L <= 1;

                                end

                        end
				4'b1100:begin
                                RES[INPUT:0] <= signed_reg_OPA - signed_reg_OPB;
                                if(signed_reg_OPA == signed_reg_OPB)begin
                                        E <= 1;
                                        G <= 0;
                                        L <= 0;
                                end
                                else if(signed_reg_OPA > signed_reg_OPB)begin
                                        E <= 0;
                                        G <= 1;
                                        L <= 0;
                                end
                                else begin
                                        E <= 0;
                                        G <= 0;
                                        L <= 1;

                                end

                                end

					default: begin  RES <= 0;OFLOW <=0;ERR<=1;end
				endcase
			end
			2'b01:begin 
				case(temp_CMD)
				4'b0100:begin 
					RES[(INPUT):0] <= temp_OPA+1;
			 end
				4'b0101:begin 
					 RES[(INPUT):0] <= temp_OPA-1;
                                	OFLOW <= (temp_OPA == 0) ? 1:0;
                       		 end
				default: begin RES <= 0;OFLOW <= 0;ERR<=1;end
			endcase 
		end
		2'b10:begin 
			case(temp_CMD)
				4'b0110:begin 
					RES[(INPUT):0] <= temp_OPB+1;
                       		 end
				4'b0111:begin 
					 RES[(INPUT):0] <= temp_OPB - 1;
	                                OFLOW <= (temp_OPB == 0) ? 1:0;
                       			 end
				default:begin RES<=0;OFLOW<=0;ERR<=1;end
			endcase 
		end
		default: begin 
			RES <= 0;ERR <= 1;end
		endcase 

	end
 	else begin 
		RES <= 0;
                ERR <= 1'b0;
                OFLOW <= 1'b0;
                G <= 1'b0;
                L <= 1'b0;
                E <= 1'b0;
	case(temp_VALID)
		2'b11:begin
			 case(temp_CMD)
				4'b0000: RES[INPUT-1:0] <= temp_OPA & temp_OPB;
				4'b0001: RES[INPUT-1:0] <= ~(temp_OPA & temp_OPB);
				4'b0010: RES[INPUT-1:0] <= temp_OPA | temp_OPB;
				4'b0011: RES[INPUT-1:0] <= ~(temp_OPA | temp_OPB);
				4'b0100: RES[INPUT-1:0] <= temp_OPA ^ temp_OPB;
				4'b0101: RES[INPUT-1:0] <= ~(temp_OPA ^ temp_OPB);
				4'b1100:begin
					if(temp_OPB[INPUT-1:($clog2(INPUT)+1)] == 0)
						ERR <= 0;
					else 
						ERR <= 1;
					RES[INPUT-1:0] <= (temp_OPA << temp_OPB[$clog2(INPUT)-1:0]) | (temp_OPA >> (INPUT - temp_OPB[$clog2(INPUT)-1:0])); 
				end
				4'b1101:begin 
					 if(temp_OPB[INPUT-1:($clog2(INPUT)+1)] == 0)
						ERR <= 0;
					else 
						ERR <= 1;
					RES[INPUT-1:0] <= (temp_OPA >> temp_OPB[$clog2(INPUT)-1:0]) | (temp_OPA << (INPUT - temp_OPB[$clog2(INPUT)-1:0])); 
				end
				default :begin RES[INPUT-1:0] <= 0;ERR<=1;end
			endcase 
		end
		2'b01:begin 
			case(temp_CMD)
				4'b0110: RES[INPUT-1:0] <= ~temp_OPA;
				4'b1000: RES[INPUT-1:0] <= temp_OPA >> 1;
				4'b1001: RES[INPUT-1:0] <= temp_OPA << 1;
				default :begin RES[INPUT-1:0] <= 0;ERR<=1;
					end
			endcase
		end
		2'b10:begin 
			case(temp_CMD)
				4'b0111: RES[INPUT-1:0] <= ~temp_OPB;
				4'b1010: RES[INPUT-1:0] <= temp_OPB >> 1;
				4'b1011: RES[INPUT-1:0] <= temp_OPB << 1;
				default :begin RES[INPUT-1:0] <= 0;ERR<=1;
				end
			endcase 
			end
	default: begin RES[INPUT-1:0] <= 0;ERR <=1;end
	endcase 
	end
end
end

always@(RES) begin 
		if(CE)begin 
			COUT = 0; 
			case(temp_CMD)
				 4'b0000:begin 
				 COUT = RES[INPUT];
				 end
            			 4'b0010:begin 
				 COUT = RES[INPUT];
			  	 end
           			 4'b0100:begin 
				 COUT = RES[INPUT];
				 end
           			 4'b0110:begin 
				 COUT = RES[INPUT];
				end
				4'b1011:begin 
				OFLOW = ((~signed_reg_OPA[INPUT-1]&~signed_reg_OPB[INPUT-1]&RES[INPUT-1])|(signed_reg_OPA[INPUT-1]&signed_reg_OPB[INPUT-1]&~RES[INPUT-1]));
				end
				4'b1100:begin
				OFLOW = ((signed_reg_OPA[INPUT-1] != signed_reg_OPB[INPUT-1]) && (RES[INPUT-1] != signed_reg_OPA[INPUT-1]));
				end
				default: begin COUT = 0;end
			endcase
		end
	end
endmodule 

