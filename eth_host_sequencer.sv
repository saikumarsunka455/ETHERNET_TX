class eth_host_sequencer extends uvm_sequencer #(eth_sequence_item);

	`uvm_component_utils(eth_host_sequencer); //factory registraction for component

	//=========constructor===========

	function new(string name = "eth_host_sequencer",uvm_component parent);
		super.new(name,parent);
	endfunction

endclass
