#!/bin/sh

z=`cat /scripts/WM_Name.txt | wc -l`
for i in `seq 1 $z`;  do
#echo $z
name=`cat /scripts/WM_Name.txt | head -n $i | tail -n 1`        #  WM_Name.txt -   файл содержащий   имена виртуальных машины (см. start_up.sh)
#echo $name
id=`vim-cmd vmsvc/getallvms | grep $name | awk '{print $1}'`     # vim-cmd vmsvc/getallvms - вывод списка виртуальных машин со всей лабудой

dir="/vmfs/volumes/Backup/$name"
curdate="`date \+\%Y_\%m_\%d`"  
LOGFILE=/tmp/$curdate.txt                                  
dest="/vmfs/volumes/NFS_backup/"                                            # Смонтированная на хосте ESXi директория NFS   
vim-cmd vmsvc/snapshot.create $id Snapshot_$name                                   # Команда создания снапшота.
sleep 5s
task=`vim-cmd vmsvc/get.tasklist $id`                                                      # Вывод списка процессов
pattern="(ManagedObjectReference) []"                                                      #Вывод команды когда все действия с ВМ завершены.

log()                                                                                     # Функция Логирования
       {
           echo $(date)" "$1 >> $LOGFILE
       }

Movefiles(){                                                                              # Функция  копирования файлов ВМ на NFS                                   

           mkdir $dest/"$name"_"$curdate"
           find $dir -name "*.vmdk" -exec cp '{}' $dest/"$name"_"$curdate" \;  2>>$LOGFILE     # Копирование всех файлов  с расширением vmdk (образы дисков) на бэкапный диск 
           find $dir \( -name "*vmx" -or -name "*vmx~*" \) -type f -exec cp '{}' $dest/"$name"_"$curdate" \; 2>>$LOGFILE  # *vmx и vmx~  - файлы конфигураций ВМ
           log "Files Copy is complet"
           vim-cmd vmsvc/snapshot.removeall $id                                              #Удаление всех снапшотов
          }
WaitForcomplete()                                                                         # Функция ожидания окончания выполнения снапшота.
  {
      log " Not done yet, waiting 2m"
      sleep 2m
      Chekstate

   }
Chekstate()                                                                              # Функция проверки выполнения снапшота если выполнен то переход на Movefiles
   {                                                                                     # Если нет то ожидаем 2 минуты (идем в WaitForcomplete )
      task=`vim-cmd vmsvc/get.tasklist $id`                                              # Вывод списка процессов
                                                                                              
      if [ "$task" == "$pattern" ]; then                                                 # Проверка окончания процесса создания снапшота

          res="TRUE"
          echo $res
          Movefiles
          log "Task completed!"
      else

           res="FALSE"
           echo $res
           WaitForcomplete
      fi
  }

       Chekstate
done