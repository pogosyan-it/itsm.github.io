#!/usr/bin/pwsh -Command
##########################
# PowerCLI to create VMs #
# Version 1.0            #
##########################

Connect-VIServer -Server vcenter.rgs.ru -Protocol https -User 'domain\login' -Password 'Password'

$VMNAME = @{"VM_1" = "VM_Name_1"; "VM_2" = "VM_Name_2"; "VM_3" = "VM_Name_3"}

$SourceVM = @{"SourceVM_1" = "Source_VM_1"; "SourceVM_2" = "SourceVM_2"; "SourceVM_3" = "Source_VM_3"}

$VMHOST = "Host_Name"
$DataStore="DataStore"

for ($i = 1; $i -le $VMNAME.Count; $i++)

  {
       $VM = New-VM -Name $VMNAME["VM_$i"] -VM $SourceVM["SourceVM_$i"] -VMHost $VMHOST -Datastore $DataStore
       New-TagAssignment -Tag "PCG" -Entity $VMNAME["VM_$i"]  #Project_Name
       New-TagAssignment -Tag "Owner" -Entity $VMNAME["VM_$i"] #Owner_Name
       New-TagAssignment -Tag "Test" -Entity $VMNAME["VM_$i"]   #Environment
       New-TagAssignment -Tag "FastDisk" -Entity $VMNAME["VM_$i"] #disktype
       New-TagAssignment -Tag "non-backup" -Entity $VMNAME["VM_$i"] #backup 
       New-TagAssignment -Tag "none" -Entity $VMNAME["VM_$i"]        #FT
       New-TagAssignment -Tag "Постоянно" -Entity $VMNAME["VM_$i"] #Time of live
       Set-VM -VM $VMNAME["VM_$i"] -Notes "Владелец: Строганов Даниил `nДата создания: 06.11.2019 `nJIRA: PCG-20359" -Confirm:$False # Any notes
   }

