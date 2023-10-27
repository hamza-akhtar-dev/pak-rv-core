// data cache

module dcache # (
    parameter  DATA_WIDTH  = 32,
    parameter  DCACHE_SIZE = 1,    // size in kilo (2^10) bytes
    parameter  S           = 1,

    // block size or line size can be used alternatively.
    parameter  BLOCK_SIZE  = 4,    // 4 words per block
    localparam NUM_BLOCKS  = (DCACHE_SIZE*(2**10)/4)/BLOCK_SIZE
)(
    input  logic                             clk,
    input  logic                             arst_n,
    input  logic                             write_en,
    input  logic [DATA_WIDTH-1:0]            addr,
    input  logic [BLOCK_SIZE*DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0]            data_out,
    output logic                             dcache_hit
);

    // direct mapped dcache

    localparam WORD_SIZE       = 4; // 4 bytes per word
    localparam BYTE_OFFSET     = $clog2(WORD_SIZE);
    localparam WORD_SIZE_BITS  = $clog2(WORD_SIZE);
    localparam BLOCK_SIZE_BITS = $clog2(BLOCK_SIZE);
    localparam NUM_BLOCKS_BITS = $clog2(NUM_BLOCKS);
    localparam TAG_BITS        = DATA_WIDTH-NUM_BLOCKS_BITS-BLOCK_SIZE_BITS-BYTE_OFFSET;  // -2 for byte of

    logic [WORD_SIZE_BITS -1 :0] byte_offset;
    logic [BLOCK_SIZE_BITS-1 :0] block_offset;
    logic [NUM_BLOCKS_BITS-1 :0] block_num;
    logic [TAG_BITS-1:0]         tag;

    logic [BLOCK_SIZE-1:0][DATA_WIDTH-1:0] cache [NUM_BLOCKS-1:0];
    logic [TAG_BITS-1:0]                   tags  [NUM_BLOCKS-1:0];

    assign byte_offset  = addr[BYTE_OFFSET    -1  : 0                  ];
    assign block_offset = addr[                2 +: BLOCK_SIZE_BITS    ];
    assign block_num    = addr[BLOCK_SIZE_BITS+2 +: NUM_BLOCKS_BITS    ];
    assign tag          = addr[     DATA_WIDTH-1  : DATA_WIDTH-TAG_BITS];

    always_comb
    begin
        if (tag == tags[block_num])
        begin
            dcache_hit = 1;
            data_out  = cache[block_num][block_offset];
        end
        else
        begin
            dcache_hit = 0;
            data_out  = '0;
        end
    end

    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            cache <= '{default: '0};
            tags  <= '{default: '0};
        end
        else if (write_en)
        begin
            cache[block_num] <= data_in;
            tags[block_num]  <= tag;
        end
    end

endmodule: dcache