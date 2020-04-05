#!/bin/sh
dir="/vmfs/volumes/NAS_IP6/"
cd $dir
latter_true="G"
if [ -f /scripts/res.txt ]; then
   rm /scripts/res.txt
fi
dir_name=$(ls -l | grep `date \+\%Y_\%m_\%d`| awk '{print $9}')
for i in $dir_name; do
 vol=$(du -h $i | awk '{print $1}' | cut -f1 -d".")
 latter=$(du -h $i | awk '{print $1}' | tail -c 2)
   if [ $vol -gt 10 ] && [ $latter == $latter_true ]
         then
                 echo "Virtual Machine $i copied succsesfuly" >> /scripts/res.txt
   else
                 echo "BACKUP of $i FAILED" >> /scripts/res.txt
   fi
done
