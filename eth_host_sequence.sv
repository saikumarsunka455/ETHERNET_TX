
class eth_host_sequence extends uvm_sequence #(eth_sequence_item);

	`uvm_object_utils(eth_host_sequence) ///factory registraction for object

	//=======CONSTRUCTOR=========

	function new(string name = "eth_host_sequence");
			super.new(name);
	endfunction

   	eth_config_class h_eth_config_class; 

	int bd_count;
//==========================task body============================//

	//-------------a prebody task for getting config class--------------//
	task pre_body;
        assert(uvm_config_db #(eth_config_class)::get(null,this.get_full_name(),"eth_config_class",h_eth_config_class));		
	endtask

	//-------------task for configuE all registers---------------------//
	task config_reg(int addr, bit write);
		start_item(req);
		assert(req.randomize with {paddr_i==addr;pwrite_i == write;}); 
		finish_item(req);
	endtask
	
	//-------------task for configure int mask register---------------//
	task config_reg_mask(int addr, bit write, bit txb_m_tb=1,bit txe_m_tb=1);
		start_item(req);
		assert(req.randomize with {paddr_i==addr;pwrite_i == write; TXE_M == txe_m_tb; TXB_M ==txb_m_tb;}); 
		finish_item(req);
	endtask

	//-------------task for moder register ---------------------------//
	task config_reg_moder(int addr, bit write, bit no_pre=1'b0,tx_en=1'b1);
		start_item(req);
		assert(req.randomize with {paddr_i==addr;pwrite_i == write; NOPRE == no_pre; TXEN ==tx_en;});
		finish_item(req);
	endtask


	//-----------for tx_bd_num---------------
	task t_tx_bd_num(bit write_tb=1'd1);
		config_reg('d32,write_tb);
	endtask

	//-----------for mii addr---------------
	task t_mii_addr(bit write_tb=1'd1);
		config_reg('d48,write_tb);
	endtask

	//------------for mac0-----------------
	task t_mac0(bit write_tb=1'd1);
		config_reg('d64,write_tb);
	endtask

	//-----------for mac1-----------------
	task t_mac1(bit write_tb=1'd1);
		config_reg('d68,write_tb);
	endtask

	//----------tx_bd_num----------------
		task t_txbd();
		  repeat(h_eth_config_class.TX_BD_NUM[7:0]) begin
			start_item(req);
				assert(req.randomize with {paddr_i==1024+bd_count;pwrite_i == 1'd1;});
			finish_item(req);

			start_item(req);
				assert(req.randomize with {paddr_i==1024+bd_count;pwrite_i == 1'd0;});
			finish_item(req);

			start_item(req);
				assert(req.randomize with {paddr_i==(1024+bd_count+4);pwrite_i == 1'd1;});
			finish_item(req);

			start_item(req);
				assert(req.randomize with {paddr_i==(1024+bd_count+4);pwrite_i == 1'd0;});
			finish_item(req);

		  bd_count= bd_count+8;
		end

	endtask

	task t_int_source(bit write_tb=1'd1);
		config_reg('d4,write_tb);
	endtask

	

task body();
		req=eth_sequence_item :: type_id::create("req");
		req.t1_txbd_value();
		req.t1_lenth;
//--------------TX_BD_NUM--32--------------------------//
		t_tx_bd_num(1);//write 
		t_tx_bd_num(0);//read
		

//--------------MII ADDRS--48--------------------------//
		t_mii_addr(1); //write
		t_mii_addr(0); //read

//--------------MAC0------64---------------------//
		t_mac0(1);
		t_mac0(0);
		
//--------------MAC1------68----------------------//
		t_mac1(1);
		t_mac1(0);

//--------------RX_BD---------------------------//
		t_txbd();
		
//--------------INT_SOURCE----4------------------------//
		t_int_source(1);
		t_int_source(0);

//--------------INT_MASK------8----------------------//
		config_reg_mask('d8,1'd1,1'b1,1'b1); //addr,write,txe,txb
		config_reg_mask('d8,1'd0,1'b1,1'b1);
		

//--------------MODER----------------------------//
		config_reg_moder('d0,1'd1,1'b1,1'b1); //addr,write,no_pre,tx_en;
		config_reg_moder('d0,1'd0,1'b1,1'b1);

		h_eth_config_class.displays();
	endtask

endclass



//==============================================================================================================
//-----------------------------------------No preamble----------------------------------------------------------
//==============================================================================================================


class eth_host_sequence_no_pre extends eth_host_sequence;

	`uvm_object_utils(eth_host_sequence_no_pre) ///factory registraction for object

	//=======CONSTRUCTOR=========

	function new(string name = "eth_host_sequence");
			super.new(name);
	endfunction


	int bd_count;
//==========================task body============================//


task body();
		req=eth_sequence_item :: type_id::create("req");
		req.t1_txbd_value();
		req.t1_lenth;
//--------------TX_BD_NUM--32--------------------------//
		t_tx_bd_num(1);//write 
		t_tx_bd_num(0);//read
		

//--------------MII ADDRS--48--------------------------//
		t_mii_addr(1); //write
		t_mii_addr(0); //read

//--------------MAC0------64---------------------//
		t_mac0(1);
		t_mac0(0);
		
//--------------MAC1------68----------------------//
		t_mac1(1);
		t_mac1(0);

//--------------RX_BD---------------------------//
//		t_txbd(h_eth_config_class.TX_BD_NUM[7:0]);
		t_txbd();
//--------------INT_SOURCE----4------------------------//
		t_int_source(1);
		t_int_source(0);

//--------------INT_MASK------8----------------------//
		config_reg_mask('d8,1'd1,1'b1,1'b1); //addr,write,txe,txb
		config_reg_mask('d8,1'd0,1'b1,1'b1);
		

//--------------MODER----------------------------//
		config_reg_moder('d0,1'd1,1'b1,1'b1); //addr,write,no_pre,tx_en;
		config_reg_moder('d0,1'd0,1'b1,1'b1);

		h_eth_config_class.displays();
	endtask
endclass
//==============================================================================================================
//--------------------------------------------No TX_EN----------------------------------------------------------
//==============================================================================================================


class eth_host_sequence_no_tx_en extends eth_host_sequence;

	`uvm_object_utils(eth_host_sequence_no_tx_en) ///factory registraction for object

	//=======CONSTRUCTOR=========

	function new(string name = "eth_host_sequence");
			super.new(name);
	endfunction


	int bd_count;
//==========================task body============================//


task body();
		req=eth_sequence_item :: type_id::create("req");
		req.t1_txbd_value();
		req.t1_lenth;
//--------------TX_BD_NUM--32--------------------------//
		t_tx_bd_num(1);//write 
		t_tx_bd_num(0);//read
		

//--------------MII ADDRS--48--------------------------//
		t_mii_addr(1); //write
		t_mii_addr(0); //read

//--------------MAC0------64---------------------//
		t_mac0(1);
		t_mac0(0);
		
//--------------MAC1------68----------------------//
		t_mac1(1);
		t_mac1(0);

//--------------RX_BD---------------------------//
//		t_txbd(h_eth_config_class.TX_BD_NUM[7:0]);
		t_txbd();
//--------------INT_SOURCE----4------------------------//
		t_int_source(1);
		t_int_source(0);

//--------------INT_MASK------8----------------------//
		config_reg_mask('d8,1'd1,1'b1,1'b1); //addr,write,txe,txb
		config_reg_mask('d8,1'd0,1'b1,1'b1);
		

//--------------MODER----------------------------//
		config_reg_moder('d0,1'd1,1'b0,1'b0); //addr,write,no_pre,tx_en;
		config_reg_moder('d0,1'd0,1'b0,1'b0);

		h_eth_config_class.displays();
	endtask
endclass

//==============================================================================================================
//--------------------------------------------INT MASKING-------------------------------------------------------
//==============================================================================================================


class eth_host_sequence_int_masking extends eth_host_sequence;

	`uvm_object_utils(eth_host_sequence_int_masking) ///factory registraction for object

	//=======CONSTRUCTOR=========

	function new(string name = "eth_host_sequence");
			super.new(name);
	endfunction


	int bd_count;
//==========================task body============================//


task body();
		req=eth_sequence_item :: type_id::create("req");
		req.t1_txbd_value();
		req.t1_lenth;
//--------------TX_BD_NUM--32--------------------------//
		t_tx_bd_num(1);//write 
		t_tx_bd_num(0);//read
		

//--------------MII ADDRS--48--------------------------//
		t_mii_addr(1); //write
		t_mii_addr(0); //read

//--------------MAC0------64---------------------//
		t_mac0(1);
		t_mac0(0);
		
//--------------MAC1------68----------------------//
		t_mac1(1);
		t_mac1(0);

//--------------RX_BD---------------------------//
//		t_txbd(h_eth_config_class.TX_BD_NUM[7:0]);
		t_txbd();
		
//--------------INT_SOURCE----4------------------------//
		t_int_source(1);
		t_int_source(0);

//--------------INT_MASK------8----------------------//
		config_reg_mask('d8,1'd1,1'b0,1'b0); //addr,write,txe,txb
		config_reg_mask('d8,1'd0,1'b0,1'b0);
		

//--------------MODER----------------------------//
		config_reg_moder('d0,1'd1,1'b0,1'b1); //addr,write,no_pre,tx_en;
		config_reg_moder('d0,1'd0,1'b0,1'b1);

		h_eth_config_class.displays();
	endtask
endclass


class eth_host_sequence_IRQ_toggle extends eth_host_sequence;

	`uvm_object_utils(eth_host_sequence_IRQ_toggle) ///factory registraction for object

	//=======CONSTRUCTOR=========

	function new(string name = "eth_host_sequence");
			super.new(name);
	endfunction

	task pre_body;
        assert(uvm_config_db #(eth_config_class)::get(null,this.get_full_name(),"eth_config_class",h_eth_config_class));		
	endtask


	int bd_count;

		task t_txbd();
//		  repeat(h_eth_config_class.TX_BD_NUM[7:0]) begin
		  for(int s;s<h_eth_config_class.TX_BD_NUM[7:0];s++) begin
			if(s%2==0) begin
				start_item(req);
					assert(req.randomize with {paddr_i==1024+bd_count;pwrite_i == 1'd1;IRQ==1;});
				finish_item(req);

				start_item(req);
					assert(req.randomize with {paddr_i==1024+bd_count;pwrite_i == 1'd0;});
				finish_item(req);

				start_item(req);
					assert(req.randomize with {paddr_i==(1024+bd_count+4);pwrite_i == 1'd1;});
				finish_item(req);

				start_item(req);
					assert(req.randomize with {paddr_i==(1024+bd_count+4);pwrite_i == 1'd0;});
				finish_item(req);

			  bd_count= bd_count+8;
		    end
			else begin
				start_item(req);
					assert(req.randomize with {paddr_i==1024+bd_count;pwrite_i == 1'd1;IRQ==0;});
				finish_item(req);

				start_item(req);
					assert(req.randomize with {paddr_i==1024+bd_count;pwrite_i == 1'd0;});
				finish_item(req);

				start_item(req);
					assert(req.randomize with {paddr_i==(1024+bd_count+4);pwrite_i == 1'd1;});
				finish_item(req);

				start_item(req);
					assert(req.randomize with {paddr_i==(1024+bd_count+4);pwrite_i == 1'd0;});
				finish_item(req);

			  bd_count= bd_count+8;


			end
		end

	endtask


//==========================task body============================//
task body();
		req=eth_sequence_item :: type_id::create("req");
		req.t1_txbd_value();
		req.t1_lenth;
//--------------TX_BD_NUM--32--------------------------//
		t_tx_bd_num(1);//write 
		t_tx_bd_num(0);//read
		

//--------------MII ADDRS--48--------------------------//
		t_mii_addr(1); //write
		t_mii_addr(0); //read

//--------------MAC0------64---------------------//
		t_mac0(1);
		t_mac0(0);
		
//--------------MAC1------68----------------------//
		t_mac1(1);
		t_mac1(0);

//--------------RX_BD---------------------------//
//		t_txbd(h_eth_config_class.TX_BD_NUM[7:0]);
		t_txbd();
		
//--------------INT_SOURCE----4------------------------//
		t_int_source(1);
		t_int_source(0);

//--------------INT_MASK------8----------------------//
		config_reg_mask('d8,1'd1,1'b1,1'b1); //addr,write,txe_m,txb_m
		config_reg_mask('d8,1'd0,1'b1,1'b1);
		

//--------------MODER----------------------------//
		config_reg_moder('d0,1'd1,1'b0,1'b1); //addr,write,no_pre,tx_en;
		config_reg_moder('d0,1'd0,1'b0,1'b1);

		h_eth_config_class.displays();
	endtask
endclass
