#!/bin/bash

echo -e "Clean UP of Already existing network namespaces "
for i in zero one two three four five six seven eight
do
	ip netns del $i
done

declare -a list_of_ns=("zero" "one" "two" "three" "four" "five" "six" "seven" "eight")
declare -a list_of_network=(" " "192.168.100." "192.168.101." "192.168.102." "192.168.104.")

echo -e "Enter number of pairs of namespaces you want: 
For eg: 2 port card can have 1 pair of namespaces containing 2 netns.
	4 port card can have 2 pair of namespaces containing 4 netns."
read pair_of_namespaces

j=1

No_of_namespaces=`expr 2 \* $pair_of_namespaces`


for ((i=1; i<= $No_of_namespaces ;i++ ))
 do
  echo -e "Enter the interface of $i namespace "
  read interface
  echo  "Creating namespaces $i"
  ip netns add ${list_of_ns[$i]}
  echo -e "Adding respective interface to the namespace"
  ip link set dev $interface netns ${list_of_ns[$i]}
  echo -e "Assigning IP's to the netns"
   if [ `expr $i % 2` == 0 ]
   then
	ip netns exec ${list_of_ns[$i]}  ifconfig $interface ${list_of_network[$j]}20/24 up
	j=`expr $j + 1`

	echo -e " Do you want to Test connectivity for this pair using ping?
          Enter 'y' for yes and 'n' for no"

	read ping
		if [ $ping == 'y' ]
		then
        		if [ `expr $i % 2` == 0 ]
		        then
                		echo "ip netns exec ${list_of_ns[$i]}  ping -c 5  ${list_of_network[$j]}10"
        		else
                		echo "ip netns exec ${list_of_ns[$i]}  ping -c 5 ${list_of_network[$j]}20"
        		fi
		else
        		break
		fi

	echo -e " Do you want to Test iperf Traffic?
          Enter 'y' for yes and 'n' for no"

        read iperf
                if [ $iperf == 'y' ]
                then
                        if [ `expr $i % 2` == 0 ]
                        then
                                echo "ip netns exec ${list_of_ns[$i]}  iperf -c  ${list_of_network[$j]}10 -i 2 -T 100"
                        else
                                echo "ip netns exec ${list_of_ns[$i]}  iperf -c  ${list_of_network[$j]}20 -i 2 -T 100"
                        fi
                else
                        break
                fi


   else
	ip netns exec ${list_of_ns[$i]}  ifconfig $interface ${list_of_network[$j]}10/24 up
   

: 'echo -e " Do you want to Test connectivity for this pair using ping?
	  Enter 'y' for yes and 'n' for no"

read ping
if [$ping == 'y' ]
then
	if [ `expr $i % 2` == 0 ]
   	then
		ip netns exec ${list_of_ns[$i]}  ping ${list_of_network[$j]}10
	else
		ip netns exec ${list_of_ns[$i]}  ping ${list_of_network[$j]}20
	fi
else
	break
fi '
   fi


 done
