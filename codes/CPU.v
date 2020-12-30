module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

wire    [31:0]      address;
wire    [31:0]      new_address;
wire    [31:0]      branch_address;
wire    [31:0]      address_ID;
wire    [31:0]      PCSrc_address;
wire    [31:0]      ins, ins_ID, ins_EX, ins_MEM, ins_WB;	

wire    [ 1:0]      ALUOp, ALUOp_EX;
wire                RegWrite, RegWrite_EX, Registers_MEM, RegWrite_WB;
wire                ALUSrc, ALUSrc_EX;
wire    [31:0]      imm_gen_wire, imm_gen_wire_EX;
wire    [31:0]      read_data1, read_data1_EX;
wire    [31:0]      read_data2, read_data2_EX, read_data2_MEM;
wire    [31:0]      mux_wire;
wire    [31:0]      ALU_result, ALU_result_MEM, ALU_result_WB;
wire    [ 2:0]      ALU_control_wire;
wire                Zero;

// additional
wire                MemtoReg, MemtoReg_EX, MemtoReg_MEM;
wire                MemRead, MemRead_EX, MemRead_MEM;
wire                MemWrite, MemWrite_EX, MemWrite_MEM;
wire    [31:0]      data_memory_output, data_memory_output_WB;
wire    [31:0]      write_register;

//Forwarding
wire    [ 1:0]      Forward_A , Forward_B;
wire    [31:0]      MUX_ForwardA_out , MUX_ForwardB_out;

// Branch & Hazard Detection
wire                Branch;
wire                RS1eqRS2;
wire                PCWrite;
wire                Stall;
wire                NoOp;
wire                Flush;

//=====================================================================//
//============================== Modules ==============================//
//=====================================================================//

Pipeline_Register #(.n(32)) IF_ID (
    .clk_i      (clk_i),
    .start_i    (start_i),
    .stall_i    (Stall),
    .flush_i    (Flush),
    .pc_i       (address),
    .data_i     (ins),
    .pc_o       (address_ID),
    .data_o     (ins_ID)
);


Pipeline_Register #(.n(135)) ID_EX (
    .clk_i      (clk_i),
    .start_i    (start_i),
    .stall_i    (1'bx),
    .flush_i    (1'bx),
    .pc_i       (32'bx),
    .data_i     ({RegWrite, MemtoReg, MemRead, MemWrite, ALUOp, ALUSrc, read_data1, read_data2, imm_gen_wire, ins_ID}),
    .pc_o       (),
    .data_o     ({RegWrite_EX, MemtoReg_EX, MemRead_EX, MemWrite_EX, ALUOp_EX, ALUSrc_EX, read_data1_EX, read_data2_EX, imm_gen_wire_EX, ins_EX})
);


Pipeline_Register #(.n(100)) EX_MEM (
    .clk_i          (clk_i),
    .start_i        (start_i),
    .stall_i        (1'bx),
    .flush_i        (1'bx),
    .pc_i           (32'bx),
    .data_i         ({RegWrite_EX, MemtoReg_EX, MemRead_EX, MemWrite_EX, ALU_result, MUX_ForwardB_out, ins_EX}),
    .pc_o           (),
    .data_o         ({RegWrite_MEM, MemtoReg_MEM, MemRead_MEM, MemWrite_MEM, ALU_result_MEM, read_data2_MEM, ins_MEM})
);


Pipeline_Register #(.n(98)) MEM_WB (
    .clk_i          (clk_i),
    .start_i        (start_i),
    .stall_i        (1'bx),
    .flush_i        (1'bx),
    .pc_i           (32'bx),
    .data_i         ({RegWrite_MEM, MemtoReg_MEM, ALU_result_MEM, data_memory_output, ins_MEM}),
    .pc_o           (),
    .data_o         ({RegWrite_WB, MemtoReg_WB, ALU_result_WB, data_memory_output_WB, ins_WB})
);


Control Control(
    .Op_i           (ins_ID[6:0]),
    .NoOp_i         (NoOp),
    .RegWrite_o     (RegWrite),
    .MemtoReg_o     (MemtoReg),
    .MemRead_o      (MemRead),
    .MemWrite_o     (MemWrite),
    .ALUOp_o        (ALUOp),
    .ALUSrc_o       (ALUSrc),
    .Branch_o       (Branch)
);


Adder Add_PC(
    .data1_in       (address),
    .data2_in       (32'b100),
    .data_o         (new_address)
);


PC PC(
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .start_i        (start_i),
    .PCWrite_i      (PCWrite),
    .pc_i           (PCSrc_address),
    .pc_o           (address)
);


Instruction_Memory Instruction_Memory(
    .addr_i         (address), 
    .instr_o        (ins)
);


Registers Registers(
    .clk_i          (clk_i),
    .RS1addr_i      (ins_ID[19:15]),
    .RS2addr_i      (ins_ID[24:20]),
    .RDaddr_i       (ins_WB[11:7]),
    .RDdata_i       (write_register),
    .RegWrite_i     (RegWrite_WB), 
    .RS1data_o      (read_data1), 
    .RS2data_o      (read_data2) 
);


MUX_Forwarding MUX_ForwardA(
    .data00_i       (read_data1_EX),
    .data01_i       (write_register),
    .data10_i       (ALU_result_MEM),
    .Forward_i      (Forward_A),
    .data_o         (MUX_ForwardA_out)
);


MUX_Forwarding MUX_ForwardB(
    .data00_i       (read_data2_EX),
    .data01_i       (write_register),
    .data10_i       (ALU_result_MEM),
    .Forward_i      (Forward_B),
    .data_o         (MUX_ForwardB_out)
);


MUX32 MUX_ALUSrc(
    .data1_i        (MUX_ForwardB_out),
    .data2_i        (imm_gen_wire_EX),
    .select_i       (ALUSrc_EX),
    .data_o         (mux_wire)
);


Forwarding_Unit Forwarding_Unit(
    .clk_i          (clk_i),
    .EX_rs1_i       (ins_EX[19:15]),
    .EX_rs2_i       (ins_EX[24:20]),
    .MEM_RegWrite_i (RegWrite_MEM),
    .MEM_Rd_i       (ins_MEM[11:7]),
    .WB_RegWrite_i  (RegWrite_WB),
    .WB_Rd_i        (ins_WB[11:7]),
    .ForwardA_o     (Forward_A),
    .ForwardB_o     (Forward_B)
);


MUX32 REG_WRISrc(
    .data1_i        (ALU_result_WB),
    .data2_i        (data_memory_output_WB),
    .select_i       (MemtoReg_WB),
    .data_o         (write_register)
);


Imm_Gen Imm_Gen(
    .data_i         (ins_ID[31:0]),
    .data_o         (imm_gen_wire)
);
  

ALU ALU(
    .data1_i        (MUX_ForwardA_out),
    .data2_i        (mux_wire),
    .ALUCtrl_i      (ALU_control_wire),
    .data_o         (ALU_result),
    .Zero_o         (Zero)
);


ALU_Control ALU_Control(
    .funct_i        ({ins_EX[31:25], ins_EX[14:12]}),
    .ALUOp_i        (ALUOp_EX),
    .ALUCtrl_o      (ALU_control_wire)
);


Data_Memory Data_Memory(
    .clk_i          (clk_i), 
    .addr_i         (ALU_result_MEM), 
    .MemRead_i      (MemRead_MEM),
    .MemWrite_i     (MemWrite_MEM),
    .data_i         (read_data2_MEM),
    .data_o         (data_memory_output)
);


Hazard_Detection Hazard_Detection(
    .RDaddr_EX_i    (ins_EX[11:7]),
    .RS1addr_ID_i   (ins_ID[19:15]),
    .RS2addr_ID_i   (ins_ID[24:20]),
    .RegWrite_EX_i  (RegWrite_EX), 
    .MemRead_EX_i   (MemRead_EX),
    .PCWrite_o      (PCWrite),
    .Stall_o        (Stall),
    .NoOp_o         (NoOp)
);


Equal Equality_Compare(
    .data1_i        (read_data1),
    .data2_i        (read_data2),
    .result_o       (RS1eqRS2)
);


AND #(.n(1)) AND_Branch_Equality(
    .data1_i       (Branch),
    .data2_i       (RS1eqRS2),
    .data_o        (Flush)
);


Adder Add_PC_Imm(
    .data1_in       (imm_gen_wire << 1),
    .data2_in       (address_ID),
    .data_o         (branch_address)
);


MUX32 MUX_PCSrc(
    .data1_i        (new_address),
    .data2_i        (branch_address),
    .select_i       (Flush),
    .data_o         (PCSrc_address)
);


endmodule