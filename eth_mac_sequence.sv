//====== mac sequence class =======//

class eth_mac_sequence extends uvm_sequence #(eth_sequence_item);

	`uvm_object_utils(eth_mac_sequence)   //=Factory registration

//===============construction =======================

	function new(string name = "");
		super.new(name);
	endfunction

//==========================task body============================//
task body();
		req=eth_sequence_item :: type_id::create("req");

//repeat(2) begin
		start_item(req);

		assert(req.randomize with{mcrs==0;});
	
		finish_item(req);
//end
		start_item(req);

		assert(req.randomize with{mcrs==0;});
	
		finish_item(req);


	endtask

endclass




