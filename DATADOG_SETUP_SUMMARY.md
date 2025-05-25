# DATADOG AWS INTEGRATION SETUP

## Risorse create

Abbiamo creato con successo le seguenti risorse IAM necessarie per l'integrazione Datadog-AWS:

1. **IAM Role**: `DatadogIntegrationRole`
2. **IAM Policy**: `DatadogIntegrationPolicy` con le autorizzazioni necessarie
3. **External ID**: Generato casualmente per garantire la sicurezza

## Informazioni di configurazione

Utilizza queste informazioni per configurare manualmente l'integrazione nella console Datadog:

| Parametro | Valore |
|-----------|--------|
| AWS Account ID | 006217752970 |
| IAM Role Name | DatadogIntegrationRole |
| External ID | FVvWwgjFfQRckOAnRugR4OPLuRgOU1fD |

## Istruzioni per la configurazione manuale

1. Accedi alla tua console Datadog
2. Vai su **Integrations** > **AWS**
3. Clicca su **Add an AWS Account**
4. Inserisci i valori riportati sopra
5. Clicca su **Install Integration**

## Credenziali Datadog

Le credenziali Datadog sono configurate nel file `tf/terraform.tfvars`:

```
datadog_api_key = "644b1aa9e093ab067228c799e88837cc"
datadog_app_key = "264f2b6f6265892c1b30033848a8d7ec128289a6"
datadog_site    = "datadoghq.com"
```

> **Nota**: Il file terraform.tfvars è già configurato per essere ignorato da git per motivi di sicurezza.

## Dashboard e monitor

Nel progetto sono definiti (ma non applicati) i seguenti dashboard e monitor:

1. **AWS Infrastructure Overview Dashboard**: Un dashboard completo per monitorare le risorse AWS (EC2, Lambda, API Gateway, RDS, S3, SQS)
2. **Monitor EC2 CPU**: Avvisa quando l'utilizzo della CPU supera l'80%
3. **Monitor EC2 Memory**: Avvisa quando l'utilizzo della memoria supera l'80%
4. **Monitor Lambda Errors**: Avvisa quando ci sono troppi errori nelle funzioni Lambda

Per applicare queste risorse, sarà necessario configurare correttamente l'integrazione Datadog-AWS e poi decommentare le risorse nei file Terraform. 