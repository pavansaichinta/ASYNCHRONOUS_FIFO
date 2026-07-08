`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.01.2026 15:30:31
// Design Name: 
// Module Name: async_fifo_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module async_fifo_tb;
    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 3;

    // Inputs (reg)
    reg wr_clk, rd_clk;
    reg wr_rst_n, rd_rst_n;
    reg wr_en, rd_en;
    reg [DATA_WIDTH-1:0] wr_data;

    // Outputs (wire)
    wire [DATA_WIDTH-1:0] rd_data;
    wire full, empty;

    // Instantiate the FIFO with explicit port mapping
    async_fifo #(DATA_WIDTH, ADDR_WIDTH) uut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty)
    );

    // Clock Generation
    initial begin
        wr_clk = 0;
        rd_clk = 0;
    end

    always #5    wr_clk = ~wr_clk; // 100MHz (Period = 10ns)
    always #8 rd_clk = ~rd_clk; // 62.5MHz  (Period = 16ns)

    // Simulation Procedure
    integer i;
    initial begin
        // 1. Initialize & Reset
        wr_rst_n = 0; 
        rd_rst_n = 0;
        wr_en = 0; 
        rd_en = 0; 
        wr_data = 0;

        #20;
        wr_rst_n = 1; 
        rd_rst_n = 1;
        #10;

        // 2. Write Data until Full
        $display("---------------------------------------------------------");
        $display("[%0t ns] --- Starting Sequential Write Operations ---", $time);
        $display("---------------------------------------------------------");
        for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1) begin
            @(posedge wr_clk);
            if (!full) begin
                wr_en   <= 1;
                wr_data <= i + 8'hA0; // Data: A0, A1, A2...
                $display("[%0t ns] [WRITE] Writing Data: 0x%h to FIFO", $time, (i + 8'hA0));
            end else begin
                wr_en   <= 0;
                $display("[%0t ns] [WRITE SKIPPED] FIFO is already FULL!", $time);
            end
        end
        @(posedge wr_clk) wr_en <= 0;

        // Wait for flags to synchronize across domains
        repeat(5) @(posedge wr_clk);
        if (full) $display("[%0t ns] [STATUS] FIFO successfully reported FULL status.", $time);

        #30;

        // 3. Read Data until Empty (Streamlined to avoid rd_en toggling)
        $display("---------------------------------------------------------");
        $display("[%0t ns] --- Starting Sequential Read Operations ---", $time);
        $display("---------------------------------------------------------");
        for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1) begin
            @(posedge rd_clk);
            if (!empty) begin
                rd_en <= 1;
            end else begin
                rd_en <= 0;
                $display("[%0t ns] [READ SKIPPED] FIFO is already EMPTY!", $time);
            end
            
            // Print the data driven out by the PREVIOUS clock cycle's read request
            if (rd_en) begin
                $display("[%0t ns] [READ] Captured Data: 0x%h from FIFO", $time, rd_data);
            end
        end

        // Catch the final valid data word on the last read cycle
        @(posedge rd_clk);
        if (rd_en) begin
            $display("[%0t ns] [READ] Captured Data: 0x%h from FIFO", $time, rd_data);
        end
        rd_en <= 0;

        // Wait for flags to synchronize across domains
        repeat(5) @(posedge rd_clk);
        if (empty) $display("[%0t ns] [STATUS] FIFO successfully reported EMPTY status.", $time);

        #50;
        $display("[%0t ns] Simulation Finished.", $time);
        $finish;
    end

    // Waveform setup for GTKWave/Vivado/ModelSim
    initial begin
        $dumpfile("fifo_waves.vcd");
        $dumpvars(0, async_fifo_tb);
    end

endmodule