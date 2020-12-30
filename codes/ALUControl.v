module ALU_Control
(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);

`define AND  10'b0000000_111
`define XOR  10'b0000000_100
`define sll  10'b0000000_001
`define add  10'b0000000_000
`define sub  10'b0100000_000
`define mul  10'b0000001_000
`define addi  3'b000
`define srai  3'b101
`define lw    3'b010
`define sw    3'b010

// Interface
input   [9:0]      funct_i;
input   [1:0]      ALUOp_i;
output  [2:0]      ALUCtrl_o;

reg     [2:0]      ALUCtrl_o;

// Control
always @(*) begin
    if(ALUOp_i == 2'b11) begin
        case(funct_i[2:0])
            `addi: ALUCtrl_o = 6;
            `srai: ALUCtrl_o = 7;
        endcase
    end
    else if(ALUOp_i == 2'b10) begin
        case(funct_i)
            `AND: ALUCtrl_o = 0;
            `XOR: ALUCtrl_o = 1;
            `sll: ALUCtrl_o = 2;
            `add: ALUCtrl_o = 3;
            `sub: ALUCtrl_o = 4;
            `mul: ALUCtrl_o = 5;
        endcase
    end
    else if(ALUOp_i == 2'b00) begin
        case(funct_i[2:0])
            `lw: ALUCtrl_o = 3;
            `sw: ALUCtrl_o = 3;
        endcase
    end
end

endmodule
