class eth_top_env extends uvm_env;
	`uvm_component_utils(eth_top_env)
	eth_host_mem_env h_eth_host_mem_env;
	eth_mac_env h_eth_mac_env;
	eth_score_board h_eth_score_board;

	function new(string name = "",uvm_component parent);
		super.new(name,parent);
	endfunction


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		h_eth_host_mem_env = eth_host_mem_env::type_id::create("h_eth_host_mem_env",this);
		h_eth_mac_env = eth_mac_env::type_id::create("h_eth_mac_env",this);
		h_eth_score_board = eth_score_board::type_id::create("h_eth_score_board",this);
	endfunction


//===========================connect phase=====================

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		h_eth_host_mem_env.h_eth_mem_active_agent.h_eth_mem_input_monitor.h_mem_input_monitor_port.connect(h_eth_score_board.h_score_board_input_monitor_imp);
		h_eth_mac_env.h_eth_mac_passive_agent.h_eth_mac_output_monitor.h_mac_output_monitor_port.connect(h_eth_score_board.h_score_board_output_monitor_imp);
	endfunction




endclass
