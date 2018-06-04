# SDN-openwrt
Running SDN network using openwrt firmware


Default linksys-EA4500 router internal diagram:
![alt text](./img/linksys-EA4500_def_layout.png "linksys-EA4500 default layout")

Default /etc/config/network file 
```
root@OpenWrt:~# cat /etc/config/network

config interface 'loopback'
        option ifname 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fdb0:616b:c995::/48'

config interface 'lan'
        option type 'bridge'
        option ifname 'eth0'
        option proto 'static'
        option ipaddr '192.168.1.1'
        option netmask '255.255.255.0'
        option ip6assign '60'

config interface 'wan'
        option ifname 'eth1'
        option proto 'dhcp'

config interface 'wan6'
        option ifname 'eth1'
        option proto 'dhcpv6'

config switch
        option name 'switch0'
        option reset '1'
        option enable_vlan '1'

config switch_vlan
        option device 'switch0'
        option vlan '1'
        option ports '0 1 2 3 5'

config switch_vlan
        option device 'switch0'
        option vlan '2'
        option ports '4 6'
```

Default /etc/config/wireless
```
root@OpenWrt:~# cat /etc/config/wireless
config wifi-device  radio0
        option type     mac80211
        option channel  11
        option hwmode   11g
        option path     'mbus/mbus:pcie-controller/pci0000:00/0000:00:01.0/0000:01:00.0'
        option htmode   HT20
        # REMOVE THIS LINE TO ENABLE WIFI:
        option disabled 1

config wifi-iface
        option device   radio0
        option network  lan
        option mode     ap
        option ssid     OpenWrt
        option encryption none

config wifi-device  radio1
        option type     mac80211
        option channel  36
        option hwmode   11a
        option path     'mbus/mbus:pcie-controller/pci0000:00/0000:00:02.0/0000:02:00.0'
        option htmode   HT20
        # REMOVE THIS LINE TO ENABLE WIFI:
        option disabled 1

config wifi-iface
        option device   radio1
        option network  lan
        option mode     ap
        option ssid     OpenWrt
        option encryption none

```
Create OVS and connect lan3,4,5 and WiFi. Keeping lan1 for OF controller (Recommended settings)
![alt text](./img/ovs-keep-br-lan.png "OVS bridge with one port for controller/management")


# steps
SSH into your tplink router ( ssh root@192.168.1.1) 
Make sure WiFi is up. 
Copy this script into ovsbr.sh file and then past it there  (vim ovsbr.sh ), press (i), right click -> past, then press (esc), then (:wq). 
Add run permission chmod +x ovsbr.sh  
Then run the script 
./ovslan.sh  
