class eth_test extends uvm_test;

//================== factory registration ========
	`uvm_component_utils(eth_test)

//============instance ========
	eth_top_env h_eth_top_env;
	eth_host_sequence h_eth_host_sequence;
	eth_mem_sequence h_eth_mem_sequence;
	eth_mac_sequence h_eth_mac_sequence;
	eth_reconfig_int_source h_eth_reconfig_int_source;

	virtual eth_interface h_eth_interface;
   	eth_config_class h_eth_config_class; 
//---------------- event for waiting ---- based on the output monitor trigger ----
	uvm_event event_test_op_every_bd;
//=============== construction ==========
	function new(string name = "",uvm_component parent);
		super.new(name,parent);
	endfunction


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db #(virtual eth_interface) :: get(this , "" , "eth_interface", h_eth_interface);
		assert(uvm_config_db #(eth_config_class)::get(null,this.get_full_name(),"eth_config_class",h_eth_config_class));
		h_eth_top_env = eth_top_env::type_id::create("h_eth_top_env",this);
		h_eth_host_sequence = eth_host_sequence::type_id::create("h_eth_host_sequence");
		h_eth_mem_sequence = eth_mem_sequence::type_id::create("h_eth_mem_sequence");
		h_eth_mac_sequence = eth_mac_sequence::type_id::create("h_eth_mac_sequence");
		h_eth_reconfig_int_source = eth_reconfig_int_source::type_id::create("h_eth_reconfig_int_source");
		event_test_op_every_bd = uvm_event_pool :: get_global("event_sb_out");
		
	endfunction

	function void start_of_simulation_phase(uvm_phase phase);
	//function void end_of_elaboration_phase(uvm_phase phase);
	//	uvm_top.print_topology();//  to print the topology to verify how the connetions is going on
		print();
	endfunction

//=====================run phase=======================//

	task run_phase(uvm_phase phase);
		super.run_phase(phase);

		phase.raise_objection(this,"rasied");

			h_eth_host_sequence.start(h_eth_top_env.h_eth_host_mem_env.h_eth_host_active_agent.h_eth_host_sequencer);
			fork			
				h_eth_mem_sequence.start(h_eth_top_env.h_eth_host_mem_env.h_eth_mem_active_agent.h_eth_mem_sequencer);
			//	h_eth_mac_sequence.start(h_eth_top_env.h_eth_mac_env.h_eth_mac_active_agent.h_eth_mac_sequencer);
		      	for(int i = 0; i < h_eth_config_class.TX_BD_NUM;i++) begin
					event_test_op_every_bd.wait_trigger();
					if(h_eth_config_class.irq_que[i])
 							wait(h_eth_interface.int_o) h_eth_reconfig_int_source.start(h_eth_top_env.h_eth_host_mem_env.h_eth_host_active_agent.h_eth_host_sequencer);
				end
		
			join
			#10000;
		phase.drop_objection(this , "dropped");

	endtask


endclass
