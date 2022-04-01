//------------------------------------------------------//
//- Digital IC Design 2021                              //
//-                                                     //
//- Final Project: FP_MUL                               //
//------------------------------------------------------//
`timescale 1ns/10ps

//`include "FP_MUL.v"
`include "MY_FP.v"

module TEST;

parameter CYCLE=50.0;
parameter SIM_CYCLE=200;

reg         CLK, RESET;
reg         ENABLE;
reg   [7:0] DATA_IN;
wire  [7:0] DATA_OUT;
wire        READY;
reg  [63:0] A, B; //FP input
reg  [63:0] Z; //FP_MUL output
reg  [63:0] C; //Expect FP_MUL output
reg  [31:0] err_count;
reg  [31:0] sim_count;
reg  [31:0] err_count_s;
reg  [31:0] err_count_e;
reg  [31:0] err_count_f;
integer     i;
reg [31:0] s,e,f; 

FP_MUL FP_MUL(.CLK(CLK), .RESET(RESET), .ENABLE(ENABLE), 
              .DATA_IN(DATA_IN), 
              .DATA_OUT(DATA_OUT), .READY(READY)); 

always #(CYCLE/2.0) CLK=~CLK;

initial begin
$fsdbDumpfile("FP_MUL.fsdb");
$fsdbDumpvars;
$fsdbDumpMDA;

CLK=0; RESET=0; 
ENABLE=0;
DATA_IN=0;
A=0; B=0; Z=0; C=0; s=0; e=0; f=0;
err_count=0; err_count_s=0; err_count_e=0; err_count_f=0;

@(negedge CLK) RESET=1;
@(negedge CLK) RESET=0;

for(i=0; i <= SIM_CYCLE; i=i+1) begin     
  //Give Pattern
  fp_patten;
  //Check Result 
  fp_check;
  repeat (2) @(negedge CLK); //wait 2 clock cycles
end

if(err_count !=0) 
begin
  $display("\n\n**********************");
  $display("Simulation Fail       ");
  $display("**********************\n\n"); 
end else begin
  $display("\n\n**********************");
  $display("Simulation OK         ");
  $display("**********************\n\n"); 
end
#10 $finish;
end

//--TASK: FP Patern Generation ---------------------------------------------//
task fp_patten;

   real        A_real, B_real, C_real, D_real, E_real, F_real; 
    reg  [7:0] IN_A [0:7];
    reg  [7:0] IN_B [0:7];
integer        sim_time;
integer        i;

begin 

  ENABLE=1'b0;
  DATA_IN=0;
  
  //Generate Random Input
  sim_time=$time;
  C_real=$random(sim_time);
  D_real=$random(sim_time);
  E_real=$random(sim_time);
  F_real=$random(sim_time);

  A_real=C_real/D_real;
  B_real=E_real/F_real;

  A=$realtobits(A_real);
  B=$realtobits(B_real);
  
  {IN_A[7],IN_A[6],IN_A[5],IN_A[4],IN_A[3],IN_A[2],IN_A[1],IN_A[0]}=A;
  {IN_B[7],IN_B[6],IN_B[5],IN_B[4],IN_B[3],IN_B[2],IN_B[1],IN_B[0]}=B;

  //Input Data to FP_MUL
  for(i=0; i <= 7; i=i+1) begin
    @(negedge CLK) begin
        ENABLE=1'b1;
		DATA_IN = IN_A[i];
    end
  end

  for(i=0; i <= 7; i=i+1) begin
    @(negedge CLK) begin
        ENABLE=1'b1;
        DATA_IN = IN_B[i];
    end    
  end

  @(negedge CLK) ENABLE=1'b0;

end 
endtask 
//----------------------------------------------------------------//

//--TASK----------------------------------------------------------//
task fp_check;

   real        checkA, checkB, checkZ;
    reg  [7:0] IN_Z [0:7];
integer        i;

begin
  //Get Data from FP_MUL
  @(posedge READY) begin
     for(i=0; i <= 7; i=i+1) begin
        @(negedge CLK) IN_Z[i] = DATA_OUT;
     end
  end 

  //Check Results
  checkA = $bitstoreal(A);
  checkB = $bitstoreal(B);
  checkZ = checkA * checkB; //FP MUL
  C = $realtobits(checkZ);
  //Z = {IN_Z[7],IN_Z[6],IN_Z[5],IN_Z[4],IN_Z[3],IN_Z[2],IN_Z[1],IN_Z[0]};
  Z = {IN_Z[0],IN_Z[1],IN_Z[2],IN_Z[3],IN_Z[4],IN_Z[5],IN_Z[6],IN_Z[7]};
  //Display Debug Information
  fp_show; 
  if( C[51:0] != Z[51:0]) begin //If answer is wrong
      err_count_f = err_count_f + 1'b1;
 //     $display("Float_Error at %t", $time);
  end
  else
  f = f +1;


  if( C[62:52] != Z[62:52]) begin //If answer is wrong
      err_count_e = err_count_e + 1'b1;
 //     $display("Exp_Error at %t", $time);
  end
  else
  e = e +1;


  if( C[63] != Z[63]) begin //If answer is wrong
      err_count_s = err_count_s + 1'b1;
 //     $display("Sign_Error at %t", $time);
  end
  else begin
  s = s + 1;
  end

  if( C != Z) begin //If answer is wrong
      err_count = err_count + 1'b1;
 //     $display("Sign_Error at %t", $time);
  end



end

endtask
//----------------------------------------------------------------//
//initial #5000 $finish;
//--TASK----------------------------------------------------------//
task fp_show;
begin 
  $display("\n");
  $display("********************************************************************");
  $display("(%+f) * (%+f) = %+f", $bitstoreal(A), $bitstoreal(B), $bitstoreal(C));
  $display("A=%b_%b_%b", A[63], A[62:52], A[51:0]);
  $display("B=%b_%b_%b", B[63], B[62:52], B[51:0]);
  $display("------------------- Your Result ------------------------------------");
  $display("Z=%b_%b_%b", Z[63], Z[62:52], Z[51:0]);
  $display("------------------- Correct Result ---------------------------------");
  $display("C=%b_%b_%b", C[63], C[62:52], C[51:0]);
  $display("********************************************************************");
  $display("---------------Total  Error Pattern -----------------------");
  $display("Sign  bit Error   Pattern = %d",err_count_s);
  $display("Exp   bit Error   Pattern = %d",err_count_e);
  $display("Float bit Error   Pattern = %d",err_count_f);
  $display("********************************************************************");
end 
endtask 
//----------------------------------------------------------------//

endmodule
