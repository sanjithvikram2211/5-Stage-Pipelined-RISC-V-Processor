
# ==========================================
# 5-Stage Pipelined 32-bit RISC-V Processor
# ModelSim Simulation Script
# ==========================================

# Create working library
vlib work

# Compile RTL files
vlog RTL/*.v

# Compile Testbench
vlog Testbench/15_RISC_V_TB.v

# Start simulation
vsim -voptargs=+acc work.RISC_V_TB

# ==========================================
# CLOCK AND RESET
# ==========================================

add wave -divider "CLOCK AND RESET"

add wave -radix binary sim:/RISC_V_TB/clk
add wave -radix binary sim:/RISC_V_TB/reset

# ==========================================
# INSTRUCTION FETCH STAGE
# ==========================================

add wave -divider "INSTRUCTION FETCH"

add wave -radix unsigned sim:/RISC_V_TB/DUT/pc
add wave -radix hexadecimal sim:/RISC_V_TB/DUT/instruction

# ==========================================
# INSTRUCTION DECODE STAGE
# ==========================================

add wave -divider "INSTRUCTION DECODE"

add wave -radix hexadecimal sim:/RISC_V_TB/DUT/ifid_instruction
add wave -radix unsigned sim:/RISC_V_TB/DUT/idex_data1
add wave -radix unsigned sim:/RISC_V_TB/DUT/idex_data2

# ==========================================
# EXECUTE STAGE
# ==========================================

add wave -divider "EXECUTE STAGE"

add wave -radix unsigned sim:/RISC_V_TB/DUT/alu_result
add wave -radix unsigned sim:/RISC_V_TB/DUT/forward_data_a
add wave -radix unsigned sim:/RISC_V_TB/DUT/forward_data_b
add wave -radix unsigned sim:/RISC_V_TB/DUT/exmem_alu_result

# ==========================================
# HAZARD DETECTION AND FORWARDING
# ==========================================

add wave -divider "HAZARD AND FORWARDING"

add wave -radix binary sim:/RISC_V_TB/DUT/stall
add wave -radix binary sim:/RISC_V_TB/DUT/forward_a
add wave -radix binary sim:/RISC_V_TB/DUT/forward_b

# ==========================================
# MEMORY ACCESS STAGE
# ==========================================

add wave -divider "MEMORY ACCESS"

add wave -radix unsigned sim:/RISC_V_TB/DUT/memory_read_data
add wave -radix binary sim:/RISC_V_TB/DUT/exmem_mem_read
add wave -radix binary sim:/RISC_V_TB/DUT/exmem_mem_write

# ==========================================
# WRITE BACK STAGE
# ==========================================

add wave -divider "WRITE BACK"

add wave -radix unsigned sim:/RISC_V_TB/DUT/writeback_data

# ==========================================
# RUN SIMULATION
# ==========================================

run -all

# ==========================================
# END OF SCRIPT
# ==========================================
