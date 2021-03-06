#!/bin/sh
#author: Mohammed Alshaboti, vuw, nz.

OVSLAN='ovslan'
LINUXBRIDGE='br-lan'
ctl_ip=192.168.1.100
ctl_port=6633
rep_br_lan='no'

while true; do
    read -p "Do you wish to replace br-lan(y,n)?" yn
    case $yn in
        [Yy]* ) rep_br_lan='yes'; break;;
        [Nn]* ) break 2;;
        * ) echo "Please answer yes or no.";;
    esac
done

if [ '$rep_br_lan' = 'yes' ] 
then
ports=$(seq 2 5)
uci set network.@switch_vlan[0].ports='0'
else
ports=$(seq 3 5)
uci set network.@switch_vlan[0].ports='0 2'
fi

for port in $ports
do
lan=$((port-1))
vlan=$((port+1))

#add new array item
uci add network switch_vlan

#[-1] means the last added index
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vlan=$vlan''
uci set network.@switch_vlan[-1].vid=$vlan''
uci set network.@switch_vlan[-1].ports=$port' 0t'

#create interfce for each vlan
p='lan'$lan
uci set network.$p=interface
uci set network.$p.proto='static'
uci set network.$p.ifname='eth1.'$vlan

done

uci commit network

#enable wifi
uci set wireless.@wifi-device[0].disabled=0; 
#delete it from lan bridge
uci delete wireless.@wifi-iface[0].network; 
#isolate wifi clients
uci set wireless.@wifi-iface[0].isolate='1'
uci commit wireless; wifi

#replace br-lan with ovslan 

if [ '$rep_br_lan' = 'yes' ] 
then
ifconfig $LINUXBRIDGE down
uci delete network.lan.type
uci set network.lan.ifname=$OVSLAN
#delete eth1, wlan0 from br-lan
brctl delif $LINUXBRIDGE eth1
brctl delif $LINUXBRIDGE wlan0
brctl delbr $LINUXBRIDGE
fi

# Create Open vSwitch
ovs-vsctl --may-exist add-br $OVSLAN
# set openflow13
ovs-vsctl set Bridge $OVSLAN protocols=OpenFlow13
#set fail_mod standalone or secure, from my test; it has to be secure to work with wifi
ovs-vsctl set Bridge $OVSLAN fail_mode=secure
#set controller
ovs-vsctl set-controller $OVSLAN tcp:$ctl_ip:$ctl_port

# Add LAN port to Open vSwitch (ovslan)

ovs-vsctl --may-exist add-port $OVSLAN wlan0
for port in $ports
do 
ovs-vsctl --may-exist add-port $OVSLAN eth1.$((port+1))
done 

#to add eth0 (wan)
uci delete network.wan
uci delete network.wan6
uci commit network
ovs-vsctl add-port $OVSLAN eth0

uci commit network
/etc/init.d/network restart
