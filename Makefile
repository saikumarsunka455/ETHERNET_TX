home = /home/chicago/tools/Questa_2021.4_3/questasim/linux_x86_64/../modelsim.ini


pack = eth_package.sv

top = eth_top.sv

interface = eth_interface.sv

work:
	vlib work
map:
	vmap work work 

	
#good_frame=0,
#bad_frame=1
#good_frame_len_lt_46=2
#good_frame_len_gt_1500=3
#good_frame_len_bw_46_to_1500=4
#bd_num_flag=1 (randomize) 0 (non_randomize)

comp_good_frame:
	vlog -work work +cover +acc -sv $(pack) $(top) $(interface)
	vsim -coverage -sva -c -do "log -r /*;coverage save -onexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l comp_good_frame.log  -wlf comp_good_frame.wlf work.top +UVM_TESTNAME=eth_test +svSeed=RANDOM +UVM_VERBOSITY=UVM_HIGH +bd_value=2 +type_frame1=0 +bd_num_flag=0
comp_bad_frame:
	vlog -work work +cover +acc -sv $(pack) $(top) $(interface)
	vsim -coverage -sva -c -do "log -r /*;coverage save -onexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l comp_bad_frame.log  -wlf comp_bad_frame.wlf work.top +UVM_TESTNAME=eth_test +svSeed=RANDOM +UVM_VERBOSITY=UVM_HIGH +bd_value=1 +type_frame1=1 +bd_num_flag=1
comp_good_frame_len_lt_46:
	vlog -work work +cover +acc -sv $(pack) $(top) $(interface)
	vsim -coverage -sva -c -do "log -r /*;coverage save -onexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l comp_good_frame_len_lt_46.log  -wlf comp_good_frame_len_lt_46.wlf work.top +UVM_TESTNAME=eth_test +svSeed=RANDOM +UVM_VERBOSITY=UVM_HIGH +bd_value=10 +type_frame1=2 +bd_num_flag=1

comp_good_frame_len_gt_1500:
	vlog -work work +cover +acc -sv $(pack) $(top) $(interface)
	vsim -coverage -sva -c -do "log -r /*;coverage save -onexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l comp_good_frame_len_gt_1500.log  -wlf comp_good_frame_len_gt_1500.wlf work.top +UVM_TESTNAME=eth_test +svSeed=RANDOM +UVM_VERBOSITY=UVM_HIGH +bd_value=10 +type_frame1=3 +bd_num_flag=1

comp_good_frame_len_bw_46_to_1500:
	vlog -work work +cover +acc -sv $(pack) $(top) $(interface)
	vsim -coverage -sva -c -do "log -r /*;coverage save -onexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l comp_good_frame_len_bw_46_to_1500.log  -wlf comp_good_frame_len_bw_46_to_1500.wlf work.top +UVM_TESTNAME=eth_test +svSeed=RANDOM +UVM_VERBOSITY=UVM_HIGH +bd_value=10 +type_frame1=4 +bd_num_flag=1


comp_good_frame_max_bds_128:
	vlog -work work +cover +acc -sv $(pack) $(top) $(interface)
	vsim -coverage -sva -c -do "log -r /*;coverage save -onexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l comp_good_frame.log  -wlf comp_good_frame.wlf work.top +UVM_TESTNAME=eth_test +svSeed=RANDOM +UVM_VERBOSITY=UVM_HIGH +bd_value=128 +type_frame1=0 +bd_num_flag=0

comp_nopre:
	vlog -work work +cover +acc -sv $(pack) $(top) $(interface)
	vsim -coverage -sva -c -do "log -r /*;coverage save -onexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l comp_nopre.log  -wlf comp_nopre.wlf work.top +UVM_TESTNAME=eth_test +svSeed=RANDOM +UVM_VERBOSITY=UVM_HIGH +UVM_SET_TYPE_OVERRIDE=eth_host_sequence,eth_host_sequence_no_pre +bd_value=10 +type_frame1=0 +bd_num_flag=0

comp_no_txen:
	vlog -work work +cover +acc -sv $(pack) $(top) $(interface)
	vsim -coverage -sva -c -do "log -r /*;coverage save -onexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l comp_no_txen.log  -wlf comp_no_txen.wlf work.top +UVM_TESTNAME=eth_test +svSeed=RANDOM +UVM_VERBOSITY=UVM_HIGH +UVM_SET_TYPE_OVERRIDE=eth_host_sequence,eth_host_sequence_no_tx_en +bd_value=10 +type_frame1=0 +bd_num_flag=0


comp_int_masking:
	vlog -work work +cover +acc -sv $(pack) $(top) $(interface)
	vsim -coverage -sva -c -do "log -r /*;coverage save -onexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l comp_int_masking.log  -wlf comp_int_masking.wlf work.top +UVM_TESTNAME=eth_test +svSeed=RANDOM +UVM_VERBOSITY=UVM_HIGH +UVM_SET_TYPE_OVERRIDE=eth_host_sequence,eth_host_sequence_int_masking +bd_value=2 +type_frame1=0 +bd_num_flag=0

comp_IRQ_toggle:
	vlog -work work +cover +acc -sv $(pack) $(top) $(interface)
	vsim -coverage -sva -c -do "log -r /*;coverage save -onexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l comp_IRQ_toggle.log  -wlf comp_IRQ_toggle.wlf work.top +UVM_TESTNAME=eth_test +svSeed=RANDOM +UVM_VERBOSITY=UVM_HIGH +UVM_SET_TYPE_OVERRIDE=eth_host_sequence,eth_host_sequence_IRQ_toggle +bd_value=4 +type_frame1=0 +bd_num_flag=0

comp_mtxerr:
	vlog -work work +cover +acc -sv $(pack) $(top) $(interface)
	vsim -coverage -sva -c -do "log -r /*;coverage save -onexit cover_file.ucdb -assert -directive -cvg -code All ;run -all ;exit" -coverage -sva -l comp_mtxerr.log  -wlf comp_mtxerr.wlf work.top +UVM_TESTNAME=eth_test +svSeed=RANDOM +UVM_VERBOSITY=UVM_HIGH +UVM_SET_TYPE_OVERRIDE=eth_mem_sequence,eth_mem_sequence_mtxerr_case +bd_value=1 +type_frame1=0 +bd_num_flag=0

sim1_code_cover:
	vlog -work work +cover +acc -sv $(pack) ../MCS_DV06_APB_TOP/mcs_dv06_apb_top.sv
	vsim -coverage -debugdb -c -do "log -r /*; coverage save -onexit coverfiles/sel_changes.ucdb -assert -cvg -directive -codeAll;run -all;exit" -l sel_changes.log work.top +UVM_TESTNAME=test +svSeed=RANDOM +UVM_VERBOSITY=UVM_HIGH



wave: 
	vsim -view apb.wlf &

merge:
	vcover merge all_cover.ucdb *.ucdb
	
clean:
	rm -rf *.ini transcript work regression_status_list *.log merge_list_file *.wlf .goutputstream* *.swp *.dbg wlf* *.vstf *.ucdb




