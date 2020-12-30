module Pipeline_Register
(
    clk_i,
    start_i,
    stall_i,
    flush_i,
    pc_i,
    data_i,
    pc_o,
    data_o
);

input                clk_i, start_i;
input                stall_i, flush_i;
input   [ 31:0]      pc_i;
input   [n-1:0]      data_i;
output  [ 31:0]      pc_o;
output  [n-1:0]      data_o;

reg     [n-1:0]      data_o;
reg     [ 31:0]     pc_o;

parameter n = 1;


always @(posedge start_i) begin
    data_o <= 0; 
end

always @(posedge clk_i) begin
    if (flush_i == 1)
        data_o <= 0;
    else if (stall_i == 1)
        data_o <= data_o;
    else
        data_o <= data_i;

    pc_o <= pc_i;
end

endmodule
