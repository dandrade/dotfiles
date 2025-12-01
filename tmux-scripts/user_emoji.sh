id -P $(stat -f%Su /dev/console) | awk -F ':' '{print $8}'
