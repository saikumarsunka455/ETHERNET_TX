class eth_score_board extends uvm_scoreboard;

//====================factory registration =================
	`uvm_component_utils(eth_score_board)

	nibble_queue in_que , out_que;
	uvm_event event_sb;
   	eth_config_class h_eth_config_class; 
	virtual eth_interface h_eth_interface;
//==================== sequence item instance ==============
	 eth_sequence_item h_seq_item_mem_input_monitor,h_seq_item_mac_output_monitor;
//==================== analysis port=======================
	`uvm_analysis_imp_decl(_outmon)
	uvm_analysis_imp #(nibble_queue,eth_score_board) h_score_board_input_monitor_imp;
	uvm_analysis_imp_outmon #(nibble_queue,eth_score_board) h_score_board_output_monitor_imp;

//===============construction =======================

	function new(string name="", uvm_component parent);
		super.new(name,parent);
	endfunction

//====================build phase=======================

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		h_score_board_input_monitor_imp = new("h_score_board_input_monitor_imp",this);
		h_score_board_output_monitor_imp = new("h_score_board_output_monitor_imp",this);
		h_seq_item_mem_input_monitor = eth_sequence_item::type_id::create("h_seq_item_mem_input_monitor",this);
		h_seq_item_mac_output_monitor = eth_sequence_item::type_id::create("h_seq_item_mac_output_monitor",this);
		event_sb = uvm_event_pool :: get_global("event_sb_out");

	endfunction

//===========================connect phase=====================

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
        assert(uvm_config_db #(eth_config_class)::get(null,this.get_full_name(),"eth_config_class",h_eth_config_class));
		uvm_config_db #(virtual eth_interface) :: get(this , "" , "eth_interface", h_eth_interface);

	endfunction

//====================write functions==================

	function void write(input nibble_queue in_data);
		in_que = in_data;
	endfunction

	function void write_outmon(input nibble_queue out_data);
		out_que = out_data;
	endfunction



	//===================run phase =========================

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever 
		begin//{ 

//--------------------- thid flag be 0 after completion of every bd once it is 1 -----
			h_eth_config_class.delete_flag=0;
//---------------- wait for the event trigger in the output monitor after completion of every bd ---------
			event_sb.wait_trigger();

		//	$display($time," ************** scoreboard ********* que_in %p --- in_que_size  %0d \n\n\n que_out %p ---- out_que_size  %0d \n\n\n\n\n\n", in_que,in_que.size(),out_que,out_que.size);	

			foreach(out_que[i]) begin
				if(out_que[i] == in_que[i]) begin
				  `uvm_info( "SCOREBOARD PASS",$sformatf("********* PASS *******in_que = %0d out_que=%0d|| **********",in_que[i],out_que[i]),UVM_HIGH);
				end
				else begin
				 `uvm_info( "SCOREBOARD FAIL ",$sformatf("******** FAIL ******* in_que = %0d out_que=%0d|| **********",in_que[i],out_que[i]),UVM_HIGH);

				end
			end
//------------------ for deletion of queues in input and output monitor based on this flag ----
			h_eth_config_class.delete_flag=1;
			in_que.delete();
			out_que.delete();

		#20;
		end//}

	endtask

//=============== final phase for only displays ========

	function void final_phase(uvm_phase phase);
		super.final_phase(phase);

			$display("\n\n\n");

			$display($time," &&&&&&&&&&&&&&&&&&&&&&&& {pointer:{length,RD}} assoc  %p ------ size  %0d ",h_eth_config_class.length_pointer_assoc,h_eth_config_class.length_pointer_assoc.size);

			$display($time," &&&&&&&&&&&&&&&&&&&&&&&& TXBD  %p ",h_eth_config_class.TXD);

			$display($time," &&&&&&&&&&&&&&&&&&&&&&&& IRQ QUEUE  %p ",h_eth_config_class.irq_que);

			$display($time," &&&&&&&&&&&&&&&&&&&&&&&& TX_BD_NUM ----- %0d ",h_eth_config_class.TX_BD_NUM);

	endfunction
endclass



