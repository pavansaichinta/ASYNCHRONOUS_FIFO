`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.01.2026 08:47:37
// Design Name: 
// Module Name: async_fifo
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

module async_fifo #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 3) (
    //Write Domain
    input  wr_clk, wr_rst_n, wr_en,
    input  [DATA_WIDTH-1:0] wr_data,
    output full,
    
    //Read Domain
    input  rd_clk, rd_rst_n, rd_en,
    output [DATA_WIDTH-1:0] rd_data,
    output empty
);

    reg  [ADDR_WIDTH:0] w_ptr_bin, w_ptr_gray;
    reg  [ADDR_WIDTH:0] r_ptr_bin, r_ptr_gray;
    wire [ADDR_WIDTH:0] w_ptr_gray_sync, r_ptr_gray_sync;

    //RAM Instanciation
    fifo_ram #(DATA_WIDTH, ADDR_WIDTH) ram_inst (
        .wr_clk(wr_clk), .wr_en(wr_en && !full), .wr_addr(w_ptr_bin[ADDR_WIDTH-1:0]), .wr_data(wr_data),
        .rd_clk(rd_clk), .rd_addr(r_ptr_bin[ADDR_WIDTH-1:0]), .rd_data(rd_data)
    );

    //Write Domain Logic
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            w_ptr_bin  <= 0;
            w_ptr_gray <= 0;
        end else if (wr_en && !full) begin
            w_ptr_bin  <= w_ptr_bin + 1;
            w_ptr_gray <= (w_ptr_bin + 1) ^ ((w_ptr_bin + 1) >> 1);
        end
    end

    //Read Domain Logic
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            r_ptr_bin  <= 0;
            r_ptr_gray <= 0;
        end else if (rd_en && !empty) begin
            r_ptr_bin  <= r_ptr_bin + 1;
            r_ptr_gray <= (r_ptr_bin + 1) ^ ((r_ptr_bin + 1) >> 1);
        end
    end

    //Cross-Domain Synchronization
    sync_ptr #(ADDR_WIDTH+1) s_rd_to_wr (
        .clk(wr_clk), .rst_n(wr_rst_n), .ptr_in(r_ptr_gray), .ptr_out(r_ptr_gray_sync)
    );
    sync_ptr #(ADDR_WIDTH+1) s_wr_to_rd (
        .clk(rd_clk), .rst_n(rd_rst_n), .ptr_in(w_ptr_gray), .ptr_out(w_ptr_gray_sync)
    );

    //Flag Logic
    assign empty = (r_ptr_gray == w_ptr_gray_sync);
    assign full  = (w_ptr_gray == {~r_ptr_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1], r_ptr_gray_sync[ADDR_WIDTH-2:0]});

endmodule

//Two FF Synchronizers
module sync_ptr #(parameter W = 4) (
    input  clk, rst_n,
    input  [W-1:0] ptr_in,
    output [W-1:0] ptr_out
);
    reg [W-1:0] q1, q2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q1 <= 0;
            q2 <= 0;
        end else begin
            q1 <= ptr_in;
            q2 <= q1;
        end
    end

    assign ptr_out = q2;
endmodule

//RAM
module fifo_ram #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 3) (
    input  wr_clk, wr_en,
    input  [ADDR_WIDTH-1:0] wr_addr,
    input  [DATA_WIDTH-1:0] wr_data,
    input  rd_clk,
    input  [ADDR_WIDTH-1:0] rd_addr,
    output [DATA_WIDTH-1:0] rd_data
);
    parameter DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge wr_clk) begin
        if (wr_en) mem[wr_addr] <= wr_data;
    end

    assign rd_data = mem[rd_addr];
endmodule
