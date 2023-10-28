// data cache

module dcache # (
    parameter  DATA_WIDTH  = 32,
    parameter  DCACHE_SIZE = 1,    // size in kilo (2^10) bytes
    parameter  K           = 2,    // for k-way set associative
    parameter  CACHE_TYPE  = 0,    // 0: Direct mapped, 1: Fully associative, 2: K-way set associative
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

    generate

        // direct mapped cache type
        if (CACHE_TYPE == 0)
        begin
            localparam WORD_SIZE       = 4; // 4 bytes per word
            localparam BYTE_OFFSET     = $clog2(WORD_SIZE);
            localparam WORD_SIZE_BITS  = $clog2(WORD_SIZE);
            localparam BLOCK_SIZE_BITS = $clog2(BLOCK_SIZE);
            localparam NUM_BLOCKS_BITS = $clog2(NUM_BLOCKS);
            localparam TAG_BITS        = DATA_WIDTH-NUM_BLOCKS_BITS-BLOCK_SIZE_BITS-BYTE_OFFSET;  // -2 for byte offset

            logic [WORD_SIZE_BITS -1 :0] byte_offset;
            logic [BLOCK_SIZE_BITS-1 :0] block_offset;
            logic [NUM_BLOCKS_BITS-1 :0] block_num;
            logic [TAG_BITS-1:0]         tag;

            logic [BLOCK_SIZE-1:0][DATA_WIDTH-1:0] cache [NUM_BLOCKS-1:0];
            logic [TAG_BITS-1:0]                   tags  [NUM_BLOCKS-1:0];

            assign byte_offset  = addr[BYTE_OFFSET    -1  : 0                  ];
            assign block_offset = addr[                2 +: BLOCK_SIZE_BITS    ];
            assign block_num    = addr[BLOCK_SIZE_BITS+BYTE_OFFSET +: NUM_BLOCKS_BITS    ];
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
        end

        // fully associative cache type
        else if (CACHE_TYPE == 1)
        begin
            // there is no concept of block number in fully associative cache
            // because any block in main mem, can reside in any location in cache
            // to tackle conflict misses
            localparam NUM_WAYS        = NUM_BLOCKS;
            localparam WORD_SIZE       = 4; // 4 bytes per word
            localparam BYTE_OFFSET     = $clog2(WORD_SIZE);
            localparam WORD_SIZE_BITS  = $clog2(WORD_SIZE);
            localparam BLOCK_SIZE_BITS = $clog2(BLOCK_SIZE);
            localparam TAG_BITS        = DATA_WIDTH-BLOCK_SIZE_BITS-BYTE_OFFSET;  // -2 for byte offest

            logic [WORD_SIZE_BITS -1 :0] byte_offset;
            logic [BLOCK_SIZE_BITS-1 :0] block_offset;
            logic [TAG_BITS-1:0]         tag;

            logic [BLOCK_SIZE-1:0][DATA_WIDTH-1:0] cache  [NUM_BLOCKS-1:0];
            logic                                  valids [NUM_BLOCKS-1:0];
            logic [TAG_BITS-1:0]                   tags   [NUM_BLOCKS-1:0];

            assign byte_offset  = addr[BYTE_OFFSET    -1  : 0                  ];
            assign block_offset = addr[                2 +: BLOCK_SIZE_BITS    ];
            assign tag          = addr[     DATA_WIDTH-1  : DATA_WIDTH-TAG_BITS];

            always_comb
            begin
                for (genvar i = 0; i < NUM_WAYS; i++)
                begin
                    if (valids[i])
                        begin
                        if (tag == tags[i])
                        begin
                            dcache_hit = 1;
                            data_out  = cache[i][block_offset];
                        end
                        else
                        begin
                            dcache_hit = 0;
                            data_out   = '0;
                        end
                    end
                    else
                    begin
                        dcache_hit = 0;
                        data_out   = '0;
                    end
                end
            end

            always_ff @ (posedge clk, negedge arst_n)
            begin
                if (~arst_n)
                begin
                    cache  <= '{default: '0};
                    valids <= '{default: '0};
                    tags   <= '{default: '0};
                end
                else if (write_en)
                begin
                    for (genvar i = 0; i < NUM_WAYS; i++)
                    begin
                        // see which valid in low, populate it
                        if (!valids[i])
                        begin
                            valids[i] <= 1'b1;
                            cache[i]  <= data_in;
                            tags[i]   <= tag;
                        end
                    end
                end
            end
            
        end

        // K-way set associative cache type
        else if (CACHE_TYPE == 2)
        begin
            // this cache is a mixture of direct mapped and associative cache
            // each set in this cache holds direct mapping as well as associative property
            localparam WORD_SIZE       = 4; // 4 bytes per word
            localparam NUM_WAYS        = NUM_BLOCKS/K;
            localparam NUM_WAYS_BITS   = $clog2(NUM_WAYS);
            localparam BYTE_OFFSET     = $clog2(WORD_SIZE);
            localparam WORD_SIZE_BITS  = $clog2(WORD_SIZE);
            localparam BLOCK_SIZE_BITS = $clog2(BLOCK_SIZE);
            localparam TAG_BITS        = DATA_WIDTH-BLOCK_SIZE_BITS-NUM_WAYS_BITS-BYTE_OFFSET;

            logic [WORD_SIZE_BITS -1 :0] byte_offset;
            logic [BLOCK_SIZE_BITS-1 :0] block_offset;
            logic [NUM_WAYS_BITS  -1 :0] set_num;
            logic [TAG_BITS       -1 :0] tag;
            logic [NUM_WAYS       -1 :0] hits;

            logic [BLOCK_SIZE-1:0][DATA_WIDTH-1:0] cache  [NUM_WAYS-1:0][NUM_BLOCKS-1:0];
            logic                                  valids [NUM_WAYS-1:0][NUM_BLOCKS-1:0];
            logic [TAG_BITS-1:0]                   tags   [NUM_WAYS-1:0][NUM_BLOCKS-1:0];
            logic [DATA_WIDTH-1:0]               data_out [NUM_WAYS-1:0];

            assign byte_offset  = addr[                                         0 +: BYTE_OFFSET    ];
            assign block_offset = addr[                               BYTE_OFFSET +: BLOCK_SIZE_BITS];
            assign set_num      = addr[               BLOCK_SIZE_BITS+BYTE_OFFSET +: NUM_WAYS_BITS  ];
            assign tag          = addr[NUM_WAYS_BITS+BLOCK_SIZE_BITS+BYTE_OFFSET  +: TAG_BITS       ];

            always_comb
            begin
                for (genvar way = 0; way < NUM_WAYS; way++)
                begin
                    for (genvar block_num = 0; block_num < NUM_BLOCKS; block_num++)
                    begin
                        if (valids[way][block_num])
                        begin
                            if (tag == tags[way][block_num])
                            begin
                                hits    [way] = 1'b1;
                                data_out[way] = cache[way][block_num][block_offset];
                            end
                            else
                            begin
                                hits    [way] = 1'b0;
                                data_out[way] = '0;
                            end
                        end
                        else
                        begin
                            hits    [way] = 1'b0;
                            data_out[way] = '0;
                        end
                    end
                end
            end

            // TODO: use some replacement policy
            always_ff @ (posedge clk, negedge arst_n)
            begin
                if (~arst_n)
                begin
                    cache  <= '{default: '0};
                    valids <= '{default: '0};
                    tags   <= '{default: '0};
                end
                else if (write_en)
                begin
                    for (genvar way = 0; way < NUM_WAYS; way++)
                    begin
                        for (genvar block_num = 0; block_num < NUM_BLOCKS; block_num++)
                        begin
                            // see which valid in low, populate it
                            if (!valids[way][block_num])
                            begin
                                valids[way][block_num]               <= 1'b1;
                                cache [way][block_num][block_offset] <= data_in;
                                tags  [way][block_num]               <= tag;
                            end
                        end
                    end
                end
            end
        end
    endgenerate


endmodule: dcache