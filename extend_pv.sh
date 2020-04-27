#/bin/bash
echo "Вибирите диск, который нужно расширить"
fdisk -l | grep -E "\/dev\/sd[a-z]{1,2}:" | awk '{print $2,$3,$4 }' | cat -n
read num
initial_value=$(fdisk -l | grep -E "\/dev\/sd[a-z]{1,2}:" | awk '{print $2,$3,$4 }' | head -n $num | tail -n 1)
disk_name=$(fdisk -l | grep -E "\/dev\/sd[a-z]{1,2}:" | awk '{print $2}' | tr -d '\:' | cut -c 6- | head -n $num | tail -n 1)

  symb1=$(lsscsi -v | grep $disk_name | awk '{print $1}' | cut -c 2-2)
  symb2=$(lsscsi -v | grep $disk_name | awk '{print $1}' | cut -c 4-4)
  symb3=$(lsscsi -v | grep $disk_name | awk '{print $1}' | cut -c 6-6)
  symb4=$(lsscsi -v | grep $disk_name | awk '{print $1}' | cut -c 8-8)

echo 1 > /sys/bus/scsi/devices/$symb1\:$symb2\:$symb3\:$symb4/rescan

pvresize /dev/$disk_name 2>/dev/null
finite_value=$(fdisk -l | grep -E "\/dev\/sd[a-z]{1,2}:" | awk '{print $2,$3,$4 }' | head -n $num | tail -n 1)

echo "Начальный размер диска:  $initial_value"
echo "Размер после увеличения: $finite_value"
