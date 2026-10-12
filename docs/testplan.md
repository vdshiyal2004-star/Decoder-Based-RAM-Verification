# Test Plan: Decoder-Based RAM Verification

## 1. DUT
128 x 8-bit synchronous RAM (`ram.v`) with write enable (`we`), read enable (`re`), 7-bit address, 8-bit write data, 8-bit read data and reset (reset clears memory).

## 2. Verification Goals
1. Every location can be written and read back correctly.
2. Data patterns expose stuck-at, coupling and bit-line faults.
3. Reads are stable when repeated.
4. Reset clears the whole memory.
5. Reach 100% functional coverage for write and read.

## 3. Scenarios

| ID | Scenario | Stimulus | Check |
|----|----------|----------|-------|
| T0 | All zeros | Write 0x00 to all 128 addresses (random order), read all | Read == written |
| T1 | All ones | 0xFF | Read == written |
| T2 | Alternating | 0xAA | Read == written |
| T3 | Inverse alternating | 0x55 | Read == written |
| T4 | Walking ones | 01,02,04,...,80 | Read == written |
| T5 | Walking zeros | FE,FD,FB,...,7F | Read == written |
| T6 | Structured data | Sequential/patterned values | Read == written |
| T7 | Random data | Fully random wdata | Read == written |
| T8 | Repeated random reads | 128 random addresses re-read | Data unchanged |
| T9 | Reset | Assert reset, release, read all 128 | All reads == 0x00 |

## 4. Checking
`ram_scoreboard` keeps a reference memory (associative array/array). Each monitored write updates it; each monitored read is compared to the stored value. PASS/FAIL counters are printed at the end.

## 5. Coverage
- Write coverage: addresses and data values written
- Read coverage: addresses and data values read
- Reset asserted / released
- Post-reset read observed

## 6. Result (QuestaSim 10.7c)
- Writes: 1024, Reads checked: 1280
- PASS = 1280, FAIL = 0
- Write coverage 100%, Read coverage 100%
