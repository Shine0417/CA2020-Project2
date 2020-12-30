module Control
(
    Op_i,
    NoOp_i,
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    ALUOp_o,
    ALUSrc_o,
    Branch_o   
);

// Interface
input   [6:0]      Op_i;
input			   NoOp_i;
output             RegWrite_o;
output             MemtoReg_o;
output             MemRead_o;
output             MemWrite_o;
output  [1:0]      ALUOp_o;
output             ALUSrc_o;
output             Branch_o;

reg                RegWrite_o;
reg                MemtoReg_o;
reg                MemRead_o;
reg                MemWrite_o;
reg     [1:0]      ALUOp_o;
reg                ALUSrc_o;
reg                Branch_o;

// Control
always @(*) begin
    //default
    MemtoReg_o = 0;
    MemRead_o = 0;
    MemWrite_o = 0;
    Branch_o = 0;
    RegWrite_o = 1;

    if (NoOp_i == 1) begin
    	RegWrite_o = 0;
    	ALUOp_o = 0;
    	ALUSrc_o = 0;
    end
    else if(Op_i == 7'b0110011) begin // R-type
        ALUOp_o = 2'b10;
        ALUSrc_o = 0;
    end
    else if(Op_i == 7'b0010011) begin // addi and srai
        ALUOp_o = 2'b11;
        ALUSrc_o = 1;
    end
    else if(Op_i == 7'b0000011) begin // lw
        ALUOp_o = 2'b00;
        ALUSrc_o = 1;
        MemtoReg_o = 1;
        MemRead_o = 1;
    end
    else if(Op_i == 7'b0100011) begin // sw
        ALUOp_o = 2'b00;
        ALUSrc_o = 1;
        MemtoReg_o = 0;// dont care
        MemWrite_o = 1;
        RegWrite_o = 0;
    end
    else if(Op_i == 7'b1100011) begin // beq
    	ALUOp_o = 2'b01;
    	ALUSrc_o = 0;
	    Branch_o = 1;
	    RegWrite_o = 0;
	end
    else begin
        ALUOp_o = 2;
        ALUSrc_o = 0;
    end
end

endmodule
