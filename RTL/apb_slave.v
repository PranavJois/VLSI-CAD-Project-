module apb_slave(
    input clk, rst,
    input [31:0] paddr, pwdata,
    input pwrite, psel, penable,
    output reg pready,
    output reg [31:0] prdata
);

reg [31:0] mem;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        mem <= 0;
        pready <= 0;
    end else begin
        pready <= 0;
        if (psel && penable) begin
            pready <= 1;
            if (pwrite)
                mem <= pwdata;
            else
                prdata <= mem;
        end
    end
end
endmodule
