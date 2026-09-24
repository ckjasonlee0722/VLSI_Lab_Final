`ifdef RTL
    `define CYCLE_TIME 5.0
`endif
`ifdef GATE
    `define CYCLE_TIME 5.0
`endif

module PATTERN(
    output reg clk,
    output reg rst_n,
    output reg in_valid,
    output reg [3:0] in_data,
    input wire out_valid,
    input wire [12:0] out_data
);

//===========================================
// Clock Generation
//===========================================
real CYCLE = `CYCLE_TIME;
always	#(CYCLE/2.0) clk = ~clk;

//===========================================
// integer & reg declaration
//===========================================
integer i, j, k;
integer PATNUM = 200;
integer pat_cnt;
integer local_latency;
integer total_latency = 0;
integer input_file, output_file;
real golden_ans;


//===========================================
// Initial Block for Test Pattern Generation
//===========================================
initial begin
    // Open input and output files
    input_file = $fopen("../00_TESTBED/input.txt", "r");
    output_file = $fopen("../00_TESTBED/output.txt", "r");
    
    if (input_file == 0) begin
        $display("\033[31mFailed to open input.txt\033[0m");
        $finish;
    end
    if (output_file == 0) begin
        $display("\033[31mFailed to open output.txt\033[0m");
        $finish;
    end

    // Reset the DUT
    reset_task();

    // Run through all patterns
    for (pat_cnt = 1; pat_cnt <= PATNUM; pat_cnt = pat_cnt + 1) begin
        local_latency = 0;
        input_data_task();
        wait_out_task();
        check_ans_task();
        total_latency = total_latency + local_latency;
        $display("\033[32m        PATTERN %d Passed!         \033[0m", pat_cnt);
        repeat($urandom_range(2, 5)) @(negedge clk);
    end

    pass_task();
end


//================================================================
//  TASK
//================================================================
task reset_task; begin
	rst_n = 1'b1;
	in_valid = 1'b0;
    in_data = 'bx;
	force clk = 1'b0;
	#(0.5);
	rst_n = 1'b0;
	#(100); // CHECK: All output signals should be reset after the reset signal is asserted. 
	if (out_valid !== 1'b0 || out_data !== 'b0) begin
		$display("\033[31mRESET FAIL \033[0m");
        $display(" out_valid = %b, out_data = %h", out_valid, out_data);
		$display("==========================================================================================");
        #(100);
		$finish;
	end
	rst_n = 1'b1;
	#(30);
	release clk;
end endtask

task input_data_task; begin
    @(negedge clk);
    in_valid = 1'b1;

    for (i = 0; i < 8; i = i + 1) begin
        k = $fscanf(input_file, "%d", in_data);
        @(negedge clk);
    end

    in_valid = 1'b0;
    in_data = 'bx;
end endtask


task wait_out_task; begin
    while (out_valid !== 1'b1) begin
        if (local_latency > 1000) begin
            $display("\033[31m        PATTERN %d Failed > 1000 cycles latency!         \033[0m", pat_cnt);
            $display("==========================================================================================");
            #(100);
            $finish;
        end
        local_latency = local_latency + 1;
        @(negedge clk);
    end
end endtask

task check_ans_task; begin
    for(i = 0; i < 4; i = i + 1) begin
        k = $fscanf(output_file, "%d", golden_ans);
        if (out_data !== golden_ans) begin
            $display("\033[31m        PATTERN %d Failed!         \033[0m", pat_cnt);
            $display("out_data = %d, golden_ans = %d", out_data, golden_ans);
            $display("==========================================================================================");
            #(100);
            $finish;
        end
        @(negedge clk);
    end
end endtask

task pass_task; begin
    $display("*************************************************************************");
    $display("*                Congratulations!                                       *");
    $display("*                Your execution cycles = %5d cycles                   *", total_latency);
    $display("*                Your clock period = %.1f ns                            *", CYCLE);
    $display("*************************************************************************");
	$display("==========================================================================================");
    $finish;
end endtask

always @(negedge clk) begin
	if(out_valid === 1'b0 && rst_n === 1'b1) begin
		if(out_data !== 0) begin
			$display("\033[31m \033[5m out_valid == 1'b0         out_data !==0 \033[0m");
			$display("==========================================================================================");
			$finish;
		end
	end
end

always @(*) begin
	if(out_valid === 1'b1) begin
		if(in_valid === 1'b1) begin
			$display("\033[31m \033[5m  out_valid == 1'b1      in_valid == 1'b1  \033[0m");
			$display("==========================================================================================");
			$finish;
		end
	end
end


endmodule