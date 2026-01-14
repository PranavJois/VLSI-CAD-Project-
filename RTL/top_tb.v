`timescale 1ns/1ps

module top_tb;

    reg clk = 0;
    reg rst = 1;

    always #5 clk = ~clk;

    wire [31:0] paddr, pwdata, prdata;
    wire pwrite, psel, penable, pready;
    wire [31:0] result;
    wire done;

    apb_master M(clk, rst, paddr, pwdata, pwrite, psel, penable, pready, prdata, result, done);
    apb_slave  S(clk, rst, paddr, pwdata, pwrite, psel, penable, pready, prdata);

    initial begin
        $display("SIM START");
        #10 rst = 0;

        wait(done);

        #10;
        if (result == 32'h12345678)
            $display("PASS: %h", result);
        else
            $display("FAIL: %h", result);

        $finish;
    end
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
    end
  

endmodule
