
//DESIGN
`include "ETHERNET_RTL/apb_BDs_bridge.v"
`include "ETHERNET_RTL/eth_clockgen.v"
`include "ETHERNET_RTL/eth_crc.v"
`include "ETHERNET_RTL/eth_fifo.v"
`include "ETHERNET_RTL/eth_maccontrol.v"
`include "ETHERNET_RTL/ethmac_defines.v"
`include "ETHERNET_RTL/eth_macstatus.v"
`include "ETHERNET_RTL/eth_miim.v"
`include "ETHERNET_RTL/eth_outputcontrol.v"
`include "ETHERNET_RTL/eth_random.v"
`include "ETHERNET_RTL/eth_receivecontrol.v"
`include "ETHERNET_RTL/eth_registers.v"
`include "ETHERNET_RTL/eth_register.v"
`include "ETHERNET_RTL/eth_rxaddrcheck.v"
`include "ETHERNET_RTL/eth_rxcounters.v"
`include "ETHERNET_RTL/eth_rxethmac.v"
`include "ETHERNET_RTL/eth_rxstatem.v"
`include "ETHERNET_RTL/eth_shiftreg.v"
`include "ETHERNET_RTL/eth_spram_256x32.v"
`include "ETHERNET_RTL/eth_transmitcontrol.v"
`include "ETHERNET_RTL/eth_top.v"
`include "ETHERNET_RTL/eth_txcounters.v"
`include "ETHERNET_RTL/eth_txethmac.v"
`include "ETHERNET_RTL/eth_txstatem.v"
`include "ETHERNET_RTL/eth_wishbone.v"
`include "ETHERNET_RTL/timescale.v"

package eth_package;

	import uvm_pkg::*;
typedef bit[3:0] nibble_queue[$];

	`include "uvm_macros.svh"
	`include "eth_config_db.sv"
	`include "eth_sequence_item.sv"
	`include "reconfig_int_source.sv"
	`include "eth_host_sequence.sv"
	`include "eth_mem_sequence.sv"
	`include "eth_mac_sequence.sv"
	`include "eth_host_sequencer.sv"
	`include "eth_host_driver.sv"
	`include "eth_host_monitor.sv"
	`include "eth_host_active_agent.sv"
	`include "eth_mem_sequencer.sv"
	`include "eth_mem_driver.sv"
	`include "eth_mem_input_monitor.sv"
	`include "eth_mem_active_agent.sv"
	`include "eth_mac_sequencer.sv"
	`include "eth_mac_driver.sv"
	`include "eth_mac_output_monitor.sv"
	`include "eth_mac_active_agent.sv"
	`include "eth_mac_passive_agent.sv"
	`include "eth_host_mem_env.sv"
	`include "eth_mac_env.sv"
	`include "eth_score_board.sv"
	`include "eth_top_env.sv"
	`include "eth_test.sv"



endpackage


