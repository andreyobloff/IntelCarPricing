# Данные процесса практики 09

## Структура данных

| Поле | Тип | Описание |
|---|---|---|
| record_id | string | Идентификатор записи |
| request_id | string | Связанный запрос на цену |
| product_id | string | Идентификатор продукции |
| price_value | decimal | Согласованная цена |
| margin_value | decimal | Маржинальность |
| risk_level | string | Уровень коммерческого риска |
| decision_status | string | Статус решения |
| decision_date | date | Дата решения |
| target_channel | string | Целевой канал передачи цены |

## Пример данных

| record_id | request_id | product_id | price_value | margin_value | risk_level | decision_status | decision_date | target_channel |
|---|---|---|---:|---:|---|---|---|---|
| REC-001 | REQ-001 | BRAKE-PAD-01 | 4390 | 33.94 | low | accepted | 2026-06-10 | web |
| REC-002 | REQ-002 | OIL-FILTER-02 | 950 | 35.79 | low | accepted | 2026-06-10 | erp |
| REC-003 | REQ-003 | BATTERY-75AH | 12150 | 25.10 | medium | rework | 2026-06-10 | none |
