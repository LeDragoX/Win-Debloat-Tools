function Restart-AdvancedMode() {
    # -r: Restart after shutdown
    # -o: Reboot into the advanced menu
    # -t: Time before shutdown
    # -f: Force shutdown
    shutdown -o -r -f -t 0
}

Restart-AdvancedMode
