
add wave -divider "Clock and Reset"
add wave -hexadecimal sim:/tb_bulls_and_cows/clk
add wave -hexadecimal sim:/tb_bulls_and_cows/rst

add wave -divider "User Inputs"
add wave -hexadecimal sim:/tb_bulls_and_cows/sw
add wave -hexadecimal sim:/tb_bulls_and_cows/btn

add wave -divider "Display Outputs"
add wave -hexadecimal sim:/tb_bulls_and_cows/seg
add wave -hexadecimal sim:/tb_bulls_and_cows/an
add wave -hexadecimal sim:/tb_bulls_and_cows/dp

add wave -divider "DUT Internal Signals"
add wave -hexadecimal sim:/tb_bulls_and_cows/dut/*
