class eth_host_mem_env extends uvm_env;
	`uvm_component_utils(eth_host_mem_env)
	
	eth_host_active_agent h_eth_host_active_agent;
	eth_mem_active_agent h_eth_mem_active_agent;
	function new(string name = "",uvm_component parent);
		super.new(name,parent);
	endfunction


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		h_eth_host_active_agent = eth_host_active_agent::type_id::create("h_eth_host_active_agent",this);
		h_eth_mem_active_agent = eth_mem_active_agent::type_id::create("h_eth_mem_active_agent",this);
	endfunction

endclass
