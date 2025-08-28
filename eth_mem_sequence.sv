
class eth_mem_sequence extends uvm_sequence #(eth_sequence_item);

	`uvm_object_utils(eth_mem_sequence) ///factory registraction for object

//================ config class instance ========
   	eth_config_class h_eth_config_class; 

	//=======CONSTRUCTOR=========

	function new(string name = "eth_mem_sequence");
			super.new(name);
        assert(uvm_config_db #(eth_config_class)::get(null,this.get_full_name(),"eth_config_class",h_eth_config_class));
	endfunction


//==========================task body============================//
task body();
		req=eth_sequence_item :: type_id::create("req");
		$display($time,"=============================== parent==================================");
	for(int i=1024;i<(1024+(h_eth_config_class.TX_BD_NUM)*8);i=i+8) begin//{
		 h_eth_config_class.length_pointer_assoc[h_eth_config_class.TXD[i+4]][0] = h_eth_config_class.TXD[i][31:16];//-------storing the length and pointer of each txbd in assoc arr ---- index as a pointer and value as a length
		 h_eth_config_class.length_pointer_assoc[h_eth_config_class.TXD[i+4]][1] = h_eth_config_class.TXD[i][15];//-------storing the RD and pointer of each txbd in assoc arr ---- index as a pointer and value as a RD
			h_eth_config_class.irq_que.push_back(h_eth_config_class.TXD[i][14]); //--------- storing the IRQ for every bd 

			if(h_eth_config_class.length_pointer_assoc[h_eth_config_class.TXD[i+4]][0]%4==0) begin//{
				repeat(h_eth_config_class.length_pointer_assoc[h_eth_config_class.TXD[i+4]][0]/4) begin//{
					start_item(req);
					assert(req.randomize()with {m_pready_i==1;});
					finish_item(req);
				end//}
			end//}
			else begin//{
				repeat(((h_eth_config_class.length_pointer_assoc[h_eth_config_class.TXD[i+4]][0]/4)+1)) begin//{
//$display($time," $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ %0d ",(h_eth_config_class.length_pointer_assoc[h_eth_config_class.TXD[i+4]]/4)+1);
					start_item(req);
					assert(req.randomize()with {m_pready_i==1;});
					finish_item(req);
				end//}
			end//}
	end//}


//$display($time," &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& tx_bd_num  %0d length_pointer_assoc %p ------------ assoc size  %0d \n\n\n\n\n\n\n\n",h_eth_config_class.TX_BD_NUM,h_eth_config_class.length_pointer_assoc,h_eth_config_class.length_pointer_assoc.size());
	endtask


endclass


//------------------------------------Mtx error case----------------------------------------------------
//-------------------Mtx error will rise only when the length is greater then 64 -----------------------
//------------------here a example length is 72 and ready is for 64 bytes and --------------------------

class eth_mem_sequence_mtxerr_case extends eth_mem_sequence;

	`uvm_object_utils(eth_mem_sequence_mtxerr_case) ///factory registraction for object

//================ config class instance ========
   	eth_config_class h_eth_config_class; 

	//=======CONSTRUCTOR=========

	function new(string name = "eth_mem_sequence");
			super.new(name);
        assert(uvm_config_db #(eth_config_class)::get(null,this.get_full_name(),"eth_config_class",h_eth_config_class));
	endfunction


//==========================task body============================//
task body();
		req=eth_sequence_item :: type_id::create("req");

		$display($time,"=============================== extended==================================");
	for(int i=1024;i<(1024+(h_eth_config_class.TX_BD_NUM)*8);i=i+8) begin//{
		 h_eth_config_class.length_pointer_assoc[h_eth_config_class.TXD[i+4]][0] = h_eth_config_class.TXD[i][31:16];//-------storing the length and pointer of each txbd in assoc arr ---- index as a pointer and value as a length
		 h_eth_config_class.length_pointer_assoc[h_eth_config_class.TXD[i+4]][1] = h_eth_config_class.TXD[i][15];//-------storing the RD and pointer of each txbd in assoc arr ---- index as a pointer and value as a RD
			h_eth_config_class.irq_que.push_back(h_eth_config_class.TXD[i][14]); //--------- storing the IRQ for every bd 

			if(h_eth_config_class.length_pointer_assoc[h_eth_config_class.TXD[i+4]][0]%4==0) begin//{
				repeat((h_eth_config_class.length_pointer_assoc[h_eth_config_class.TXD[i+4]][0]/4)-2) begin//{
					start_item(req);
					assert(req.randomize() with {m_pready_i==1;});
					finish_item(req);
				end//}

			//	repeat(2) begin//{
					start_item(req);
					assert(req.randomize() with {m_pready_i==1;});
					finish_item(req);

					start_item(req);
					assert(req.randomize() with {m_pready_i==0;});
					finish_item(req);

			//	end//}
			end//}

			else begin//{
				repeat(((h_eth_config_class.length_pointer_assoc[h_eth_config_class.TXD[i+4]][0]/4)+1)) begin//{
//$display($time," $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ %0d ",(h_eth_config_class.length_pointer_assoc[h_eth_config_class.TXD[i+4]]/4)+1);
					start_item(req);
					assert(req.randomize());
					finish_item(req);
				end//}
			end//}
	end//}


//$display($time," &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& tx_bd_num  %0d length_pointer_assoc %p ------------ assoc size  %0d \n\n\n\n\n\n\n\n",h_eth_config_class.TX_BD_NUM,h_eth_config_class.length_pointer_assoc,h_eth_config_class.length_pointer_assoc.size());
	endtask


endclass
