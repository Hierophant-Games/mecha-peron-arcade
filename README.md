# The Rise and Fall of Mecha-Perón - Arcade
This is an arcade game based on the [Godot port](https://github.com/Hierophant-Games/mecha-peron-godot) of the [original Flash game](https://github.com/Hierophant-Games/mecha-peron).

- Developed by:
    - Santiago Martin Vilar
    - Nicolás Viegas Palermo

This game is intended to be compiled and deployed onto raspberry pi hardware. In order to set it up to boot straight into the game, the steps are as follows:

## 1. Prepare a game build to be loaded onto the raspberry pi:
- Export the game for as an ARM64 Linux, name the executable something easy to remember, for example: `MechaPeron.arm64`
- Copy the file over to an USB Drive

## 2. Raspberry Pi Setup:
- Install raspberry OS Lite onto the device's sd card, insert the card and boot the device.
- Log into your raspberri pi user and open the raspberri pi configuration screen using the command: `sudo raspi-config`, enter the boot settings and select console with autologin, reboot the system.
- Install x11 using the command: `sudo apt install xserver-xorg xinit x11-xserver-utils`.
    
## 3. Install/Update the game binary:
- Plug in the prepared usb device.
- In the raspberry pi terminal Make an empty folder onto which to mount the drive, i.e.: `mkdir drive`.
- Mount the drive onto the created folder using the command `sudo mount /dev/sda1 ~/drive`.
- Copy the game binary over: `cp ~/drive/Mechaperon.arm64 ~/MechaPeron.arm64`
    - *Note*: If updating the game with a newer version of the executable, you might want to backup the current version of the game, just in case like so: `cp ~/MechaPeron.arm64 ~/MechaPeron_backup.arm64`.
- To ensure the game is properly executable, enter the command `chmod +x ~/Mechaperon.arm64`.

## 4. Configure Raspberri Pi device to boot straight into the game:
- Create an `.xinitrc` file by entering the command: `touch .xinitrc`.
- Enter the command `vi .xinitrc`, and enter edit mode by pressing the `i` key, enter the line `exec ~/MechaPeron.arm64`, press `esc` to exit edit mode and then save and exit by entering `:x!`.
    - *Note*: This will make it so that initializing x11 starts the game. You can test it by running the command `startx` by hand.
- Similarly, edit the `.bashrc` file using vi: `vi .bashrc`, edit it by pressing the `i` key and enter the following at the end of the file:
    ```
    if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    exec startx
    fi
    ```
    press `esc` to exit edit mode and then save and exit by entering `:x!`
    - *Note*: Ths change will make it so that every time the terminal loads the `.bashrc` file, it starts x11, which will in turn run the game. Once the device is rebooted, the game should autostart. If you exit the game onto the terminal it should reopen.
    
- **Important**: If you want to stop this behavior from happening for any reason (i.e.: to perform maintenance) you can do it by using the shortcut `ctrl+ alt + f2` to open a new tab in the raspberry pi console, logging in, editing the `.bashrc` file to comment out the `exec startx`. After doing so you can safely reboot the device and the game won't autostart, booting straight onto the console.