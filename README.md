# SDN-openwrt
Running SDN network using openwrt firmware


Default linksys-EA4500 router internal diagram:
![alt text](./img/linksys-EA4500_def_layout.png "linksys-EA4500 default layout")

Create OVS and connect lan3,4,5 and WiFi. Keeping lan1 for OF controller (Recommended settings)
![alt text](./img/ovs-keep-br-lan.png "OVS bridge with one port for controller/management")


## Second step:
SSH into your tplink router ( ssh root@192.168.1.1) 
Make sure WiFi is up. 
Copy this script into ovsbr.sh file and then past it there  (vim ovsbr.sh ), press (i), right click -> past, then press (esc), then (:wq). 
Add run permission chmod +x ovsbr.sh  
Then run the script 
./ovslan.sh  
