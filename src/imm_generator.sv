//used to generate signed/unsigned immediates
//sign extender unit
module imm_generator #(
   parameter DATA_WIDTH = 32
)(
   input  logic [DATA_WIDTH-1:0] instruction, //instruction input to this unit
   input  logic [2:0]            s,
   output logic [DATA_WIDTH-1:0] imm_ext      //output (sign extended immediate)
);

   always_comb begin
      case(s)
         3'b000: begin     //I-type
            imm_ext = {{20{instruction[31]}}, instruction[31:20]};
         end
         3'b001: begin     //S-type
            imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
         end
         3'b010: begin     //B-type
            imm_ext = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
         end
         3'b011: begin     //J-type
            imm_ext = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
         end
         3'b100: begin     //U-type
            imm_ext = {{instruction[31:12]}, {12{1'b0}}};
         end
         3'b101: begin
            imm_ext = {{20{1'b0}}, instruction[31:20]};
         end
      endcase
   end

endmodule