# Decoder-Based RAM Verification (SystemVerilog Layered Testbench)

A class-based, constrained-random, self-checking **SystemVerilog verification environment** for a 128 x 8 RAM, simulated with **QuestaSim 10.7c**.

> Result: **1280 checks PASS, 0 FAIL, 100% write coverage, 100% read coverage**

---

## 1. Overview

This project verifies a RAM design (`ram.v`) using a layered testbench architecture (generator, drivers, monitors, scoreboard, coverage). It exercises the memory with directed data patterns plus random traffic, checks every read against a reference model, and finally verifies that **reset clears the memory**.

| Item | Value |
|------|-------|
| DUT | `ram.v` (128 locations x 8-bit data) |
| Language | SystemVerilog (testbench), Verilog (DUT) |
| Simulator | QuestaSim-64 10.7c |
| Methodology | Layered, class-based, self-checking |
| Coverage | Functional (write, read, reset, post-reset read) |

---

## 2. Testbench Architecture

```
                 +---------------- ram_test ----------------+
                 |                                          |
                 |   +---------------- ram_env ----------+  |
                 |   |                                   |  |
                 |   |  ram_generator                    |  |
                 |   |     |  (mailbox)                  |  |
                 |   |     v                             |  |
                 |   |  ram_wr_driver   ram_rd_driver    |  |
                 |   |     |                |            |  |
                 |   +-----|----------------|------------+  |
                 +---------|----------------|---------------+
                           v                v
                      +------- ram_if (interface) -------+
                      |                                  |
                      |           DUT: ram               |
                      +----------------------------------+
                           |                |
                      ram_wr_mon       ram_rd_mon
                           |                |
                           +--> ram_scoreboard <--+
                                     |
                               ram_coverage
```

### Components

| File | Role |
|------|------|
| `ram_interface.sv` | Interface `ram_if` connecting TB and DUT (clock, reset, we, re, addr, wdata, rdata) |
| `ram_transaction.sv` | Transaction class (randomized addr, data, we, re) |
| `ram_generator.sv` | Generates 8 phases of write/read stimulus |
| `ram_wr_driver.sv` | Drives write transactions to the DUT |
| `ram_rd_driver.sv` | Drives read transactions to the DUT |
| `ram_wr_mon.sv` | Samples write activity and sends it to the scoreboard |
| `ram_rd_mon.sv` | Samples read activity and sends it to the scoreboard |
| `ram_scoreboard.sv` | Reference memory model, compares expected vs actual, PASS/FAIL counters |
| `ram_coverage.sv` | Functional coverage (write, read, reset, post-reset read) |
| `ram_env.sv` | Creates and connects all components |
| `ram_test.sv` | Top-level test: starts env, runs reset verification, prints reports |
| `ram_pkg.sv` | Package that collects all TB classes |
| `ram_tb_top.sv` | Top module: clock, reset, DUT instance, interface, runs test |

---

## 3. Test Plan Summary

Each phase writes all 128 addresses (random order), then reads them all back.

| Phase | Data pattern | Purpose |
|-------|--------------|---------|
| 0 | `0x00` | All-zeros |
| 1 | `0xFF` | All-ones |
| 2 | `0xAA` | Alternating bits |
| 3 | `0x55` | Inverse alternating bits |
| 4 | `01,02,04,08,10,20,40,80` | Walking ones |
| 5 | `FE,FD,FB,F7,EF,DF,BF,7F` | Walking zeros |
| 6 | Structured / sequential values | Data-integrity check |
| 7 | Fully random | Random data |
| 8 | Repeated random reads (128) | Read-after-write stability |
| 9 | Reset, then read all 128 addresses | Reset must clear memory (expects `0x00`) |

Totals: **1024 writes, 1280 reads checked.**

See [`docs/testplan.md`](docs/testplan.md) for the detailed plan.

---

## 4. Results

```
PASS COUNT = 1280
FAIL COUNT = 0
TEST RESULT = PASS

Write coverage       = 100.00%
Read coverage        = 100.00%
Reset asserted       = 1
Reset released       = 1
Post-reset read seen = 1
```

Full log: [`result/covsummary.html`](result/covsummary.html)

---

## 5. Repository Structure

```
ram-verification/
|-- README.md
|-- LICENSE
|-- rtl/
|   `-- ram.v
|-- tb/
|   |-- ram_interface.sv
|   |-- ram_transaction.sv
|   |-- ram_generator.sv
|   |-- ram_wr_driver.sv
|   |-- ram_rd_driver.sv
|   |-- ram_wr_mon.sv
|   |-- ram_rd_mon.sv
|   |-- ram_scoreboard.sv
|   |-- ram_coverage.sv
|   |-- ram_env.sv
|   |-- ram_test.sv
|   |-- ram_pkg.sv
|   `-- ram_tb_top.sv

|-- docs/
|   |-- testplan.md
|   `-- images/
`-- results/
    `-- covsummaru.html/
```

---


## 6. Key Features

- Layered class-based architecture with mailboxes
- Separate write and read drivers/monitors
- Self-checking scoreboard with reference memory model
- Directed + constrained-random stimulus
- Walking-ones / walking-zeros data tests
- Reset functionality verification
- Functional coverage reporting

---

## 7. Future Improvements

- Add SystemVerilog Assertions (SVA) on the interface
- Add back-to-back read/write same-address tests
- Port the environment to UVM
- Add code coverage (statement/branch/toggle) report
- Add a regression script with multiple seeds

---

## 8. Author

**Your Name**
SVNIT surat | VLSI / Design Verification
LinkedIn: `https://www.linkedin.com/in/vishal-shiyal-2481872bb/` | Email: `vdshiyal2004@gmail.com`

## 10. License

MIT License. See [LICENSE](LICENSE).
