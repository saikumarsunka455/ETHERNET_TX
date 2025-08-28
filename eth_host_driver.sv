class eth_host_driver extends uvm_driver #(eth_sequence_item);

	`uvm_component_utils(eth_host_driver) //factory registraction for component

	virtual eth_interface h_eth_interface; //virtual interface instance

	//=====CONSTRUCTOR========

	function new(string name = "eth_host_driver",uvm_component parent);
		super.new(name,parent);
	endfunction

//============connect phase==================//

	function void connect_phase(uvm_phase phase);

		super.connect_phase(phase);

//---------------------interface getting-----------------------------//
	    assert(uvm_config_db #(virtual eth_interface) :: get(this , this.get_full_name() , "eth_interface", h_eth_interface));
	
	endfunction


//=====================run phase ============//
	task run_phase(uvm_phase phase);
			req = eth_sequence_item :: type_id::create("req");
			h_eth_interface.cb_host_mem_driver.prstn_i  	<= 0;
				@(h_eth_interface.cb_host_mem_driver);

		forever@(h_eth_interface.cb_host_mem_driver)begin

//			@(h_eth_interface.cb_host_mem_driver);

			seq_item_port.get_next_item(req);
			h_eth_interface.cb_host_mem_driver.prstn_i  	<= 1;

//-------------------------- setup phase 
			h_eth_interface.cb_host_mem_driver.psel_i   	<= 1;
			h_eth_interface.cb_host_mem_driver.penable_i 	<= 0;
			h_eth_interface.cb_host_mem_driver.pwrite_i 	<= req.pwrite_i;
			h_eth_interface.cb_host_mem_driver.paddr_i  	<= req.paddr_i;
			h_eth_interface.cb_host_mem_driver.pwdata_i 	<= req.pwdata_i;

			@(h_eth_interface.cb_host_mem_driver);

//------------------------- access phase 
			h_eth_interface.cb_host_mem_driver.psel_i   	<= 1;
			h_eth_interface.cb_host_mem_driver.penable_i 	<= 1;

			if(h_eth_interface.cb_host_mem_driver.prstn_i && h_eth_interface.cb_host_mem_driver.psel_i && h_eth_interface.cb_host_mem_driver.penable_i)
		//	begin
				wait(h_eth_interface.cb_host_mem_driver.pready_o);
				//h_eth_interface.cb_host_mem_driver.psel_i   	<= 1;
			//	h_eth_interface.cb_host_mem_driver.penable_i 	<= 0;
				seq_item_port.item_done();
		//	end
		//	else 
			//	seq_item_port.item_done();

		end
		
	endtask

endclass



