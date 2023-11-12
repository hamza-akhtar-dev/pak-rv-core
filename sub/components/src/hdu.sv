// Hazard Detection Unit

module hdu
#(
) (
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    input  logic [4:0] rd_frm_ex,
    input  logic [1:0] wb_sel_frm_ex,
    output logic       stall,
    output logic       flush
);

    // hazard detection logic
    always_comb
    begin
        stall = ((rs1 == rd_frm_ex) || (rs2 == rd_frm_ex)) && (wb_sel_frm_ex == 2'b01);
        flush = stall;
    end

endmodule: hdu
