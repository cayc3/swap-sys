#!/bin/bash
## config
read -p "Enter Base TemplateVM: " TemplateVM
read -p "Enter prefix: " PreFix

## create sys-usb templates:
#read -p "Enter Base TemplateVM: " TemplateVM

qvm-clone $TemplateVM $PreFix-sys-usb
qvm-start $PreFix-sys-usb
if [[ $TemplateVM =~ ([ebian] | [icksecure]) ]]; then qvm-run --pass-io -u root $PreFix-sys-usb "apt install -y qubes-usb-proxy"; fi
if [[ $TemplateVM =~ ([edora] | [oreos]) ]]; then qvm-run --pass-io -u root $PreFix-sys-usb "dnf install -y qubes-usb-proxy"; fi
qvm-shutdown $PreFix-sys-usb
qvm-create --template $PreFix-sys-usb --label red --property template_for_dispvms=True --class AppVM $PreFix-sys-usb-dvm

## create sys-net templates:
#read -p "Enter Base TemplateVM: " TemplateVM

qvm-clone $TemplateVM $PreFix-sys-net
qvm-start $PreFix-sys-net
if [[ $TemplateVM =~ ([ebian] | [icksecure]) ]]; then qvm-run --pass-io -u root $PreFix-sys-net "apt install -y qubes-core-agent-networking qubes-core-agent-network-manager firmware-iwlwifi"; fi
if [[ $TemplateVM =~ ([edora] | [oreos]) ]]; then qvm-run --pass-io -u root $PreFix-sys-net "dnf install -y qubes-core-agent-networking qubes-core-agent-network-manager firmware-iwlwifi"; fi
qvm-shutdown $PreFix-sys-net
qvm-create --template $PreFix-sys-net --label red --property template_for_dispvms=True --class AppVM $PreFix-sys-net-dvm

## create sys-firewall templates:
#read -p "Enter Base TemplateVM: " TemplateVM

qvm-clone $TemplateVM $PreFix-sys-firewall
qvm-start $PreFix-sys-firewall
if [[ $TemplateVM =~ ([ebian] | [icksecure]) ]]; then qvm-run --pass-io -u root $PreFix-sys-firewall "apt install -y qubes-core-agent-networking qubes-core-agent-dom0-updates"; fi
if [[ $TemplateVM =~ ([edora] | [oreos]) ]]; then qvm-run --pass-io -u root $PreFix-sys-firewall "dnf install -y qubes-core-agent-networking qubes-core-agent-dom0-updates"; fi
qvm-shutdown $PreFix-sys-firewall
qvm-create --template $PreFix-sys-firewall --label red --property template_for_dispvms=True --class AppVM $PreFix-sys-firewall-dvm

## shutdown & pause
read -n 1 -s -r -p "Poweroff & remove all dependancies on sys-* qubes & press any key to continue ... "


qvm-shutdown sys-usb
qvm-shutdown sys-net
qvm-shutdown sys-firewall

## sys-<salt> 

qvm-clone sys-usb sys-usb_old
qvm-prefs sys-usb_old autostart False
qvm-remove sys-usb
qubes-prefs default_template $PreFix-sys-usb 
qubes-prefs default_dispvm $PreFix-sys-usb-dvm
sudo qubesctl state.sls qvm.sys-usb
qvm-start sys-usb


qvm-clone sys-net sys-net_old
qvm-prefs sys-net_old autostart False
qvm-remove sys-net
qubes-prefs default_template $PreFix-sys-net
qubes-prefs default_dispvm $PreFix-sys-net-dvm
sudo qubesctl state.sls qvm.sys-net
qvm-start sys-net


qvm-clone sys-firewall sys-firewall_old
qvm-prefs sys-firewall_old autostart False
qvm-remove sys-firewall
qubes-prefs default_template $PreFix-sys-firewall
qubes-prefs default_dispvm $PreFix-sys-firewall-dvm
sudo qubesctl state.sls qvm.sys-firewall
qvm-start sys-firewall


