module apb_async_bridge(
    input clk_a, clk_b, rst,

    input  [31:0] paddr_a, pwdata_a,
    input         pwrite_a, psel_a, penable_a,
    output reg    pready_a,
    output reg [31:0] prdata_a,

    output reg [31:0] paddr_b, pwdata_b,
    output reg        pwrite_b, psel_b, penable_b,
    input             pready_b,
    input  [31:0]     prdata_b
);

reg req_a, req_b;
reg [1:0] state;

// A-domain: capture request
always @(posedge clk_a or posedge rst) begin
    if (rst) begin
        req_a <= 0;
        pready_a <= 0;
    end else begin
        pready_a <= 0;
        if (psel_a && penable_a && !req_a)
            req_a <= 1;

        if (req_b) begin
            pready_a <= 1;
            prdata_a <= prdata_b;
            req_a <= 0;
        end
    end
end

// CDC: synchronize request into B-domain
always @(posedge clk_b or posedge rst) begin
    if (rst)
        req_b <= 0;
    else
        req_b <= req_a;
end

// B-domain: APB FSM
always @(posedge clk_b or posedge rst) begin
    if (rst) begin
        state <= 0;
        psel_b <= 0;
        penable_b <= 0;
    end else begin
        case (state)
            0: if (req_b) begin
                paddr_b  <= paddr_a;
                pwdata_b <= pwdata_a;
                pwrite_b <= pwrite_a;
                psel_b   <= 1;
                penable_b<= 0;
                state    <= 1;
            end

            1: begin
                penable_b <= 1;
                state <= 2;
            end

            2: if (pready_b) begin
                psel_b <= 0;
                penable_b <= 0;
                state <= 0;
            end
        endcase
    end
end

endmodule
