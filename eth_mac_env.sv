class eth_mac_env extends uvm_env;
	`uvm_component_utils(eth_mac_env)
	
	eth_mac_active_agent h_eth_mac_active_agent;
	eth_mac_passive_agent h_eth_mac_passive_agent;
	
	function new(string name = "",uvm_component parent);
		super.new(name,parent);
	endfunction


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		h_eth_mac_active_agent = eth_mac_active_agent::type_id::create("h_eth_mac_active_agent",this);
		h_eth_mac_passive_agent = eth_mac_passive_agent::type_id::create("h_eth_mac_passive_agent",this);
	endfunction

endclass
