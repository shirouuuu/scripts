#!/bin/bash

# Initialize our own variables
OPTIND=1         # Reset in case getopts has been used previously in the shell.
turn_off=0
is_desktop=0

LEFT_MONITOR="DP-2"   # Linker Monitor: 4K@120Hz
RIGHT_MONITOR="DP-1"  # Rechter Monitor: 1440p@165Hz
TV="HDMI-A-1"
DUMMY_PLUG="HDMI-A-2"

# Konfigurationen
LEFT_RES="3840x2160@120"  
RIGHT_RES="2560x1440@165"
DUMMY_RES="2560x1600@60"
DUMMY_RES_1440="2560x1440@60"
TV_RES="3840x2160@60"

LEFT_POS="0,0"            
RIGHT_POS="2560,0"
TV_POS="5120,0"
DUMMY_POS="0,1440"

SCALE="1.0"    
SCALE_LEFT="1.5"
SCALE_DUMMY="2"

# Process command line options
while getopts "hod?" opt; do
    case "$opt" in
        h|\?)
            echo "Usage: $0 [-h] [-o] [-d]"
            exit 0
            ;;
        o)
            turn_off=1
            ;;
        d)
            is_desktop=1
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
done


shift $((OPTIND-1))

function turn_on {
    echo "TURN ON AND SET UP DESKTOP MONITORS..."
    kscreen-doctor \
        output.$LEFT_MONITOR.enable \
        output.$LEFT_MONITOR.mode.$LEFT_RES \
        output.$LEFT_MONITOR.position.$LEFT_POS \
        output.$LEFT_MONITOR.scale.$SCALE_LEFT \
        output.$RIGHT_MONITOR.primary \
        output.$RIGHT_MONITOR.enable \
        output.$RIGHT_MONITOR.mode.$RIGHT_RES \
        output.$RIGHT_MONITOR.position.$RIGHT_POS \
        output.$RIGHT_MONITOR.scale.$SCALE
    
    if kscreen-doctor -o | grep  "$TV"; then
        kscreen-doctor \
        output.$TV.enable \
        output.$TV.mode.$TV_RES \
        output.$TV.position.$TV_POS \
        output.$TV.scale.$SCALE_DUMMY
    else
        echo "TV output '$TV' not found – skipping."
    fi

    echo "DISABLE DUMMY PLUG..."
    kscreen-doctor output.$DUMMY_PLUG.disable
}

function turn_off {
    echo "SET UP DUMMY PLUG CONFIG..."
    kscreen-doctor \
        output.$DUMMY_PLUG.enable \
        output.$DUMMY_PLUG.position.$DUMMY_POS \
        output.$DUMMY_PLUG.scale.$SCALE_DUMMY \
        output.$DUMMY_PLUG.primary \

    if [ $is_desktop -eq 1 ]; then
        kscreen-doctor output.$DUMMY_PLUG.mode.$DUMMY_RES_1440
    else
        kscreen-doctor output.$DUMMY_PLUG.mode.$DUMMY_RES
    fi

    echo "TURN OFF DESKTOP MONITORS..."
    kscreen-doctor output.$LEFT_MONITOR.disable
    kscreen-doctor output.$RIGHT_MONITOR.disable
    
    if kscreen-doctor -o | grep  "$TV"; then
        kscreen-doctor output.$TV.disable
    else
        echo "TV output '$TV' not found – skipping."
    fi
}

if [ $turn_off -eq 1 ]; then
    turn_off
else
    turn_on
fi