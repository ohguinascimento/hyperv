# 🚀 Microsoft Infrastructure Automation (SRE Toolkit)

Este repositório reúne uma coleção de scripts **PowerShell** desenvolvidos para automatizar o provisionamento, a configuração e a gestão de ambientes críticos baseados em tecnologias Microsoft. O foco principal é aplicar princípios de **SRE (Site Reliability Engineering)** para garantir alta disponibilidade e padronização em larga escala.

## 📌 Contexto de Aplicação
Estes scripts foram validados em ambientes de missão crítica com mais de **300 servidores**, onde a automação é essencial para reduzir o *toil* (trabalho manual repetitivo) e mitigar erros de configuração em Clusters de alta disponibilidade.

---

## 🛠️ Scripts Principais

### 1. [Enable-HyperVPlatform.ps1](./Enable-HyperVPlatform.ps1)
Automatiza a preparação de hosts para virtualização.
* **Funcionalidade:** Verifica, instala e habilita a Role do Hyper-V e todas as ferramentas de gerenciamento remoto (RSAT).
* **Diferencial SRE:** O script é **idempotente**; ele valida o estado atual do sistema antes de aplicar mudanças, evitando reinicializações desnecessárias e garantindo que o servidor esteja em conformidade com o baseline.

### 2. [New-HyperVFailoverCluster.ps1](./New-HyperVFailoverCluster.ps1)
Orquestração completa de Clusters de Failover para Hyper-V.
* **Funcionalidade:** Instala a feature de Clustering em múltiplos nós simultaneamente, executa o `Test-Cluster` para validação de saúde e cria o cluster com IP estático.
* **Diferencial SRE:** Implementa a fase de **Validação Crítica**. O script interrompe o provisionamento caso os testes de infraestrutura (Rede, Storage, OS) não passem, garantindo que apenas clusters saudáveis entrem em produção.

---

## 🚀 Como Utilizar

### Pré-requisitos
* PowerShell 5.1 ou superior.
* Privilégios de Administrador de Domínio (para criação de objetos de Cluster no AD).
* WinRM habilitado nos servidores remotos.

### Exemplo de Uso
```powershell
# 1. Habilitar Hyper-V em um novo servidor
.\Enable-HyperVPlatform.ps1

# 2. Criar um Cluster de Alta Disponibilidade com dois nós
.\New-HyperVFailoverCluster.ps1 -ClusterName "CLUSTER-PROD-01" -Nodes "SRV-HVP01","SRV-HVP02" -StaticIP "10.0.0.50"
