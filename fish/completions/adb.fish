function __adb_need_arg
    set cmd (commandline -opc)
    if [ (count $cmd) -gt 1 ]
        return 1
    end
    return 0
end

complete -f -c adb -n '__adb_need_arg' -a 'devices connect disconnect push pull sync shell shell emu logcat forward jdwp install uninstall bugreport backup restore help version wait-for-device start-server kill-server get-state get-serialno get-devpath status-window remount reboot reboot-bootloader root usb tcpip ppp'
