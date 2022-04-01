//------------------------------------------------------//
//- Digital IC Design 2021                              //
//-                                                     //
//- Final Project: FP_MUL                               //
//------------------------------------------------------//
`timescale 1ns/10ps

module FP_MUL(CLK, RESET, ENABLE, DATA_IN, DATA_OUT, READY );



// I/O Ports
input         CLK; //clock signal
input         RESET; //sync. RESET=1
input         ENABLE; //input data sequence when ENABLE =1
input   [7:0] DATA_IN; //input data sequence
output  [7:0] DATA_OUT; //ouput data sequence

output        READY; //output data is READY when READY=1
reg           READY;




reg [4:0] counter;
reg [5:0] count;
reg [7:0] A [8:1];
reg [7:0] B [8:1];
reg [7:0] DATA_OUT; //ignore
reg [63:0] total_A;
reg [63:0] total_B;

reg s;           //sign bit
reg [10:0] exp;  //exponet bit
reg [105:0] float;
reg [104:0] float1;
reg [104:0] float2;
reg [104:0] float3;


//after 17 CLK DATA recieve finish 
//at the 48~55 CLK to out DATA
//Total CLK : 55 CLK per 1 cycle


//set counter for recieve IN_DATA
always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	begin
	counter <= 0;
	count <= 0;
	end	
	else if (count == 40 )
	begin
	counter <= 0;
	count <= 0;
	end
	else if (counter == 17)
	begin
	counter <= counter;
	count <= count +1;
	end
	else 
	begin
	counter <= counter + 1;
	count <= 0;
	end
end

//set READY's up time and down time
always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	READY <= 0;
	else if (count >= 31 && count <=38)
	READY <= 1;
	else
	READY <= 0;
end

//make A & B recieve data
always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	begin	
	A[1] <= 0;
	B[1] <= 0;
	A[2] <= 0;
	B[2] <= 0;
	A[3] <= 0;
	B[3] <= 0;
	A[4] <= 0;
	B[4] <= 0;
	A[5] <= 0;
	B[5] <= 0;
	A[6] <= 0;
	B[6] <= 0;
	A[7] <= 0;
	B[7] <= 0;
	A[8] <= 0;
	B[8] <= 0;
	end
	else if (ENABLE)
	begin
	A[counter] <= DATA_IN;
	B[counter-8] <= DATA_IN;
	end
end

//concate the all bit of IN_DATA 
always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	begin
	total_A <= 64'b0;
	total_B <= 64'b0;
	end
	else if (counter == 9)
	total_A <= {A[8],A[7],A[6],A[5],A[4],A[3],A[2],A[1]};
	else if (counter == 17)
	total_B <= {B[8],B[7],B[6],B[5],B[4],B[3],B[2],B[1]};
end

//generator the first bit of OUTPUT
always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	s <= 1'b0;
	else if ( total_A[63] == total_B[63] )
	s <= 1'b0;
	else
	s <= 1'b1;
end

//generator the exponent bits of OUTPUT
always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	exp <= 0;
	else if ( count == 1)
	exp <= (total_A[62:52] + total_B[62:52]) + 11'b10000000010; //this 11 bits is 2's 1022 (exp - 1022)
	else if ( count == 30 && float[105] == 0) 
	exp <= exp + 11'b11111111111; // this 11bits is 2's 1 (exp - 1)
end

//generator the float number of OUTPUT
always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	begin	
float  <= 0;
float1 <= 0;
float2 <= 0;
float3 <= 0;
	end
	else if ( count == 2 )
	begin
		if (total_B[0] == 1)	float1 <= {1'b1 , total_A[51:0]};		
		if (total_B[1] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 1);
	end
	else if ( count == 3)
	begin
		if (total_B[2] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 2);
		if (total_B[3] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 3);
	end
	else if ( count == 4 )
	begin
		if (total_B[4] == 1) 	float1 <= float1 + ({1'b1, total_A[51:0]} << 4);
		if (total_B[5] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 5);
	end
	else if ( count == 5 )
	begin
		if (total_B[6] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 6);
		if (total_B[7] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 7);
	end
	else if ( count == 6 )
	begin
		if (total_B[8] == 1) 	float1 <= float1 + ({1'b1, total_A[51:0]} << 8);
		if (total_B[9] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 9);
	end
	else if ( count == 7 )
	begin
		if (total_B[10] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 10);
		if (total_B[11] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 11);
	end

	else if ( count == 8 )
	begin
		if (total_B[12] == 1) 	float1 <= float1 + ({1'b1, total_A[51:0]} << 12);
		if (total_B[13] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 13);
	end
	else if ( count == 9 )
	begin
		if (total_B[14] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 14);
		if (total_B[15] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 15);
	end
	else if ( count == 10 )
	begin
		if (total_B[16] == 1) 	float1 <= float1 + ({1'b1, total_A[51:0]} << 16);	
		if (total_B[17] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 17);
	end
	else if ( count == 11 )
	begin
		if (total_B[18] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 18);
		if (total_B[19] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 19);
	end
	else if ( count == 12 )
	begin
		if (total_B[20] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 20);
		if (total_B[21] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 21);
	end
	else if ( count == 13 )
	begin
		if (total_B[22] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 22);
		if (total_B[23] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 23);
	end
	else if ( count == 14 )
	begin
		if (total_B[24] == 1) 	float1 <= float1 + ({1'b1, total_A[51:0]} << 24);	
		if (total_B[25] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 25);
	end
	else if ( count == 15 )
	begin
		if (total_B[26] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 26);
		if (total_B[27] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 27);
	end
	else if ( count == 16 )
	begin
		if (total_B[28] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 28);
		if (total_B[29] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 29);
	end
	else if ( count == 17 )
	begin
		if (total_B[30] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 30);
		if (total_B[31] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 31);
	end
	else if ( count == 18 )
	begin
		if (total_B[32] == 1) 	float1 <= float1 + ({1'b1, total_A[51:0]} << 32);
		if (total_B[33] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 33);
	end
	else if ( count == 19 )
	begin
		if (total_B[34] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 34);
		if (total_B[35] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 35);
	end
	else if ( count == 20 )
	begin
		if (total_B[36] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 36);
		if (total_B[37] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 37);
	end
	else if ( count == 21 )
	begin
		if (total_B[38] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 38);
		if (total_B[39] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 39);
	end
	else if ( count == 22 )
	begin
		if (total_B[40] == 1) 	float1 <= float1 + ({1'b1, total_A[51:0]} << 40);
		if (total_B[41] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 41);
	end
	else if ( count == 23 )
	begin
		if (total_B[42] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 42);
		if (total_B[43] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 43);
	end
	else if ( count == 24 )
	begin
		if (total_B[44] == 1) 	float1 <= float1 + ({1'b1, total_A[51:0]} << 44);
		if (total_B[45] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 45);
	end
	else if ( count == 25 )
	begin
		if (total_B[46] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 46);
		if (total_B[47] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 47);

	end
	else if ( count == 26 )
	begin
		if (total_B[48] == 1) 	float1 <= float1 + ({1'b1, total_A[51:0]} << 48);
		if (total_B[49] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 49);
	end
	else if ( count == 27 )
	begin
		if (total_B[50] == 1)	float1 <= float1 + ({1'b1, total_A[51:0]} << 50);
		if (total_B[51] == 1)	float2 <= float2 + ({1'b1, total_A[51:0]} << 51);
	end
	else if ( count == 28 )
	begin
		float3 <= ({1'b1, total_A[51:0]} << 52);
		float  <= float1 + float2;
	end
	else if ( count == 29 )
	begin
		float <= float + float3;
	end
	else if ( count == 30 && (float[105] == 0) )
	begin
	float <= float << 1;
	end
	else if ( count == 31)
	float[104:53] <= float[104:53] + float[52];
	else if ( count == 38)
	begin	
	float <= 0;
	float1 <= 0;
	float2 <= 0;
	float3 <= 0;
	end
end	

//concate all OUTPUT data
always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	begin
	DATA_OUT <= 7'b0;
	end
	else if (count==31)
	begin
	DATA_OUT  <= {s,exp[10:4]};

	end
	else if (count==32)
	begin
	DATA_OUT     <= {exp[3:0],float[104:101]};

	end
	else if (count==33)
	begin
	DATA_OUT    <= float[100:93];

	end
	else if (count==34)
	begin
	DATA_OUT     <= float[92:85];

	end
	else if (count==35)
	begin	
	DATA_OUT     <= float[84:77];

	end
	else if (count==36)
	begin
	DATA_OUT     <= float[76:69];

	end
	else if (count==37)
	begin
	DATA_OUT     <= float[68:61];

	end
	else if (count==38)
	begin	
	DATA_OUT    <=  float[60:53];

	end
end



endmodule
