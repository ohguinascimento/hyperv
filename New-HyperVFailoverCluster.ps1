<#
.SYNOPSIS
    Criação de Cluster de Failover para Hyper-V com validação de DNS/AD.
.DESCRIPTION
    Este script realiza checagens de pré-requisitos de rede e DNS antes de 
    proceder com a instalação das roles e criação do Cluster.
#>

Param(
    [Parameter(Mandatory=$true)] [string]$ClusterName,
    [Parameter(Mandatory=$true)] [string[]]$Nodes,
    [Parameter(Mandatory=$true)] [string]$StaticIP
)

Function Test-ClusterDnsPrerequisites {
    param([string]$CName, [string[]]$NodeList)
    
    Write-Host "--- Iniciando Validação de Pré-requisitos de DNS ---" -ForegroundColor Cyan
    $Pass = $true

    # 1. Verificar se o nome do Cluster já existe no DNS (Evitar Conflitos)
    try {
        $DnsCheck = Resolve-DnsName -Name $CName -ErrorAction SilentlyContinue
        if ($DnsCheck) {
            Write-Host "[ERRO] O nome '$CName' já está em uso no DNS. Escolha outro nome." -ForegroundColor Red
            $Pass = $false
        } else {
            Write-Host "[OK] Nome do Cluster '$CName' está disponível." -ForegroundColor Green
        }
    } catch { }

    # 2. Verificar se os Nós são resolvíveis e estão online
    foreach ($Node in $NodeList) {
        if (Test-Connection -ComputerName $Node -Count 1 -Quiet) {
            Write-Host "[OK] Nó $Node está online e acessível." -ForegroundColor Green
        } else {
            Write-Host "[ERRO] Não foi possível contatar o nó $Node. Verifique o DNS e a rede." -ForegroundColor Red
            $Pass = $false
        }
    }

    return $Pass
}

# --- Execução Principal ---

# Passo 1: Validação de DNS e Rede
if (-not (Test-ClusterDnsPrerequisites -CName $ClusterName -NodeList $Nodes)) {
    Write-Error "A validação de pré-requisitos falhou. O script foi interrompido."
    exit
}

# Passo 2: Instalação da Feature remotamente
Write-Host "`nInstalando Failover-Clustering nos nós..." -ForegroundColor Cyan
Invoke-Command -ComputerName $Nodes -ScriptBlock {
    Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools
}

# Passo 3: Validação oficial da Microsoft (Test-Cluster)
Write-Host "Executando Test-Cluster (Validação oficial)..." -ForegroundColor Yellow
$Validation = Test-Cluster -Node $Nodes -NoStorage 
if ($Validation) {
    # Passo 4: Criação do Cluster
    Write-Host "Criando o Cluster $ClusterName com IP $StaticIP..." -ForegroundColor Green
    New-Cluster -Name $ClusterName -Node $Nodes -StaticAddress $StaticIP
} else {
    Write-Error "O Test-Cluster reportou falhas. Verifique o relatório em C:\Windows\Cluster\Reports"
}
