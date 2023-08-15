// Load Store Unit

module lsu
    import core_pkg::opcode_t;
    import core_pkg::load_funct3_t;
    import core_pkg::store_funct3_t;
# (
    parameter DATA_WIDTH = 32
) (
    input  logic [6:0]            opcode,
    input  logic [2:0]            func3,

    input  logic [DATA_WIDTH-1:0] addr_in,     //from alu out
    output logic [DATA_WIDTH-1:0] addr_out,    //to dmem

    input  logic [DATA_WIDTH-1:0] data_s_in,   //data to be stored
    output logic [DATA_WIDTH-1:0] data_s_out,  //data to be stored manipulated by LSU

    input  logic [DATA_WIDTH-1:0] data_l_in,   //data to be loaded
    output logic [DATA_WIDTH-1:0] data_l_out,  //data to be loaded manipulated by LSU

    output logic [3:0]    mask
);

    opcode_t opcode_t;
    load_funct3_t load_funct3_t;
    store_funct3_t store_funct3_t;
 
    logic [7:0]            rdata_byte;
    logic [15:0]           rdata_hword;
    logic [DATA_WIDTH-1:0] rdata_word;

    // there is no masking in case of LOAD BYTES and LOAD HALF WORDS
    // for this, we have to have mask in register file

    assign addr_out = addr_in;

    always_comb
    begin
        if (opcode == opcode_t::LOAD)       //LOAD
        begin
            case(func3)
                load_funct3_t::LB, load_funct3_t::LBU:         //LB, LBU
                begin
                    case(addr_in[1:0])
                        2'b00:   rdata_byte = data_l_in[7:0];
                        2'b01:   rdata_byte = data_l_in[15:8];
                        2'b10:   rdata_byte = data_l_in[23:16];
                        2'b11:   rdata_byte = data_l_in[31:24];
                        default: rdata_byte = '0;
                    endcase
                end

                load_funct3_t::LH, load_funct3_t::LHU:         //LH, LHU
                begin
                    case(addr_in[1])
                        1'b0:    rdata_hword = data_l_in[15:0];
                        1'b1:    rdata_hword = data_l_in[31:16];
                        default: rdata_hword = '0;
                    endcase
                end

                load_funct3_t::LW:
                begin
                    rdata_word = data_l_in;
                end

                default:
                begin
                    rdata_byte  = '0;
                    rdata_hword = '0;
                    rdata_word  = '0;
                end
            endcase
        end
        else
        begin
            rdata_byte  = '0;
            rdata_hword = '0;
            rdata_word  = '0;
        end
    end

    always_comb begin
        if (opcode == opcode_t::LOAD)
        begin
            case(func3)
                load_funct3_t::LB :  data_l_out = {{24{rdata_byte[7]}},   rdata_byte };
                load_funct3_t::LBU:  data_l_out = {{24{1'b0}},            rdata_byte };
                load_funct3_t::LH :  data_l_out = {{16{rdata_hword[15]}}, rdata_hword};
                load_funct3_t::LHU:  data_l_out = {{16{1'b0}},            rdata_hword};
                load_funct3_t::LW :  data_l_out = {                       rdata_word };
                default           :  data_l_out = '0;
            endcase
        end
        else
        begin
            data_l_out = '0;
        end
    end

    always_comb
    begin
        if (opcode == opcode_t::STORE)
        begin
            case(func3)
                store_funct3_t::SB:    //SB
                begin
                    case(addr_in[1:0])
                        2'b00:
                        begin
                            data_s_out[7:0] = data_s_in[7:0];
                            mask            = 4'b0001;
                        end
                        2'b01:
                        begin
                            data_s_out[15:8] = data_s_in[15:8];
                            mask             = 4'b0010;
                        end
                        2'b10:
                        begin
                            data_s_out[23:16] = data_s_in[23:16];
                            mask              = 4'b0100;
                        end
                        2'b11:
                        begin
                            data_s_out[31:24] = data_s_in[31:24];
                            mask              = 4'b1000;
                        end
                        default:
                        begin
                            data_s_out = '0;
                            mask       = 4'b0000;
                        end
                    endcase
                end
                store_funct3_t::SH:    //SH
                begin
                    case(addr_in[1])
                        1'b0:
                        begin
                            data_s_out[15:0] = data_s_in[15:0];
                            mask             = 4'b0011;
                        end
                        1'b1:
                        begin
                            data_s_out[31:16] = data_s_in[31:16];
                            mask              = 4'b1100;
                        end
                        default:
                        begin
                            data_s_out = '0;
                            mask       = '0;
                        end
                    endcase
                end
                store_funct3_t::SW:    //SW
                begin
                    data_s_out = data_s_in;
                    mask       = 4'b1111;
                end
                default:
                begin
                    data_s_out = '0;
                    mask       = '0;
                end
            endcase
        end
        else
        begin
            data_s_out = '0;
            mask       = '0;
        end
    end

endmodule: lsu