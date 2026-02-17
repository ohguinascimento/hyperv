<#
.SYNOPSIS
    Criação de Cluster de Failover para Hyper-V.
.PARAMETER ClusterName
    O nome DNS que o Cluster terá.
.PARAMETER Nodes
    Array com o nome dos servidores que farão parte do Cluster.
.PARAMETER StaticIP
    Endereço IP para o ponto de acesso do Cluster.
#>

Param(
    [Parameter(Mandatory=$true)] [string]$ClusterName,
    [Parameter(Mandatory=$true)] [string[]]$Nodes,
    [Parameter(Mandatory=$true)] [string]$StaticIP
)

# 1. Instalação da Feature em todos os nós remotamente
Write-Host "Instalando Failover-Clustering nos nós: $Nodes" -ForegroundColor Cyan
Invoke-Command -ComputerName $Nodes -ScriptBlock {
    Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools
}

# 2. Validação do Cluster (Passo crítico para SRE)
Write-Host "Iniciando teste de validação do Cluster..." -ForegroundColor Yellow
$Validation = Test-Cluster -Node $Nodes -NoStorage # -NoStorage se for usar Storage externo depois
if ($Validation) {
    # 3. Criação do Cluster
    Write-Host "Validação concluída. Criando o Cluster $ClusterName..." -ForegroundColor Green
    New-Cluster -Name $ClusterName -Node $Nodes -StaticAddress $StaticIP
} else {
    Write-Error "A validação do Cluster falhou. Verifique os logs antes de prosseguir."
}
