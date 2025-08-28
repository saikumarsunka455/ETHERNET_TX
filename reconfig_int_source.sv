class eth_reconfig_int_source extends uvm_sequence #(eth_sequence_item);

	`uvm_object_utils(eth_reconfig_int_source) ///factory registraction for object

	//=======CONSTRUCTOR=========

	function new(string name = "eth_host_sequence");
			super.new(name);
	endfunction

   	eth_config_class h_eth_config_class; 

	task pre_body;
        assert(uvm_config_db #(eth_config_class)::get(null,this.get_full_name(),"eth_config_class",h_eth_config_class));		
	endtask

	task config_reg(int addr, bit write);
		req=eth_sequence_item :: type_id::create("req");
		start_item(req);
		assert(req.randomize with {paddr_i==addr;pwrite_i == write;}); 
		finish_item(req);
	endtask
	
	task body();
		//--------------INT_SOURCE----------------------------//
		config_reg('d4,1'd0);
		config_reg('d4,'b1);
		config_reg('d4,1'd0);
	endtask
endclass
