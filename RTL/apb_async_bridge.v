module apb_async_bridge (
    input  wire clk_a, rst_a,
    input  wire clk_b, rst_b,

    // A side
    input  wire [31:0] paddr_a,
    input  wire [31:0] pwdata_a,
    input  wire        pwrite_a,
    input  wire        psel_a,
    input  wire        penable_a,
    output wire [31:0] prdata_a,
    output wire        pready_a,

    // B side
    output reg  [31:0] paddr_b,
    output reg  [31:0] pwdata_b,
    output reg         pwrite_b,
    output reg         psel_b,
    output reg         penable_b,
    input  wire [31:0] prdata_b,
    input  wire        pready_b
);

    wire [64:0] fifo_wdata = { pwrite_a, paddr_a, pwdata_a };
    wire [64:0] fifo_rdata;

    wire fifo_full, fifo_empty;

    wire src_req, src_ready;
    wire dst_valid, dst_done;

    assign src_req = psel_a & penable_a & src_ready & ~fifo_full;

    cdc_handshake_ctrl u_handshake (
        .src_clk(clk_a), .src_rst(rst_a), .src_req(src_req), .src_ready(src_ready),
        .dst_clk(clk_b), .dst_rst(rst_b), .dst_valid(dst_valid), .dst_done(dst_done)
    );

    async_fifo u_fifo (
        .wr_clk(clk_a), .rd_clk(clk_b), .rst(rst_a | rst_b),
        .wr_fire(src_req), .wr_data(fifo_wdata), .full(fifo_full),
        .rd_fire(dst_valid), .rd_data(fifo_rdata), .empty(fifo_empty)
    );

    always @(posedge clk_b or posedge rst_b) begin
        if (rst_b) begin
            psel_b <= 0; penable_b <= 0;
            paddr_b <= 0; pwdata_b <= 0; pwrite_b <= 0;
        end else begin
            if (dst_valid) begin
                pwrite_b <= fifo_rdata[64];
                paddr_b  <= fifo_rdata[63:32];
                pwdata_b <= fifo_rdata[31:0];
                psel_b <= 1; penable_b <= 1;
            end else begin
                psel_b <= 0; penable_b <= 0;
            end
        end
    end

    assign dst_done = psel_b & penable_b & pready_b;

    assign pready_a = src_ready & ~fifo_full;
    assign prdata_a = prdata_b;

endmodule
