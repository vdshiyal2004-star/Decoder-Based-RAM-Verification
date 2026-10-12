
package ram_pkg;

    // Transaction must be defined first
    `include "ram_transaction.sv"

    // Components that use transaction
    `include "ram_generator.sv"
    `include "ram_wr_driver.sv"
    `include "ram_rd_driver.sv"
    `include "ram_wr_mon.sv"
    `include "ram_rd_mon.sv"
    `include "ram_scoreboard.sv"
    `include "ram_coverage.sv"

    // Environment comes after all its components
    `include "ram_env.sv"

  

endpackage
