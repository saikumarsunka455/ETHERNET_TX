class eth_mem_active_agent extends uvm_agent;

	`uvm_component_utils(eth_mem_active_agent)

	eth_mem_sequencer h_eth_mem_sequencer;
	eth_mem_driver    h_eth_mem_driver;
	eth_mem_input_monitor h_eth_mem_input_monitor;

		function new (string name="eth_mem_active_agent",uvm_component parent);
			super.new(name,parent);

		endfunction


		function void build_phase(uvm_phase phase);

			super.build_phase(phase);
			h_eth_mem_sequencer=eth_mem_sequencer::type_id::create("h_eth_mem_sequencer",this);
			h_eth_mem_driver   =eth_mem_driver::type_id::create("h_eth_mem_driver",this);
			h_eth_mem_input_monitor=eth_mem_input_monitor::type_id::create("h_eth_mem_input_monitor",this);


		endfunction

//============connect phase==================//
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
//=====================connction of tlm ports of memory driver and memory sequncer=============//
		h_eth_mem_driver.seq_item_port.connect(h_eth_mem_sequencer.seq_item_export);	
	endfunction


endclass
