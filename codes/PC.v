module PC
(
    clk_i,
    rst_i,
    start_i,
    stall_i,
    PCWrite_i,
    pc_i,
    pc_o,
    MemStall_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;
input               stall_i, MemStall_i;
input               PCWrite_i;
input   [31:0]      pc_i;
output  [31:0]      pc_o;

// Wires & Registers
reg     [31:0]      pc_o;


always@(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        pc_o <= 32'b0;
    end  
    else begin
        if (~stall_i && PCWrite_i && ~MemStall_i) begin
            if(start_i)
                pc_o <= pc_i;
            else
                pc_o <= 32'b0;
        end
    end
end

endmodule
