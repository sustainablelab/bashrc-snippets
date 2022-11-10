# --- Append this to ~/.profile ---
#
# Do not install STM32CubeProgrammer to default path.
# Install in /home/mike/.local/bin/ as shown below
#
# set PATH so it includes user's STM32CubeProgrammer bin if it exists
if [ -d "/home/mike/.local/bin/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/" ] ; then
    PATH="/home/mike/.local/bin/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/:$PATH"
fi

# --- Put this in ~/.bashrc ---
# Run STM32_Programmer_CLI to download Flash with STLINKV3
alias stm32cli='STM32_Programmer_CLI'

# =====[ stm32cli folder variables ]=====
#
# Usage : cd $firmware
export firmware="/home/mike/work/radlabs/gitrepos/arm-workspace/"
#
# Usage : cd $firmware; ls # see the repos; cd display-a/; cd $build
export build="BUILD/XDOT_L151CC/ARMC6"
#
# Usage : now invoke stm32cli or use an stm32cli_ alias below
#
# # Read (all) 256KB (262144 bytes) of Flash into ~/flash.hex:
# stm32cli -c port=SWD freq=8000 mode=UR -r 0x08000000 0x40000 ~/flash.hex
#
# # Read (all) 8KB (8192 bytes) of EEPROM into ~/eeprom.hex:
# stm32cli -c port=SWD freq=8000 mode=UR -r 0x08080000 0x2000 ~/eeprom.hex
#
# # Write display-a.bin to Flash, then restart the processor
# stm32cli -c port=SWD freq=8000 mode=UR -d display-a.bin 0x08000000 -s 0x08000000

# Test communication with STLINKV3
# Also useful to RESET the processor
alias stm32cli_reset='stm32cli -c port=SWD freq=8000 mode=UR'

# Write a .bin to Flash
# Usage: cd into folder with `.bin` then `stm32cli_flash bob.bin`
#
function stm32cli_flash() {
    if [ $# == 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
    then
        echo "Usage:"
        echo "  cd \$firmware"
        echo "  cd sensors-a"
        echo "  cd \$build"
        echo "  ls *.bin"
        echo "  stm32cli_flash sensors-a.bin"
    else
        stm32cli -c port=SWD freq=8000 mode=UR -d $1 0x08000000 -s 0x08000000
    fi
}
