# ASYNCHRONOUS_FIFO
ProjectView--  https://www.edaplayground.com/x/BqSK
## Asynchronous FIFO (Dual-Clock) in Verilog

This repository contains a robust, synthesized-ready implementation of an **Asynchronous FIFO** (First-In, First-Out) memory buffer. This design is specifically engineered for data transfer between two different clock domains (**Clock Domain Crossing**), ensuring data integrity and preventing metastability using Gray code pointer synchronization.

---

## 🚀 Features

* **Dual-Clock Architecture:** Independent `wr_clk` (Write Domain) and `rd_clk` (Read Domain).
* **Parameterized Design:** Easily adjustable `DATA_WIDTH` and `ADDR_WIDTH` (Depth = $2^{ADDR\_WIDTH}$).
* **CDC Safety:** Uses **Gray Code** encoding for pointer synchronization to minimize multi-bit synchronization errors.
* **2-FF Synchronizers:** Implements double flip-flop synchronizers to significantly reduce the probability of metastability.
* **Flag Logic:** Includes standard `full` and `empty` flag generation.

---

## 🛠 Hardware Architecture



The FIFO consists of four primary functional blocks:

1.  **Memory Array:** A dual-port RAM block that stores the data.
2.  **Write Logic:** Manages the binary write pointer (`w_ptr_bin`), converts it to Gray code (`w_ptr_gray`), and generates the `full` flag.
3.  **Read Logic:** Manages the binary read pointer (`r_ptr_bin`), converts it to Gray code (`r_ptr_gray`), and generates the `empty` flag.
4.  **Synchronizers:** 2-stage Flip-Flop chains that pass the Gray-coded pointers across the asynchronous clock boundary.

### Why Gray Code?
In an asynchronous FIFO, pointers must be synchronized to the opposite clock domain. If a binary pointer (e.g., `3` to `4` or `011` to `100`) is synchronized, multiple bits change simultaneously. If the destination clock samples during this transition, it might capture an invalid value. **Gray Code** ensures only **one bit** changes at a time, making the synchronization process safe.

---

## 📂 File Structure

* `async_fifo.v`: The top-level module containing the pointer logic and flag generation.
* `sync_ptr.v`: Generic 2-FF synchronizer module for pointer crossing.
* `fifo_ram.v`: Dual-port RAM implementation using Verilog memory arrays.
* `async_fifo_tb.v`: A comprehensive testbench simulating a fast write clock (**100MHz**) and a slower read clock (**40MHz**).

---

## 🧪 Simulation & Verification

The provided testbench performs the following sequence:
1.  **System Reset:** Synchronous-deasserted reset for both domains.
2.  **Burst Write:** Writes data until the `full` flag is asserted.
3.  **Synchronization Wait:** Accounts for the 2-cycle latency of the 2-FF synchronizers.
4.  **Burst Read:** Reads data until the `empty` flag is asserted.

gtkwave fifo_waves.vcd

