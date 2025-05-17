
vlib work
vlog -sv top_nexys_a7.sv
vlog -sv dspl_drv_NexysA7.sv
vlog -sv tb_bulls_and_cows.sv

vsim -voptargs=+acc tb_bulls_and_cows

do wave_bulls.do

run -all
