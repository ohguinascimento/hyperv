<#
.SYNOPSIS
    Habilita a Role do Hyper-V e ferramentas de gerenciamento.
.DESCRIPTION
    Verifica se o Hyper-V está ativo, instala as features necessárias e 
    gerencia o reboot de forma controlada.
#>

$Features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-PowerShell")

foreach ($Feature in $Features) {
    $Check = Get-WindowsFeature -Name $Feature
    if ($Check.Installed -eq $false) {
        Write-Host "Instalando $Feature..." -ForegroundColor Cyan
        Install-WindowsFeature -Name $Feature -IncludeManagementTools
    } else {
        Write-Host "$Feature já está instalado." -ForegroundColor Green
    }
}

# Reinicialização opcional (Descomente se quiser que reinicie automaticamente)
# Restart-Computer -Force
