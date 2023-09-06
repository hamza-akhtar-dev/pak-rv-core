// Hazard Detection Unit

module hdu
#(
) (
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    input  logic [4:0] rd_frm_mem,
    input  logic [4:0] rd_frm_wb,
    input  logic       rf_en_frm_mem,
    input  logic       rf_en_frm_wb,
    output logic [1:0] for_a,
    output logic [1:0] for_b
);

    // forwarding operand A
    always_comb
    begin
        if ((rs1 != 0) && (rs1 == rd_frm_mem) && rf_en_frm_mem)
        begin
            for_a = 2'b01;
        end
        else if ((rs1 != 0) && (rs1 == rd_frm_wb) && rf_en_frm_wb)
        begin
            for_a = 2'b10;
        end
        else
        begin
            for_a = 2'b00;
        end
    end

    // forwarding operand B
    always_comb
    begin
        if ((rs2 != 0) && (rs2 == rd_frm_mem) && rf_en_frm_mem)
        begin
            for_b = 2'b01;
        end
        else if ((rs2 != 0) && (rs2 == rd_frm_wb) && rf_en_frm_wb)
        begin
            for_b = 2'b10;
        end
        else
        begin
            for_b = 2'b00;
        end
    end

endmodule: hdu
