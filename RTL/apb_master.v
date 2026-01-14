module apb_master(
    input clk, rst,
    output reg [31:0] paddr,
    output reg [31:0] pwdata,
    output reg pwrite,
    output reg psel,
    output reg penable,
    input pready,
    input [31:0] prdata,
    output reg [31:0] result,
    output reg done
);

reg [2:0] state;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state   <= 0;
        psel    <= 0;
        penable <= 0;
        done    <= 0;
    end else begin
        case (state)

            // WRITE SETUP
            0: begin
                paddr  <= 32'h00000004;
                pwdata <= 32'h12345678;
                pwrite <= 1;
                psel   <= 1;
                penable<= 0;
                state  <= 1;
            end

            // WRITE ACCESS
            1: begin
                penable <= 1;
                if (pready) begin
                    psel    <= 0;
                    penable <= 0;
                    state   <= 2;
                end
            end

            // READ SETUP
            2: begin
                paddr  <= 32'h00000004;
                pwrite <= 0;
                psel   <= 1;
                penable<= 0;
                state  <= 3;
            end

            // READ ACCESS
            3: begin
                penable <= 1;
                if (pready) begin
                    result <= prdata;
                    psel   <= 0;
                    penable<= 0;
                    done   <= 1;
                    state  <= 4;
                end
            end

            // DONE
            4: begin
                // hold state
            end

        endcase
    end
end

endmodule
