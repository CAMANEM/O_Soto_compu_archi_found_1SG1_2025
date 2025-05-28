transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/bloodxe/Desktop/O_Soto_compu_archi_found_1SG1_2025/Proyecto1 {C:/Users/bloodxe/Desktop/O_Soto_compu_archi_found_1SG1_2025/Proyecto1/pwm.sv}

vlog -sv -work work +incdir+C:/Users/bloodxe/Desktop/O_Soto_compu_archi_found_1SG1_2025/Proyecto1 {C:/Users/bloodxe/Desktop/O_Soto_compu_archi_found_1SG1_2025/Proyecto1/tb_pwm.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_pwm

add wave *
view structure
view signals
run -all
