# Combo II-DLD S75 / MAIN CLOCK F = 50 MHz
set_property PACKAGE_PIN B6 [get_ports clk_50mhz]
set_property PACKAGE_PIN K4 [get_ports rst_p]
set_property PACKAGE_PIN Y21 [get_ports piezo]
set_property IOSTANDARD LVCMOS33 [get_ports *]

# 50 MHz 클록 제약 (주기 20.000 ns)
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]

# 비동기 리셋 입력 타이밍 예외 처리
set_false_path from [get_ports rst_p]