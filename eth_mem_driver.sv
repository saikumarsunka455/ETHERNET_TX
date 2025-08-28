class eth_mem_driver extends uvm_driver #(eth_sequence_item);

	`uvm_component_utils(eth_mem_driver)

	function new (string name="eth_mem_driver",uvm_component parent);

		super.new(name,parent);
	endfunction

	virtual eth_interface h_eth_interface; //virtual interface instance

   	eth_config_class h_eth_config_class; 

//============connect phase==================//

	function void connect_phase(uvm_phase phase);

		super.connect_phase(phase);

//---------------------interface getting-----------------------------//
	    assert(uvm_config_db #(virtual eth_interface) :: get(this , this.get_full_name() , "eth_interface", h_eth_interface));
//---------------------- config class getting ----------
        assert(uvm_config_db #(eth_config_class)::get(null,this.get_full_name(),"eth_config_class",h_eth_config_class));
	
	endfunction


//=====================run phase ============//
	task run_phase(uvm_phase phase);
			req = eth_sequence_item :: type_id::create("req");
		forever@(h_eth_interface.cb_host_mem_driver)begin

			seq_item_port.get_next_item(req);

	/*	if(h_eth_interface.cb_host_mem_driver.prstn_i && h_eth_interface.cb_host_mem_driver.m_psel_o && !h_eth_interface.cb_host_mem_driver.m_penable_o && !h_eth_interface.cb_host_mem_driver.m_pwrite_o) 
				h_eth_interface.cb_host_mem_driver.m_pready_i  	<= 0;*/


			wait(h_eth_interface.cb_host_mem_driver.prstn_i && h_eth_interface.cb_host_mem_driver.m_psel_o && h_eth_interface.cb_host_mem_driver.m_penable_o && !h_eth_interface.cb_host_mem_driver.m_pwrite_o);
			begin
				h_eth_interface.cb_host_mem_driver.m_prdata_i  	<= req.m_prdata_i;
			//	$display($time,"=============== %h===============",req.m_prdata_i);
				h_eth_interface.cb_host_mem_driver.m_pready_i  	<= req.m_pready_i;
			end
			seq_item_port.item_done();

		end
		
	endtask


endclass
