module MATRIX_MULT (
    input               clk,
    input               rst_n,
    input               in_valid,
    input        [3:0]  in_data,
    output reg          out_valid,
    output reg  [12:0] out_data
);

    localparam S_IDLE = 2'd0;
    localparam S_LOAD = 2'd1;
    localparam S_CALC = 2'd2;
    localparam S_OUT  = 2'd3;

    reg [1:0] state;
    reg [7:0] in_oh;
    reg [3:0] out_oh;

    reg [3:0] A0, A1, A2, A3;
    reg [8:0] M00, M01, M10, M11;

    wire sel_a1;
    assign sel_a1 = in_oh[6] | in_oh[7];

    wire [3:0] ma0;
    wire [3:0] ma1;
    assign ma0 = sel_a1 ? A1 : A0;
    assign ma1 = sel_a1 ? A3 : A2;

    wire [7:0] p0;
    wire [7:0] p1;
    DW02_mult #(.A_width(4), .B_width(4)) u_p0 (.A(ma0), .B(in_data), .TC(1'b0), .PRODUCT(p0));
    DW02_mult #(.A_width(4), .B_width(4)) u_p1 (.A(ma1), .B(in_data), .TC(1'b0), .PRODUCT(p1));

    wire [8:0] acc0;
    wire [8:0] acc1;
    assign acc0 = in_oh[7] ? M01 : M00;
    assign acc1 = in_oh[7] ? M11 : M10;

    wire [8:0] sum0;
    wire [8:0] sum1;
    DW01_add #(.width(9)) u_sum0 (.A(acc0), .B({1'b0,p0}), .CI(1'b0), .SUM(sum0), .CO());
    DW01_add #(.width(9)) u_sum1 (.A(acc1), .B({1'b0,p1}), .CI(1'b0), .SUM(sum1), .CO());

    wire [12:0] M00e;
    wire [12:0] M01e;
    wire [12:0] M10e;
    wire [12:0] M11e;
    assign M00e = {4'd0, M00};
    assign M01e = {4'd0, M01};
    assign M10e = {4'd0, M10};
    assign M11e = {4'd0, M11};

    wire [12:0] six00;
    wire [12:0] sev01;
    wire [12:0] d00_w;
    DW01_add #(.width(13)) u_six00 (.A(M00e<<2), .B(M00e<<1), .CI(1'b0), .SUM(six00), .CO());
    DW01_sub #(.width(13)) u_sev01 (.A(M01e<<3), .B(M01e), .CI(1'b0), .DIFF(sev01), .CO());
    DW01_add #(.width(13)) u_d00 (.A(six00), .B(sev01), .CI(1'b0), .SUM(d00_w), .CO());

    wire [12:0] fiv00;
    wire [12:0] d01_w;
    DW01_add #(.width(13)) u_fiv00 (.A(M00e<<2), .B(M00e), .CI(1'b0), .SUM(fiv00), .CO());
    DW01_add #(.width(13)) u_d01 (.A(fiv00), .B(M01e<<1), .CI(1'b0), .SUM(d01_w), .CO());

    wire [12:0] six10;
    wire [12:0] sev11;
    wire [12:0] d10_w;
    DW01_add #(.width(13)) u_six10 (.A(M10e<<2), .B(M10e<<1), .CI(1'b0), .SUM(six10), .CO());
    DW01_sub #(.width(13)) u_sev11 (.A(M11e<<3), .B(M11e), .CI(1'b0), .DIFF(sev11), .CO());
    DW01_add #(.width(13)) u_d10 (.A(six10), .B(sev11), .CI(1'b0), .SUM(d10_w), .CO());

    wire [12:0] fiv10;
    wire [12:0] d11_w;
    DW01_add #(.width(13)) u_fiv10 (.A(M10e<<2), .B(M10e), .CI(1'b0), .SUM(fiv10), .CO());
    DW01_add #(.width(13)) u_d11 (.A(fiv10), .B(M11e<<1), .CI(1'b0), .SUM(d11_w), .CO());

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            in_oh <= 8'b0000_0001;
            out_oh <= 4'b0001;
            out_valid <= 1'b0;
            out_data <= 13'd0;
        end
        else begin
            case (state)
            S_IDLE: begin
                out_valid <= 1'b0;
                out_data <= 13'd0;
                out_oh <= 4'b0001;
                if (in_valid) begin
                    A0 <= in_data;
                    in_oh <= 8'b0000_0010;
                    state <= S_LOAD;
                end
                else begin
                    in_oh <= 8'b0000_0001;
                end
            end
            S_LOAD: begin
                out_valid <= 1'b0;
                out_data <= 13'd0;
                if (in_oh[1]) A1 <= in_data;
                if (in_oh[2]) A2 <= in_data;
                if (in_oh[3]) A3 <= in_data;
                if (in_oh[4]) begin
                    M00 <= {1'b0,p0};
                    M10 <= {1'b0,p1};
                end
                if (in_oh[5]) begin
                    M01 <= {1'b0,p0};
                    M11 <= {1'b0,p1};
                end
                if (in_oh[6]) begin
                    M00 <= sum0;
                    M10 <= sum1;
                end
                if (in_oh[7]) begin
                    M01 <= sum0;
                    M11 <= sum1;
                end
                in_oh <= in_oh << 1;
                if (in_oh[7]) state <= S_CALC;
            end
            S_CALC: begin
                out_valid <= 1'b1;
                out_data <= d00_w;          // first element, D00
                out_oh <= 4'b0010;
                state <= S_OUT;
            end
            S_OUT: begin
                out_valid <= 1'b1;
                out_data <= ({13{out_oh[1]}} & d01_w)
                          | ({13{out_oh[2]}} & d10_w)
                          | ({13{out_oh[3]}} & d11_w);
                out_oh <= out_oh << 1;
                if (out_oh[3]) state <= S_IDLE;
            end
            default: begin
                state <= S_IDLE;
            end
            endcase
        end
    end

endmodule