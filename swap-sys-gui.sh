#!/bin/bash
## config
LIST=$(qvm-ls --no-spinner | grep TemplateVM | awk '{print $1}')
TemplateVM=$(echo $LIST | sed 's/\s\+/\n/g' | zenity --list --title "Select TemplateVM" --text "Select the TemplateVM to be used for sys-* zubes: " --column "Templates" 2>/dev/null | sed 's/|//g')
PreFix=$(zenity --entry --text "Enter friendly PreFix: " 2>/dev/null)


#read -p "Enter Base TemplateVM: " TemplateVM
echo "Using $TemplateVM"
#read -p "Enter prefix: " PreFix
echo "Using $PreFix"

## create sys-usb templates:
##read -p "Enter Base TemplateVM: " TemplateVM
(
qvm-clone $TemplateVM $PreFix-sys-usb
echo "20"
qvm-start $PreFix-sys-usb
echo "40"
if [[ $TemplateVM =~ ([ebian] | [icksecure]) ]]; then qvm-run --pass-io -u root $PreFix-sys-usb "apt install -y qubes-usb-proxy"; fi
if [[ $TemplateVM =~ ([edora] | [oreos]) ]]; then qvm-run --pass-io -u root $PreFix-sys-usb "dnf install -y qubes-usb-proxy"; fi
echo "60"
qvm-shutdown $PreFix-sys-usb
echo "80"
qvm-create --template $PreFix-sys-usb --label red --property template_for_dispvms=True --class AppVM $PreFix-sys-usb-dvm
echo "100"
) |
zenity --progress  --auto-close --text="Creating new sys-usb Template ..."  2>/dev/null
echo "TemplateVM for sys-usb created!"

## create sys-net templates:
##read -p "Enter Base TemplateVM: " TemplateVM
(
qvm-clone $TemplateVM $PreFix-sys-net
echo "20"
qvm-start $PreFix-sys-net
echo "40"
if [[ $TemplateVM =~ ([ebian] | [icksecure]) ]]; then qvm-run --pass-io -u root $PreFix-sys-net "apt install -y qubes-core-agent-networking qubes-core-agent-network-manager firmware-iwlwifi"; fi
if [[ $TemplateVM =~ ([edora] | [oreos]) ]]; then qvm-run --pass-io -u root $PreFix-sys-net "dnf install -y qubes-core-agent-networking qubes-core-agent-network-manager firmware-iwlwifi"; fi
echo "60"
qvm-shutdown $PreFix-sys-net
echo "80"
qvm-create --template $PreFix-sys-net --label red --property template_for_dispvms=True --class AppVM $PreFix-sys-net-dvm
echo "100"
) |
zenity --progress --auto-close --text="Creating new sys-net Template ..." 2>/dev/null
echo "TemplateVM for sys-net created!"

## create sys-firewall templates:
##read -p "Enter Base TemplateVM: " TemplateVM
(
qvm-clone $TemplateVM $PreFix-sys-firewall
echo "20"
qvm-start $PreFix-sys-firewall
echo "40"
if [[ $TemplateVM =~ ([ebian] | [icksecure]) ]]; then qvm-run --pass-io -u root $PreFix-sys-firewall "apt install -y qubes-core-agent-networking qubes-core-agent-dom0-updates"; fi
if [[ $TemplateVM =~ ([edora] | [oreos]) ]]; then qvm-run --pass-io -u root $PreFix-sys-firewall "dnf install -y qubes-core-agent-networking qubes-core-agent-dom0-updates"; fi
echo "60"
qvm-shutdown $PreFix-sys-firewall
echo "80"
qvm-create --template $PreFix-sys-firewall --label red --property template_for_dispvms=True --class AppVM $PreFix-sys-firewall-dvm
echo "100"
) |
zenity --progress --auto-close --text="Creating new sys-firewall Template ..." 2>/dev/null
echo "TemplateVM for sys-firewall created!"

## shutdown & pause
#read -n 1 -s -r -p "Poweroff & remove all dependancies on sys-* qubes & press any key to continue ... "
zenity --warning --ellipsize --text="WARNING:\n\nOld sys-* qubes will be backed up and new one's created ...\n\nPress ctrl+c to cancel now!\n\nOR\n\nPress OK to continue:"

(
qvm-shutdown sys-usb
echo "33"
qvm-shutdown sys-net
echo "66"
qvm-shutdown sys-firewall
echo "100"
) |
zenity --progress --auto-close --text="Shutting down sys-* qubes ... " 2>/dev/null

## sys-<salt> 
(
qvm-clone sys-usb sys-usb_old
echo "14"
qvm-prefs sys-usb_old autostart False
echo "28"
qvm-remove sys-usb
echo "42"
qubes-prefs default_template $PreFix-sys-usb 
echo "56"
qubes-prefs default_dispvm $PreFix-sys-usb-dvm
echo "70"
sudo qubesctl state.sls qvm.sys-usb
echo "84"
qvm-start sys-usb
echo "100"
) |
zenity --progress --auto-close --text="Salting new sys-usb ..." 2>/dev/null

(
qvm-clone sys-net sys-net_old
echo "14"
qvm-prefs sys-net_old autostart False
echo "28"
qvm-remove sys-net
echo "42"
qubes-prefs default_template $PreFix-sys-net
echo "56"
qubes-prefs default_dispvm $PreFix-sys-net-dvm
echo "70"
sudo qubesctl state.sls qvm.sys-net
echo "84"
qvm-start sys-net
echo "100"
) |
zenity --progress --auto-close --text="Salting new sys-net ..." 2>/dev/null

(
qvm-clone sys-firewall sys-firewall_old
echo "14"
qvm-prefs sys-firewall_old autostart False
echo "28"
qvm-remove sys-firewall
echo "42"
qubes-prefs default_template $PreFix-sys-firewall
echo "56"
qubes-prefs default_dispvm $PreFix-sys-firewall-dvm
echo "70"
sudo qubesctl state.sls qvm.sys-firewall
echo "84"
qvm-start sys-firewall
echo "100"
) |
zenity --progress --auto-close --text="Salting new sys-firewall ..." 2>/dev/null

zenity --info --text="Sys-Swap Completed\!\n\nBe sure to reconfigure Qubes to use the new sys-* qubes." 2>/dev/null

