class eth_mem_input_monitor extends uvm_monitor;
	//============= FACTORY REGISTRATION
	`uvm_component_utils(eth_mem_input_monitor)

//================== instances =========	
	 eth_sequence_item h_seq_item;
	virtual eth_interface h_eth_interface;
   	eth_config_class h_eth_config_class; 

//============= indication for drop conditions ========
	bit[1:0] drop_frame_condition;
/*
	temp_length ----- storing the length of the bd based on pointer coming on m_paddr_o ---
	count ----- it increments every 4 octets of payload data coming on m_pwdata_o for checking payload collection based on length 
	payload_len ---- stores the length of payload collection because every posedge clk 4 octets of payload is coming --- 
	temp_RD ----- to store the RD for every bd...
*/
	int temp_length, count , payload_len;
	bit temp_RD;

//-------------------- nibble_queue declaration -----
	nibble_queue queue_nibble_store_in;


	//~~~~~~~~~Component_Construction~~~~~~//
	function new (string name="eth_mem_input_monitor",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	//========== ANALYSIS PORT ====================
	uvm_analysis_port #(nibble_queue) h_mem_input_monitor_port;
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);	
		h_mem_input_monitor_port = new("h_mem_input_monitor_port",this);
		h_seq_item = eth_sequence_item::type_id::create("h_seq_item",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		uvm_config_db #(virtual eth_interface) :: get(this , "" , "eth_interface", h_eth_interface);
        assert(uvm_config_db #(eth_config_class)::get(null,this.get_full_name(),"eth_config_class",h_eth_config_class));

	endfunction

//================= run phase ===============
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever@(h_eth_interface.cb_host_mem_monitor)
		begin
			h_seq_item.m_pready_i = h_eth_interface.cb_host_mem_monitor.m_pready_i;
			h_seq_item.m_prdata_i = h_eth_interface.cb_host_mem_monitor.m_prdata_i;
			h_seq_item.m_psel_o = h_eth_interface.cb_host_mem_monitor.m_psel_o;
			h_seq_item.m_penable_o = h_eth_interface.cb_host_mem_monitor.m_penable_o;
			h_seq_item.m_pwrite_o = h_eth_interface.cb_host_mem_monitor.m_pwrite_o;
			h_seq_item.m_paddr_o = h_eth_interface.cb_host_mem_monitor.m_paddr_o;
			h_seq_item.prstn_i = h_eth_interface.cb_host_mem_monitor.prstn_i;

//---------------------------------- payload nibble storing task calling by checking of txen=1 and rxen=0----------
			if(h_eth_config_class.MODER[1] && !h_eth_config_class.MODER[0]) payload_storing_check;
//------------------------------- write method -------------
			h_mem_input_monitor_port.write(queue_nibble_store_in);
//-------------------- deletion of payload queue after 1 bd comparision in scoreboard ------
			if(h_eth_config_class.delete_flag) queue_nibble_store_in.delete();



		end
	endtask
	
//===================== payload collection =========
	task payload_storing_check;

		if(h_seq_item.prstn_i && h_seq_item.m_psel_o && h_seq_item.m_penable_o && /*!h_seq_item.m_pwrite_o &&*/ h_seq_item.m_pready_i) begin//{

			count = count + 1;	//--------------- count for storing into the queue every 32 bit

//----------------- calling drop_frame_conditions task -------------
			drop_frame_check;

//---------------------after checking the drop condition and payload stored into the queuue
		if(drop_frame_condition==0 && temp_RD) begin//{


			if(temp_length%4==0) begin // if length is multiples of 4 
				payload_len = (temp_length/4);// eg: if length=28 for every posedge of clk collecting 4 bytes of payload so, 28/4=7 times are collecting
				if(count <= payload_len) begin	//count 1 to 7 --- total 7 times and payload_len is 7 so, count lessthan or equalto payload_len
					nibble_push('d28); 
					if(count==payload_len) pad_storing; //-- pad generation task calling based on configured length at last octets of payload
				end	
			end
			else begin // if length not multiples of 4
				payload_len = (temp_length/4)+1;//eg:if length=29 for every posedge of clk collecting 4 bytes of payload so, 29/4=7.25 times i.e 8, one extra octet is in another 32-bit so +1 times are collecting
				if(count <= payload_len-1) begin	// payload_len =8-1=7 and count 1 to 7-- total 7 timees so -1 of payload_len..
					nibble_push('d28);
				end	
				if(count == payload_len) begin //--- another 1 time push here count =8 and payload_len=8 at last octets of payload
					nibble_push_last_octets('d28);
					pad_storing;//-- pad generation task calling based on configured length at last octets of payload
				end
			end

		end//}
		end//}
	endtask

//=============pushing into the queue nibble by nibble =======
	task nibble_push(int k);
			for(int i=k;i>=0;i=i-4) begin
				queue_nibble_store_in.push_back(h_seq_item.m_prdata_i[i+:4]);
			end
	endtask

//=================== pushing the last octets of payload into the queue based on length and its remainders(active bytes of payload) ========
	task nibble_push_last_octets(int k);
			for(int i=k;i>=0;i=i-4) begin
				if(temp_length%4==1) if(i=='d20) break; 
				if(temp_length%4==2) if(i=='d12) break; 
				if(temp_length%4==3) if(i=='d4)  break; 
				queue_nibble_store_in.push_back(h_seq_item.m_prdata_i[i+:4]);
			end
	endtask

//================= drop frame checking ========
	task drop_frame_check;
		if((h_eth_config_class.length_pointer_assoc.exists(h_seq_item.m_paddr_o)) && count==1) begin //--- count ==1 is for this condition checks only for next bd starts because pointer values will increment by 4 , so exists will execute then length will change....
			temp_length = h_eth_config_class.length_pointer_assoc[h_seq_item.m_paddr_o][0]; //store lenth for respective existed pointer
			temp_RD = h_eth_config_class.length_pointer_assoc[h_seq_item.m_paddr_o][1]; //store RD for respective existed pointer
		//	count=0;
			if(temp_length<4) drop_frame_condition=1;
			else if(temp_length<46 && !h_eth_config_class.MODER[15]) drop_frame_condition=2;
			else if(temp_length>1518 && !h_eth_config_class.MODER[14]) drop_frame_condition=3;
		end
	endtask

//================== pad storing ===============
	task pad_storing;
		if(temp_length<46 && h_eth_config_class.MODER[15]) begin
			repeat(((46-temp_length)*2)) queue_nibble_store_in.push_back(0);
		end
		count =0;	//--- count 0 for starting of next bd --- because this pad_storing task will call last octets of payload ....
	endtask
endclass







//$display($time,"======== in the memory input monitor ========= m_prdata_i  %h  ----- m_paddr_o  %0d nibble que--- size %0d ----- lenth %0d ",h_seq_item.m_prdata_i,h_seq_item.m_paddr_o,queue_nibble_store_in.size(),temp_length);


//$display($time," &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& m_paddr_o %0d  tx_bd_num  %0d length_pointer_assoc %p --- count  %0d payload_len  %0d \n\n\n\n\n\n\n\n",h_seq_item.m_paddr_o,h_eth_config_class.TX_BD_NUM,h_eth_config_class.length_pointer_assoc,count,payload_len);


//$display($time,"======== in the memory input monitor ========= m_prdata_i  %h  ----- m_paddr_o  %0d nibble que--- size %0d ----- lenth %0d ---- count  %0d ",h_seq_item.m_prdata_i,h_seq_item.m_paddr_o,queue_nibble_store_in.size(),temp_length,count);

