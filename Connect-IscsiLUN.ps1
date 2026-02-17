Write-Host "--- 🏁 Conectando ao Storage Linux via iSCSI ---" -ForegroundColor Cyan

$TargetPortal = "10.0.0.100" # IP do seu Linux Storage

# 1. Iniciar e configurar o serviço iSCSI
Start-Service msiscsi
Set-Service msiscsi -StartupType Automatic

# 2. Adicionar o Portal de Target
New-IscsiTargetPortal -TargetPortalAddress $TargetPortal

# 3. Conectar à LUN (IQN do Linux)
$TargetIQN = "iqn.2026-02.lab.local:storage.target01"
Connect-IscsiTarget -NodeAddress $TargetIQN -IsPersistent $true

# 4. Inicializar o disco para o Cluster (Apenas no primeiro nó)
Get-Disk | Where-Object BusType -Eq "iSCSI" | 
    Initialize-Disk -PartitionStyle GPT -PassThru | 
    New-Partition -UseMaximumSize -AssignDriveLetter | 
    Format-Volume -FileSystem NTFS -NewFileSystemLabel "CSV_Storage" -Confirm:$false
