# swap-sys

Some bash duct tape to re-create sys-* qubes for Qubes OS

-------------

### Intro

- Help users transition to more appropriate `sys-*` qubes
- By default, Qubes OS installation media creates integral `sys-*` qubes based on "full" TemplateVMs
- This is contrary to efforts to minimize surface area ...

			"¯\_ (ツ)_/¯ "

- Currently, only focused on swapping `sys-usb`, `sys-net` & `sys-firewall` qubes
- Easily adaptable to incorporate non-default `sys-*` qubes (`sys-audio`, etc.)
- TODO Nothing, duct tape fixes everything!

-------------

### Notes

- For `sys-net`, be sure to replace `firmware-iwlwifi` in the script with appropriate drivers for system used.
- Uses template name to determine package manager (`apt` vs. `dnf`) to be used.
- Modify accordingly if TemplateVM name does NOT include: "ebian"/"icksecure" OR "edora"/"oreos" for debian & redhat based systems.

-------------

### Installation for Qubes 4.1

##### In dispXXX Qube:

```sh
git clone https://github.com/cayc3/swap-sys
```

##### In dom0:

CLI:

```sh
sudo qvm-run --pass-io dispXXX 'cat /home/user/swap-sys/swap-sys.sh' | tee -a swap-sys.sh >& /dev/null; chmod +x swap-sys.sh; sudo ./swap-sys.sh
```

GUI (`zenity`):

```sh
sudo qvm-run --pass-io dispXXX 'cat /home/user/swap-sys/swap-sys-gui.sh' | tee -a swap-sys-gui.sh >& /dev/null; chmod +x swap-sys-gui.sh; sudo ./swap-sys-gui.sh
```

-------------

### Basic steps applied:

01. Create TemplateVM + AppVM (Template for disposable) for each `sys-*` qubes
02. Shutdown `sys-*` qubes
03. Backup existing `sys-*` qubes
04. Remove existing `sys-*` qubes
05. Salt new `sys-*` qubes based on desired TemplateVM

-------------

Project is free for personal use, donations are welcome.


BTC: bc1q3ssxvtcve8pwf2ge7rn2a2flrxrpz5xjtg9lyp

