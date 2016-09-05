module decode (
        
        input wire                rst,
        
        input wire[`InstAddrBus]  pc_in,
        input wire[`InstAddrBus]  inst_in,

        input wire[`RegBus]       src1_data_in,
        input wire[`RegBus]       src2_data_in,

        //forwarding
        input wire[`RegAddrBus] ex_dest_addr_in,
        input wire[`RegBus]     ex_dest_data_in,
        input wire              ex_wreg_in,

        input wire[`RegAddrBus] mem_dest_addr_in,
        input wire[`RegBus]     mem_dest_data_in,
        input wire              mem_wreg_in,


        output reg                src1_read_out,
        output reg                src2_read_out,
        output reg[`RegAddrBus]   src1_addr_out,
        output reg[`RegAddrBus]   src2_addr_out,

        output reg[`AluOpBus]     aluop_out,
        output reg[`AluSelBus]    alusel_out,
        output reg[`RegBus]       src1_data_out,
        output reg[`RegBus]       src2_data_out,
        output reg[`RegAddrBus]   dest_addr_out,
        output reg                wreg_out

    );
    
    // opnum
    wire[5:0] op  = inst_in[31:26];
    wire[5:0] op2 = inst_in[10:6];
    // opfunc
    wire[5:0] op3 = inst_in[5:0];
    wire[4:0] op4 = inst_in[20:16];

    // register for immediate number
    reg[`RegBus]  imm;

    reg inst_valid;

    // translate instructions
    always @( * ) begin
        if (rst == `RstEnable) begin
            aluop_out     <= `NOP_OP;
            alusel_out    <= `RES_NOP;
            dest_addr_out <= `NOPRegAddr;
            wreg_out      <= `False;
            inst_valid    <= `InstValid;
            src1_read_out <= `False;
            src2_read_out <= `False;
            src1_addr_out <= `NOPRegAddr;
            src2_addr_out <= `NOPRegAddr;
            imm           <= `ZeroWord;
        end else begin
            aluop_out     <= `NOP_OP;
            alusel_out    <= `RES_NOP;
            dest_addr_out <= inst_in[15:11];
            wreg_out      <= `False;
            inst_valid    <= `InstInvalid;
            src1_read_out <= `False;
            src2_read_out <= `False;
            src1_addr_out <= inst_in[25:21];
            src2_addr_out <= inst_in[20:16];
            imm           <= `ZeroWord;
            case (op)
                `SPECIAL: begin
                    case (op2)
                        5'b00000: begin
                            case (op3)
                                `AND: begin
                                    wreg_out      <= `True;
                                    aluop_out     <= `AND_OP;
                                    alusel_out    <= `RES_LOGIC;
                                    src1_read_out <= `True;
                                    src2_read_out <= `True;
                                    inst_valid    <= `InstValid;
                                end
                                `OR:  begin
                                    wreg_out      <= `True;
                                    aluop_out     <= `OR_OP;
                                    alusel_out    <= `RES_LOGIC;
                                    src1_read_out <= `True;
                                    src2_read_out <= `True;
                                    inst_valid    <= `InstValid; 
                                end
                                `XOR: begin
                                    wreg_out      <= `True;
                                    aluop_out     <= `XOR_OP;
                                    alusel_out    <= `RES_LOGIC;
                                    src1_read_out <= `True;
                                    src2_read_out <= `True;
                                    inst_valid    <= `InstValid;
                                end
                                `NOR: begin
                                    wreg_out      <= `True;
                                    aluop_out     <= `NOR_OP;
                                    alusel_out    <= `RES_LOGIC;
                                    src1_read_out <= `True;
                                    src2_read_out <= `True;
                                    inst_valid    <= `InstValid;
                                end
                                `SLLV: begin
                                    wreg_out      <= `True;
                                    aluop_out     <= `SLL_OP;
                                    alusel_out    <= `RES_SHIFT;
                                    src1_read_out <= `True;
                                    src2_read_out <= `True;
                                    inst_valid    <= `InstValid;
                                end
                                `SRLV: begin
                                    wreg_out      <= `True;
                                    aluop_out     <= `SRL_OP;
                                    alusel_out    <= `RES_SHIFT;
                                    src1_read_out <= `True;
                                    src2_read_out <= `True;
                                    inst_valid    <= `InstValid; 
                                end
                                `SRAV: begin
                                    wreg_out      <= `True;
                                    aluop_out     <= `SRA_OP;
                                    alusel_out    <= `RES_SHIFT;
                                    src1_read_out <= `True;
                                    src2_read_out <= `True;
                                    inst_valid    <= `InstValid;
                                end
                                `SYNC: begin
                                    wreg_out      <= `False;
                                    aluop_out     <= `NOP_OP;
                                    alusel_out    <= `RES_NOP;
                                    src1_read_out <= `False;
                                    src2_read_out <= `True;
                                    inst_valid    <= `InstValid;
                                end
                                default: begin 
                                end
                            endcase
                        end
                    endcase
                end
                `ANDI:   begin
                    wreg_out      <= `True;
                    aluop_out     <= `AND_OP;
                    alusel_out    <= `RES_LOGIC;
                    src1_read_out <= `True;
                    src2_read_out <= `False;
                    //Sign Extend
                    imm           <= {16'h0, inst_in[15:0]};
                    dest_addr_out <= inst_in[20:16];
                    inst_valid    <= `InstValid;
                end
                `ORI:   begin
                    wreg_out      <= `True;
                    aluop_out     <= `OR_OP;
                    alusel_out    <= `RES_LOGIC;
                    src1_read_out <= `True;
                    src2_read_out <= `False;
                    //Sign Extend
                    imm           <= {16'h0, inst_in[15:0]};
                    dest_addr_out <= inst_in[20:16];
                    inst_valid    <= `InstValid;
                end
                `XORI:   begin
                    wreg_out      <= `True;
                    aluop_out     <= `XOR_OP;
                    alusel_out    <= `RES_LOGIC;
                    src1_read_out <= `True;
                    src2_read_out <= `False;
                    //Sign Extend
                    imm           <= {16'h0, inst_in[15:0]};
                    dest_addr_out <= inst_in[20:16];
                    inst_valid    <= `InstValid;
                end
                `LUI:   begin
                    wreg_out      <= `True;
                    aluop_out     <= `OR_OP;
                    alusel_out    <= `RES_LOGIC;
                    src1_read_out <= `True;
                    src2_read_out <= `False;
                    //Sign Extend
                    imm           <= {inst_in[15:0], 16'h0};
                    dest_addr_out <= inst_in[20:16];
                    inst_valid    <= `InstValid;
                end
                `PREF:   begin
                    wreg_out      <= `False;
                    aluop_out     <= `NOR_OP;
                    alusel_out    <= `RES_NOP;
                    src1_read_out <= `False;
                    src2_read_out <= `False;
                    inst_valid    <= `InstValid;
                end
                default: begin
                end
            endcase
            if (inst_in[31:21] == 11'b00000000000) begin
                case (op3) 
                    `SLL: begin
                        wreg_out      <= `True;
                        aluop_out     <= `SLL_OP;
                        alusel_out    <= `RES_SHIFT;
                        src1_read_out <= `False;
                        src2_read_out <= `True;
                        imm[4:0]      <= inst_in[10:6];
                        dest_addr_out <= inst_in[15:11];
                        inst_valid    <= `InstValid;
                    end
                    `SRL: begin
                        wreg_out      <= `True;
                        aluop_out     <= `SRL_OP;
                        alusel_out    <= `RES_SHIFT;
                        src1_read_out <= `False;
                        src2_read_out <= `True;
                        imm[4:0]      <= inst_in[10:6];
                        dest_addr_out <= inst_in[15:11];
                        inst_valid    <= `InstValid;
                    end
                    `SRA: begin
                        wreg_out      <= `True;
                        aluop_out     <= `SRA_OP;
                        alusel_out    <= `RES_SHIFT;
                        src1_read_out <= `False;
                        src2_read_out <= `True;
                        imm[4:0]      <= inst_in[10:6];
                        dest_addr_out <= inst_in[15:11];
                        inst_valid    <= `InstValid;
                    end
                endcase
            end
        end
    end

    // src1
    always @( * ) begin
        if (rst == `RstEnable) begin
            src1_data_out <= `ZeroWord;
        //exe first    
        end else if (src1_read_out == `True 
            && ex_wreg_in == `True 
            && ex_dest_addr_in == src1_addr_out) 
        begin
            src1_data_out <= ex_dest_data_in;
        //then mem
        end else if (src1_read_out == `True 
            && mem_wreg_in == `True 
            && mem_dest_addr_in == src1_addr_out) 
        begin
            src1_data_out <= mem_dest_data_in;
        end else if (src1_read_out == `True) begin
            src1_data_out <= src1_data_in;
        end else if (src1_read_out == `False) begin
            src1_data_out <= imm;
        end else begin
            src1_data_out <= `ZeroWord;
        end
    end

    // src2
    always @( * ) begin
        if (rst == `RstEnable) begin
            src2_data_out <= `ZeroWord;
        //exe first    
        end else if (src2_read_out == `True 
            && ex_wreg_in == `True 
            && ex_dest_addr_in == src2_addr_out) 
        begin
            src2_data_out <= ex_dest_data_in;
        //then mem
        end else if (src2_read_out == `True 
            && mem_wreg_in == `True 
            && mem_dest_addr_in == src2_addr_out) 
        begin
            src2_data_out <= mem_dest_data_in;
        end else if (src2_read_out == `True) begin
            src2_data_out <= src2_data_in;
        end else if (src2_read_out == `False) begin
            src2_data_out <= imm;
        end else begin
            src2_data_out <= `ZeroWord;
        end
    end

endmodule