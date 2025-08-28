class eth_mac_output_monitor extends uvm_monitor;

//====================factory registration =================
	`uvm_component_utils(eth_mac_output_monitor)

	 eth_sequence_item h_seq_item;
	virtual eth_interface h_eth_interface;
   	eth_config_class h_eth_config_class; 
//===============construction =======================

	function new(string name="", uvm_component parent);
		super.new(name,parent);
	endfunction

	nibble_queue queue_nibble_out,queue_crc;

//=============== uvm event pool =======
	uvm_event event_out_mon;
//========== ANALYSIS PORT ====================
	uvm_analysis_port #(nibble_queue) h_mac_output_monitor_port;

//====================build phase=======================

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		h_mac_output_monitor_port = new("h_mac_output_monitor_port",this);
		h_seq_item = eth_sequence_item::type_id::create("h_seq_item",this);

	endfunction

//===========================connect phase=====================

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		uvm_config_db #(virtual eth_interface) :: get(this , "" , "eth_interface", h_eth_interface);
		assert(uvm_config_db #(eth_config_class)::get(null,this.get_full_name(),"eth_config_class",h_eth_config_class));
		event_out_mon = uvm_event_pool :: get_global("event_sb_out");
	endfunction

//========================run phase=====================

	task run_phase(uvm_phase phase);

		super.run_phase(phase);
		
		forever @(h_eth_interface.cb_mac_monitor) 
		begin
				h_seq_item.MTxD = h_eth_interface.cb_mac_monitor.MTxD;				
				h_seq_item.MTxen = h_eth_interface.cb_mac_monitor.MTxen;
				h_seq_item.MTxerr = h_eth_interface.cb_mac_monitor.MTxerr;
//======================= MONITOR CHECK TASK=========================
				if(h_eth_config_class.MODER[1] && !h_eth_config_class.MODER[0]) MONITOR_CHECK();
//======================== WRITE METHOD INVOCATION===================
				h_mac_output_monitor_port.write(queue_nibble_out);
//---------------------------- deletion of payload queue after completion of every bd --------		
				if(h_eth_config_class.delete_flag) queue_nibble_out.delete();				
		end
	endtask






//===================================================================================================================================================//-------------------------------------------------------------- INTERNAL VARIABLES------------------------------------------------------------------//===================================================================================================================================================

	int nibble_count;//counter value will be incremented when we receive 4 bits of valid data from TXMAC

	bit payload_swap;//used for payload switiching of receiving data.example receiving is lsb , msb . we want to store msb , lsb.
	bit [3:0]lsb_payload;// storing the frst receiving lsb payload.

	bit no_pre_flag;//flag used to block the loading of nibble count = 14 for every posedge.it should load only once during start of packet.

//===================================== BELOW REPRESENTED FLAGS USED TO  INDICATE EVERY RECIEVING DATA OF RESPECTIVE FIELD IS CRCT OR NOT.
	bit [13:0] preamble_flag;
	bit [1:0]sfd_flag;
	bit [11:0]destination_flag,source_flag;
	bit [3:0]lenght_flag;

//===================================== BELOW REGISTER INDICATES MAXIMUM PAYLOAD COUNT WITH RESPECT TO NIBBLE COUNTER.
	int payload_max_value;
	
//===================================== BELOW REPRESENTED STATUS FLAGS USED TO INDICATE RESPECTIVE FIELD DATA RECEIEVED IS TRUE OR NOT.
	bit preamle_status,sfd_status,destination_status,source_status,lenght_status;

//===================================== BELOW REGISTER USED TO RETRIVE LENGTH OF RESPECTIVE BD LOCATION
	int tx_bd_memory_loc_addr = 1024;







//===================================================================================================================================================//--------------------------------------------------PACKET CHECKS STARTED----------------------------------------------------------------------------//==================================================================================================================================================
	task MONITOR_CHECK();
		if(h_seq_item.MTxen)
		begin
			if(h_eth_config_class.MODER[2] == 1 && no_pre_flag == 'd0)//=========== if moder[2] == 1 means frame shouldn't contain preamble.
			begin
				nibble_count = 14;//making counter to 14 i.e because to skip PREAMBLE task during nopre == 1.
				no_pre_flag = 1'b1;			
			end

//============= task should execute for 14 times because preamble is of 7 bytes for every clk on mrxd we will receiver 4 bits, so for 7 bytes we need to wait for 14 clocks.
			if(nibble_count < 14)
			begin
				PREAMBLE_CHECK();
			end
//============= task should execute for 2 times because sfd is of 1 byte for every clk on mrxd we will receiver 4 bits, so for 1 byte we need to wait for 2 clocks.
			else if(nibble_count < 16)
			begin
				SFD_CHECK();
			end
//============= task should execute for 12 times because destination address is of 6 bytes for every clk on mrxd we will receiver 4 bits, so for 6 byte we need to wait for 12 clocks.

			else if(nibble_count < 28)
			begin
				DESTINATION_ADDR_CHECK();
			end

//============= task should execute for 12 times because source address is of 6 bytes for every clk on mrxd we will receiver 4 bits, so for 6 byte we need to wait for 12 clocks.

			else if(nibble_count <40) 
			begin
				SOURCE_ADDR_CHECK();
			end
//============= task should execute for 4 times because lenght is of 2 bytes for every clk on mrxd we will receiver 4 bits, so for 2 byte we need to wait for 4 clocks.
			else if(nibble_count <44)
			begin
				LENGTH_CHECK();
			end
//============= task should execute for legth*2 times becaus payload varies.
			else if(nibble_count <payload_max_value)
			begin
				PAYLOAD_CHECK();

			end
//============= task should execute for 8 times because crc is of 4 bytes for every clk on mrxd we will receiver 4 bits, so for 4 byte we need to wait for 8 clocks.

			else if(nibble_count <payload_max_value+8)
			begin
					CRC_CHECK();
			end
			nibble_count++;
			if(nibble_count == payload_max_value+8 && no_pre_flag==1)
			begin
				nibble_count = 0;
				no_pre_flag = 0;
				event_out_mon.trigger();//----- event trigger for scoreboard comparision after 1 bd ---
			end
		//	$display($time,"============ nibble_count = %d",nibble_count);
		end
		else
		begin
	//		`uvm_info("OUTPUT_MONITOR",$sformatf("================ PACKET TRANSMISSION IS NOT YET STARTED"),UVM_DEBUG);
		end
	endtask




	task PREAMBLE_CHECK();
		if(h_seq_item.MTxD == 'b0101)
		begin
			preamble_flag[nibble_count] = 1'b1;
		end
		else
		begin
			preamble_flag[nibble_count] = 1'b0;
		end
			`uvm_info("MAC_OUTPUT_MONITOR",$sformatf(" preamble_flag = %b",preamble_flag),UVM_DEBUG);
		if(nibble_count == 13)
		begin
		
			preamle_status = &preamble_flag;
			no_pre_flag=1;
			`uvm_info("MAC_OUTPUT_MONITOR",$sformatf("preamle_status = %b",preamle_status),UVM_DEBUG);

		end
	endtask

	task SFD_CHECK();
		if(nibble_count == 14)
		begin
			if(h_seq_item.MTxD == 'b0101)
			begin
				sfd_flag[0] = 1;
			end
			else 
			begin
				sfd_flag[0] = 0;
			end

		end	
		else if(nibble_count == 15)
		begin
			if(h_seq_item.MTxD == 'b1101)
			begin
				sfd_flag[1] = 1;
			end
			else
			begin 
				sfd_flag[1] = 0;
			end
			sfd_status = &sfd_flag;
			`uvm_info("MAC_OUTPUT_MONITOR",$sformatf("sfd   _flag = %b",sfd_flag),UVM_DEBUG);
			`uvm_info("MAC_OUTPUT_MONITOR",$sformatf("sfd    _status = %b",sfd_status),UVM_DEBUG);
		end

	endtask




	task DESTINATION_ADDR_CHECK();
			if(nibble_count == 17)
			begin
				if(h_seq_item.MTxD == 'b1100)
				begin
					destination_flag[nibble_count%16] = 1;
				end
				else
				begin 
					destination_flag[nibble_count%16] = 0;
				end
			end
			else 
			begin
				if(h_seq_item.MTxD == 0)
				begin
					destination_flag[nibble_count%16] = 1;
				end
				else
				begin 
					destination_flag[nibble_count%16] = 0;
				end
	
			end
			`uvm_info("MAC_OUTPUT_MONITOR",$sformatf("destination_flag = %b",destination_flag),UVM_DEBUG);
			if(nibble_count == 27)
			begin
					destination_status = &destination_flag;
			`uvm_info("MAC_OUTPUT_MONITOR",$sformatf("destination_status= %b",destination_status),UVM_DEBUG);
			end
	endtask




	task SOURCE_ADDR_CHECK;
			if(nibble_count == 28)
			begin
				if(h_seq_item.MTxD == h_eth_config_class.MAC_ADDR1[15:12])
				begin
					source_flag[nibble_count%28] = 1;
				end
				else
				begin 
					source_flag[nibble_count%28] = 0;
				end
			end
			else if(nibble_count == 29)
			begin
				if(h_seq_item.MTxD == h_eth_config_class.MAC_ADDR1[11:8])
				begin
					source_flag[nibble_count%28] = 1;
				end
				else
				begin 
					source_flag[nibble_count%28] = 0;
				end
			end
			else if(nibble_count == 30)
			begin
				if(h_seq_item.MTxD == h_eth_config_class.MAC_ADDR1[7:4])
				begin
					source_flag[nibble_count%28] = 1;
				end
				else
				begin 
					source_flag[nibble_count%28] = 0;
				end
			end
			else if(nibble_count == 31)
			begin
				if(h_seq_item.MTxD == h_eth_config_class.MAC_ADDR1[3:0])
				begin
					source_flag[nibble_count%28] = 1;
				end
				else
				begin 
					source_flag[nibble_count%28] = 0;
				end
			end

			else 
			begin
				if(h_seq_item.MTxD == 0)
				begin
					source_flag[nibble_count%28] = 1;
				end
				else
				begin 
					source_flag[nibble_count%28] = 0;
				end
	
				if(nibble_count == 39)
				begin
					source_status = &source_flag;
					`uvm_info("MAC_OUTPUT_MONITOR",$sformatf("source _status= %b",source_status),UVM_DEBUG);		
				end
		  	end
			`uvm_info("MAC_OUTPUT_MONITOR",$sformatf("source_flag = %b",source_flag),UVM_DEBUG);
	endtask




	task LENGTH_CHECK;
			case(nibble_count)
			40: 
				begin
					if(h_eth_config_class.TXD[tx_bd_memory_loc_addr][27:24] == h_seq_item.MTxD)
					 		lenght_flag[nibble_count % 40] = 1'b1;
					else
					 		lenght_flag[nibble_count % 40] = 1'b0;
								
				end
			41:
				begin
					if(h_eth_config_class.TXD[tx_bd_memory_loc_addr][31:28] == h_seq_item.MTxD)
					 		lenght_flag[nibble_count % 40] = 1'b1;
					else
					 		lenght_flag[nibble_count % 40] = 1'b0;
								
				end

			42:
				begin
					if(h_eth_config_class.TXD[tx_bd_memory_loc_addr][19:16] == h_seq_item.MTxD)
					 		lenght_flag[nibble_count % 40] = 1'b1;
					else
					 		lenght_flag[nibble_count % 40] = 1'b0;
								
				end

			43:
				begin
					if(h_eth_config_class.TXD[tx_bd_memory_loc_addr][23:20] == h_seq_item.MTxD)
					 		lenght_flag[nibble_count % 40] = 1'b1;
					else
					 		lenght_flag[nibble_count % 40] = 1'b0;
					lenght_status = &lenght_flag;	
					payload_max_value = (h_eth_config_class.TXD[tx_bd_memory_loc_addr][31:16] < 46)?(92 +  nibble_count + 1):(h_eth_config_class.TXD[tx_bd_memory_loc_addr][31:16]*2 + nibble_count + 1);
					`uvm_info("MAC_OUTPUT_MONITOR",$sformatf("lenght_flag = %b,lenght_status = %b",lenght_flag,lenght_status),UVM_DEBUG);
					tx_bd_memory_loc_addr+=8;
				//	$display($time,"========================= tx_bd_memory_loc_addr = %d",tx_bd_memory_loc_addr);
				end
 
		endcase
	endtask

	task PAYLOAD_CHECK;
		case(payload_swap)
			'd0: begin lsb_payload = h_seq_item.MTxD;payload_swap++;end
			'd1: begin 
					 queue_nibble_out.push_back(h_seq_item.MTxD);
					 queue_nibble_out.push_back(lsb_payload);
					 payload_swap = 0;
				end
		endcase
				//	 $display($time,"============= queue_nibble_out = %p queuq size = %d",queue_nibble_out,queue_nibble_out.size());
	endtask
	
	task CRC_CHECK;
				queue_crc.push_back(h_seq_item.MTxD);
			/*	if(queue_crc.size == 8)
				begin
					nibble_count= 0;
				end*/
				//	$display($time,"============== queue crc = %p",queue_crc);

	endtask



endclass


