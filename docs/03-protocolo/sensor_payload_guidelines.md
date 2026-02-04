* * *

# Guidelines de Payload para Sensores (V2.4)

**Status:** Referência técnica (NÃO normativa)  
**Escopo:** Firmware + App + Testes  
**Objetivo:** Fornecer schemas orientativos por `kind` para reduzir ambiguidade entre devs, facilitar UI/UX, orientar validações leves e preservar forward-compatibility.

* * *

## 1. Princípio Geral

- **Schemas não são obrigatórios:** São apenas recomendações para padronização.
- **Campo obrigatório:** O único campo obrigatório por contrato é `ts` (Unix Epoch em segundos).
- **Flexibilidade:** Campos extras podem existir sem aviso prévio.
- **Robustez:** O App e o backend DEVEM ignorar campos desconhecidos (soberania do receptor).

* * *

## 2. Envelope Mínimo (Comum a todos)

```json
{ 
  "ts": 1710000000 
}
```

* * *

## 3. Schemas Orientativos por `kind`

### 3.1 Nível de Água (`water.level.*`)

```json
{
  "liters": 1200,
  "percent": 55,
  "distance_cm": 48,
  "alert": "NORMAL",
  "ts": 1710000000
}
```

### 3.2 Clima/Ambiente (`env.climate.*`)

```json
{
  "temp_c": 26.4,
  "humidity": 58,
  "alert": "NORMAL",
  "ts": 1710000000
}
```

### 3.3 Qualidade do Ar (`env.air.*`)

```json
{
  "gas_ppm": 320,
  "voc_index": 120,
  "alert": "WARN",
  "ts": 1710000000
}
```

### 3.4 Presença (`security.presence.*`)

```json
{
  "presence": true,
  "confidence": 0.82,
  "ts": 1710000000
}
```

* * *

## 4. Campos Recomendados (Cross-cutting)

| Campo | Uso |
| :--- | :--- |
| `value` | Sensores simples (unidimensional) |
| `unit` | Suporte para UI/UX (unidades de medida) |
| `alert` | `NORMAL` | `WARN` | `CRITICAL` |
| `quality` | Metadados sobre a confiabilidade da leitura |
| `raw` | Dados brutos para debug ou calibração |

* * *

## 5. O que é PROIBIDO (Mesmo como guideline)

- **Comandos em sensores:** Publicar `command` em um tópico de sensor.
- **Mistura de responsabilidades:** Misturar controle (actuation) e telemetria no mesmo recurso.
- **Schemas fixos:** Assumir que o schema é imutável no lado do App.
- **Validação no Broker:** Tentar validar schemas JSON diretamente no broker MQTT.

* * *
