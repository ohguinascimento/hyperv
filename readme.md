# 🚀 Windows Server & Hyper-V Automation Suite (SRE focused)

Este repositório contém um conjunto de ferramentas em **PowerShell** desenvolvidas para automatizar a infraestrutura de missão crítica. O objetivo é transformar tarefas complexas de gerenciamento de servidores em processos previsíveis, seguros e documentados, seguindo os princípios de **Site Reliability Engineering (SRE)**.

## 📌 Contexto e Valor de Negócio
Em um parque com mais de **300 servidores**, a configuração manual é o caminho mais curto para a indisponibilidade. Estes scripts foram projetados para garantir:
* **Padronização:** Configurações idênticas em todos os nós do cluster.
* **Previsibilidade:** Validações de DNS e rede antes de qualquer alteração estrutural.
* **Resiliência:** Redução drástica de falhas humanas no provisionamento de Alta Disponibilidade (HA).

---

## 🛠️ Ferramentas do Toolkit

### 1. [Enable-HyperVPlatform.ps1](./Enable-HyperVPlatform.ps1)
Prepara o sistema operacional para atuar como Hypervisor.
* **Recursos:** Instalação da Role Hyper-V, ferramentas RSAT e módulos de PowerShell.
* **Diferencial:** Possui lógica de verificação de estado (idempotência), evitando reinstalações ou reboots desnecessários.

### 2. [New-HyperVFailoverCluster.ps1](./New-HyperVFailoverCluster.ps1)
Orquestrador para criação de clusters de failover com inteligência de pré-requisitos.
* **Pre-flight Checks:** O script valida se o **nome do Cluster está disponível no DNS** e se os nós estão online antes de iniciar a instalação.
* **Integração AD/DNS:** Gerencia a criação do Cluster Name Object (CNO) e assegura que os registros de rede sejam criados corretamente.
* **Segurança:** Interrompe a execução caso a validação oficial da Microsoft (`Test-Cluster`) encontre inconsistências de hardware ou rede.

---

## 🚀 Como Executar

### Pré-requisitos
* PowerShell 5.1 ou superior.
* Conectividade com Active Directory e DNS.
* Permissões de Admin no domínio para registro de objetos de cluster.

### Exemplo de Uso
```powershell
# 1. Configurar o Host
.\Enable-HyperVPlatform.ps1

# 2. Deploy de Cluster com validação automática de DNS
.\New-HyperVFailoverCluster.ps1 `
    -ClusterName "CLSTR-PROD-01" `
    -Nodes "SRV-HVP01", "SRV-HVP02" `
    -StaticIP "192.168.10.50"
