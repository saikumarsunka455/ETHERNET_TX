//=====================config class==================//

class eth_config_class extends uvm_object;

//=========factory registration====================//

	`uvm_object_utils(eth_config_class)

//==============construction====================//

	function new(string name="");

		super.new(name);

	endfunction

//============registers declaration===================//

	int MODER;

	int INT_SOURCE;

	int INT_MASK;

	int TX_BD_NUM;

	int MIIADDRESS;

	int MAC_ADDR0;

	int MAC_ADDR1;

	int TXD[int];



task displays;
	int addr;
		$display($time,"-------------TX_EN ==%0d---------------",MODER[1]);
		$display($time,"-------------NOPRE ==%0d---------------",MODER[2]);
		$display($time,"-------------IFG ==%0d---------------",MODER[6]);
		$display($time,"-------------FULLD==%0d---------------",MODER[10]);
		$display($time,"-------------HUGEN ==%0d---------------",MODER[14]);
		$display($time,"-------------PAD ==%0d---------------",MODER[15]);
		$display($time,"-------------TXB_M ==%0d---------------",INT_MASK[0]);
		$display($time,"-------------TXE_M ==%0d---------------",INT_MASK[1]);
		$display($time,"-------------TX_BD_NUM ==%0d---------------",TX_BD_NUM[7:0]);
		$display($time,"------------Source ==%0d---------------",MIIADDRESS[7:0]);
		for(int i=1024;i<1024+((TX_BD_NUM[7:0])*8);i+=8)
			$display($time,"-------------Length =%0d-----------------",TXD[i][31:16]);
		
endtask	

//================= len , pointer storing assoc array of dynamic type values ---- {pointer:{length,RD}} ---- ========
	typedef int dyn_arr[2];
	dyn_arr length_pointer_assoc[int];
//=========== for storing the IRQ for every bd ======
	bit irq_que[$];
//=========== indication for deletion of queues =======
	bit delete_flag;
endclass



