module Hazard_Detection
(
    RDaddr_EX_i,
    RS1addr_ID_i,
    RS2addr_ID_i,
    RegWrite_EX_i,
    MemRead_EX_i,
    PCWrite_o,
    Stall_o,
    NoOp_o
);

input   [4:0]       RDaddr_EX_i, RS1addr_ID_i, RS2addr_ID_i;
input               RegWrite_EX_i, MemRead_EX_i;
output              PCWrite_o, Stall_o, NoOp_o;

reg                 PCWrite_o, Stall_o, NoOp_o;

always @(RDaddr_EX_i or RS1addr_ID_i or RS2addr_ID_i) begin
	if (MemRead_EX_i && (RDaddr_EX_i == RS1addr_ID_i || RDaddr_EX_i == RS2addr_ID_i)) begin
		PCWrite_o <= 0;
		Stall_o <= 1;
		NoOp_o <= 1;
	end
	else begin
		PCWrite_o <= 1;
		Stall_o <= 0;
		NoOp_o <= 0;
	end
end


endmodule