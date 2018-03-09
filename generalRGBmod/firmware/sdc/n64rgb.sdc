## Generated SDC file "n64rgb.out.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

## DATE    "Thu Mar 17 08:11:47 2016"

##
## DEVICE  "EPM240T100C5"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {VCLK} -period 20.000 -waveform { 0.000 10.000 } [get_ports { VCLK }]
create_clock -name {nDSYNC} -period 80.000 -waveform { 0.000 60.000 } [get_ports { nDSYNC }]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock { VCLK } -min 5.4 [get_ports {nDSYNC}]
set_input_delay -clock { VCLK } -max 6.4 [get_ports {nDSYNC}]
set_input_delay -clock { VCLK } -min 5.4 [get_ports {D_i[*]}]
set_input_delay -clock { VCLK } -max 6.4  [get_ports {D_i[*]}]
set_input_delay -clock { nDSYNC } -min -1 -add_delay [get_ports {D_i[*]}]
set_input_delay -clock { nDSYNC } -max 1 -add_delay [get_ports {D_i[*]}]


#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

