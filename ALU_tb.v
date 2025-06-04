`include "main1.v"
`include "ref_model.v"


module ALU_testbench #(parameter INPUT = 8);
	


	reg [INPUT-1:0] OPA;
	reg [INPUT-1:0] OPB;
	reg CIN,CLK,CE,MODE;
	reg RST;
	reg [3:0] CMD;
	reg [1:0] VALID;
	

	//outputs from the DUT
	wire COUT,OFLOW,G,E,L,ERR;
	wire [(INPUT*2)-1:0] RES;
	
	//output from the ref model
	wire [(INPUT*2)-1:0] EX_RES;
	wire EX_COUT,EX_OFLOW;
	wire EX_G,EX_E,EX_L,EX_ERR;
	
	initial begin 
		CLK =0;
		forever #5 CLK = ~CLK;
	end
	
	//DUT inst
	ALU1 #(.INPUT(INPUT)) DUT(.OPA(OPA),.OPB(OPB),.CIN(CIN),.CLK(CLK),.CE(CE),.MODE(MODE),.RST(RST),.CMD(CMD),.VALID(VALID),.RES(RES),.COUT(COUT),.OFLOW(OFLOW),.G(G),.E(E),.L(L),.ERR(ERR));
	
	//reference model 
	ref_model_alu #(.INPUT(INPUT)) REF_MODEL(.OPA(OPA),.OPB(OPB),.CIN(CIN),.CE(CE),.MODE(MODE),.RST(RST),.CMD(CMD),.VALID(VALID),.EX_RES(EX_RES),.EX_ERR(EX_ERR),.EX_OFLOW(EX_OFLOW),.EX_COUT(EX_COUT),.EX_G(EX_G),.EX_L(EX_L),.EX_E(EX_E));

	initial begin 
		CE = 1;
		RST = 1;
		MODE = 0;
		CIN = 0;
		OPA = 8'h00;
		OPB = 8'h00;
		CMD = 4'h0;
		VALID = 2'b00;
		
		//reset
		@(posedge CLK);
		RST = 0;
		@(posedge CLK);

		MODE = 1;
		
		VALID = 2'b11;
		//test add
		OPA = 8'd1;OPB = 8'd1;CMD= 4'b0000;
		delay;
		check_results("ADD");

		VALID = 2'b00;
		OPA = 8'd1;OPB = 8'd1;CMD = 4'B0000;
		delay;
		 check_results("ADD w ERR");

		VALID = 2'b11;
		OPA = 8'd2; OPB=8'd2; CMD = 4'b1001;
		mul_delay;
		#3 check_results("MULL");


		OPA = 8'd255;OPB = 8'd255;CMD = 4'b1001;
		mul_delay;
		check_results("MULL");

	 	OPA = 8'd254;OPB=8'd254;CMD=4'b1001;
		mul_delay;
		check_results("MULL");
		

		OPA = 8'd0;OPB=8'd0;CMD = 4'b1001;
		mul_delay;
		check_results("MULL");
		
		
		OPA = 8'd3;OPB=8'd4;CMD = 4'b1010;
		mul_delay;
		check_results("MULL");
		
		OPA = 8'd1;OPB=8'd4;CMD = 4'b1010;
		mul_delay;
		check_results("MULL");

		OPA = 8'd2;OPB=8'd4;CMD = 4'b1010;
		mul_delay;
		check_results("MULL");

		OPA =-8'd127;OPB=-8'd1;CMD = 4'b1011;
		delay;
		check_results("signed add");

		OPA = -8'd128;OPB=-8'd1;CMD = 4'b1011;
                delay;
                check_results("signed add");
		
		OPA =-8'd64;OPB=-8'd63;CMD = 4'b1011;
                delay;
                check_results("signed add");
	
		OPA = 8'd127;OPB=-8'd1;CMD=4'b1100;
		delay;
		check_results("signed sub");

		OPA = -8'd128;OPB=8'd1;CMD=4'b1100;
		delay;
		check_results("signed sub");
		
		OPA = -8'd64;OPB=-8'd64;CMD=4'b1100;
		delay;
		check_results("signed sub");


		OPA = 8'd255;OPB=8'd254;CMD=4'b1010;
		mul_delay;
		check_results("MuL");
		#100;
		$finish;

		
	end
		
	task check_results;
		input [8*20-1:0] operation;
		
		begin 
			#3;
			$display("\n%s Operation:", operation);
           		 $display("Inputs: OPA=%d, OPB=%d, CIN=%b, CMD=%b, MODE=%b", 
                    	 OPA, OPB, CIN, CMD, MODE);
            
            // Check RES
            if (RES === EX_RES)
                $display("RES: PASS - Got %d", RES);
            else
                $display("RES: FAIL - Got %d, Expected %d", RES,EX_RES);
                
            // Check COUT
            if (COUT === EX_COUT)
                $display("COUT: PASS - Got %b", COUT);
            else
                $display("COUT: FAIL - Got %b, Expected %b", COUT, EX_COUT);
                
            // Check OFLOW
            if (OFLOW === EX_OFLOW)
                $display("OFLOW: PASS - Got %b", OFLOW);
            else
                $display("OFLOW: FAIL - Got %b, Expected %b", OFLOW, EX_OFLOW);
                
            // Check comparison flags
            if (G === EX_G && E === EX_E && L === EX_L)
                $display("Comparison flags: PASS - G=%b, E=%b, L=%b", G, E, L);
            else
                $display("Comparison flags: FAIL - Got G=%b,E=%b,L=%b Expected G=%b,E=%b,L=%b", 
                         G, E, L, EX_G, EX_E, EX_L);
                
            // Check ERR
            if (ERR === EX_ERR)
                $display("ERR: PASS - Got %b", ERR);
            else
                $display("ERR: FAIL - Got %b, Expected %b", ERR, EX_ERR);
        end
    endtask	
    	
    	task mul_delay;
		repeat (3) begin 
			@(posedge CLK);
		end
	endtask 

	task delay;
		repeat (2) begin 
			@(posedge CLK);
		end
	endtask
endmodule 

