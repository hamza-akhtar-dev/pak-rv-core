// Parametrized Program Counter

module pc 
# (
    parameter PC_SIZE = 32
) (
    input  logic               clk,
    input  logic               arst_n,
    input  logic               en_in,
    input  logic [PC_SIZE-1:0] pc_in,
    output logic [PC_SIZE-1:0] pc_out
);

    always_ff@(posedge clk, negedge arst_n)
    begin
        if(~arst_n)
        begin
            pc_out <= 32'h8000_0000;
        end
        else if(en_in)
        begin
            pc_out <= pc_in;
        end
    end
    
endmodule
