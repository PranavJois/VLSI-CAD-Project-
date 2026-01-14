module tb_top;

    // =========================================================
    // Clock and Reset
    // =========================================================
    reg clk_a = 0;
    reg clk_b = 0;
    reg rst   = 1;

    // Parameterized clock half-periods (ns)
    parameter integer T_A = 5;   // 100 MHz
    parameter integer T_B = 7;   // ~71 MHz

    // Generate clocks
    always #T_A clk_a = ~clk_a;
    always #T_B clk_b = ~clk_b;

    // =========================================================
    // DUT signals
    // =========================================================
    wire [31:0] paddr_a, pwdata_a, prdata_a;
    wire        pwrite_a, psel_a, penable_a, pready_a;

    wire [31:0] paddr_b, pwdata_b, prdata_b;
    wire        pwrite_b, psel_b, penable_b, pready_b;

    // =========================================================
    // Instantiate DUT blocks
    // =========================================================

    apb_master M (
        .clk(clk_a), .rst(rst),
        .paddr(paddr_a), .pwdata(pwdata_a), .pwrite(pwrite_a),
        .psel(psel_a), .penable(penable_a),
        .pready(pready_a), .prdata(prdata_a)
    );

    apb_async_bridge B (
        .clk_a(clk_a), .rst_a(rst),
        .clk_b(clk_b), .rst_b(rst),

        .paddr_a(paddr_a), .pwdata_a(pwdata_a), .pwrite_a(pwrite_a),
        .psel_a(psel_a), .penable_a(penable_a),
        .prdata_a(prdata_a), .pready_a(pready_a),

        .paddr_b(paddr_b), .pwdata_b(pwdata_b), .pwrite_b(pwrite_b),
        .psel_b(psel_b), .penable_b(penable_b),
        .prdata_b(prdata_b), .pready_b(pready_b)
    );

    apb_slave S (
        .clk(clk_b), .rst(rst),
        .paddr(paddr_b), .pwdata(pwdata_b), .pwrite(pwrite_b),
        .psel(psel_b), .penable(penable_b),
        .prdata(prdata_b), .pready(pready_b)
    );

    // =========================================================
    // Simulation control
    // =========================================================
    initial begin
        // Dump waveform
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);

        // Hold reset
        #50;
        rst = 0;
        $display("Reset deasserted");

        // Run simulation
        #10000;

        $display("Simulation finished normally.");
        $finish;
    end

    // =========================================================
    // Safety timeout (prevents infinite hang)
    // =========================================================
    initial begin
        #20000;
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
