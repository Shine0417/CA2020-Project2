module MUX_Forwarding
(
    data00_i,
    data01_i,
    data10_i,
    Forward_i,
    data_o 
);

`define ID_EX 2'b00
`define EX_MEM 2'b10
`define MEM_WB 2'b01

input   [31:0]      data00_i , data01_i , data10_i;
input   [ 1:0]      Forward_i;
output  [31:0]      data_o;

reg     [31:0]      data_o;

always @(*) begin
    case (Forward_i)
        `ID_EX:   data_o = data00_i;
        `EX_MEM:  data_o = data10_i;
        `MEM_WB:  data_o = data01_i;
    endcase
end

endmodule