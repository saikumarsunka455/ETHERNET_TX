//======================= eth mac ACTIVE AGENT ====================//

class eth_mac_active_agent extends uvm_agent;

//================ factory registration ==================

	`uvm_component_utils(eth_mac_active_agent)

//===================construction ================

	function new(string name = "" , uvm_component parent);
		super.new(name,parent);
	endfunction

//========================instances ===========================

	eth_mac_sequencer h_eth_mac_sequencer;
	eth_mac_driver h_eth_mac_driver;

//====================build phase=======================

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

//=======================memory creations===========================
		h_eth_mac_sequencer = eth_mac_sequencer :: type_id :: create("h_eth_mac_sequencer",this);
		h_eth_mac_driver = eth_mac_driver :: type_id :: create("h_eth_mac_driver",this);


	endfunction

//===========================connect phase=====================

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		h_eth_mac_driver.seq_item_port.connect(h_eth_mac_sequencer.seq_item_export);
	endfunction

endclass



