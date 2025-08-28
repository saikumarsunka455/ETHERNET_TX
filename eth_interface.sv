//====================INTERFACE=====================//

interface eth_interface(input pclk_i , MTxclk);

//==============signal declaration===================//

//-------------host signals----------------//
	logic prstn_i , psel_i , pwrite_i , penable_i;
	logic [31:0] paddr_i , pwdata_i;
	logic [31:0] prdata_o;
	logic pready_o;
	logic int_o;

//-----------memory signals---------------------//

	logic [31:0]m_prdata_i;
	logic m_pready_i;
	logic [31:0] m_paddr_o;
	logic [31:0] m_pwdata_o;
	logic m_psel_o, m_pwrite_o, m_penable_o;

//--------------tx mac signals-------------------//

	logic MTxen , MTxerr,mcrs;
	logic [3:0] MTxD;

//==========clocking blocks declaration===================//

//-------------host mem driver----------------//
	clocking cb_host_mem_driver @(posedge pclk_i);

//=============== host signals ==========
		input pready_o , int_o;
		input prdata_o;
		output prstn_i , psel_i , pwrite_i , penable_i;
		output paddr_i , pwdata_i;

//======================= memory signals
		output m_prdata_i;
		output m_pready_i;
		input m_paddr_o;
		input m_pwdata_o;
		input  m_psel_o , m_pwrite_o , m_penable_o;


	endclocking


//-------------------host monitor-----------------------------------//
	clocking cb_host_mem_monitor @(posedge pclk_i);

//============== host signals 
		input pready_o , int_o;
		input prdata_o;
		input prstn_i , psel_i , pwrite_i , penable_i;
		input paddr_i , pwdata_i;

//==================== mmeory signals 
		input m_prdata_i;
		input m_pready_i;
		input m_paddr_o;
		input m_pwdata_o ;
		input  m_psel_o , m_pwrite_o , m_penable_o;

	endclocking

//------------------mac driver---------------------//

	clocking cb_mac_driver @(posedge MTxclk);

		output mcrs;
		input MTxerr , MTxen;
		input MTxD;


	endclocking

//------------------mac monitor---------------------//

	clocking cb_mac_monitor @(posedge MTxclk);

		input mcrs;
		input MTxerr , MTxen ;
		input MTxD;

	endclocking

/*
	always@(posedge pclk_i) begin
		$display($time," in the interface ---------- m_prdata_i %0d  ----- m_pready_i %0d ",m_prdata_i,m_pready_i);
	end
*/

	/*initial begin
		@(posedge pclk_i) prstn_i =1; m_psel_o=1; m_penable_o=0;m_pwrite_o=0;
		@(posedge pclk_i) prstn_i =1; m_psel_o=1; m_penable_o=1;m_pwrite_o=0;
	end*/

endinterface
