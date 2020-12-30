module Imm_Gen
(
    data_i,
    data_o
);

input   [31:0]      data_i;
output  [31:0]      data_o;

reg     [31:0]      data_o;

`define sw 7'b0100011
`define beq 7'b1100011

always @(*) begin
    case (data_i[6:0])
        `sw:        data_o = {{20{data_i[31]}}, data_i[31:25], data_i[11:7]};
        `beq:       data_o = {{20{data_i[31]}}, data_i[7], data_i[30:25], data_i[11:8]};
        default:    data_o = {{20{data_i[31]}}, data_i[31:20]};
    endcase
end

endmodule