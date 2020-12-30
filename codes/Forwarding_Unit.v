module Forwarding_Unit(
    clk_i,
    EX_rs1_i,
    EX_rs2_i,
    MEM_RegWrite_i,
    MEM_Rd_i,
    WB_RegWrite_i,
    WB_Rd_i,
    ForwardA_o,
    ForwardB_o
);

input               clk_i;
input   [4:0]       EX_rs1_i, EX_rs2_i, MEM_Rd_i, WB_Rd_i;
input               MEM_RegWrite_i, WB_RegWrite_i;

output  [1:0]       ForwardA_o, ForwardB_o;

reg     [1:0]       ForwardA_o, ForwardB_o;

always @(*) begin
    if (MEM_RegWrite_i && MEM_Rd_i && MEM_Rd_i == EX_rs1_i) ForwardA_o <= 2'b10; //EX hazard
    else if (WB_RegWrite_i && WB_Rd_i && WB_Rd_i == EX_rs1_i) ForwardA_o <= 2'b01; //MEM hazard
    else ForwardA_o <= 2'b00;

    if (MEM_RegWrite_i && MEM_Rd_i && MEM_Rd_i == EX_rs2_i) ForwardB_o <= 2'b10; //EX hazard
    else if (WB_RegWrite_i && WB_Rd_i && WB_Rd_i == EX_rs2_i) ForwardB_o <= 2'b01; // MEM hazard
    else ForwardB_o <= 2'b00;

end

endmodule
