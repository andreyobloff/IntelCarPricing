# Визуальная панель проекта

## Проект

**Интеллектуальное ценообразование на автомобильную продукцию**

## Управленческий контур

```mermaid
flowchart LR
    A["Практические задания"] --> B["GitHub Issues"]
    B --> C["GitHub Project"]
    C --> D["Планирование сроков"]
    C --> E["Планирование ресурсов"]
    C --> F["Контроль исполнения"]
    D --> G["Базовый план"]
    E --> H["Выравнивание ресурсов"]
    F --> I["Фактическое выполнение и отклонения"]
    G --> J["Отчёты"]
    H --> J
    I --> J
    J --> K["ZIP-пакеты для сдачи"]

    classDef source fill:#e8f1ff,stroke:#2f6fab,stroke-width:1px;
    classDef control fill:#fff4cc,stroke:#b58900,stroke-width:1px;
    classDef output fill:#e6f4ea,stroke:#2e7d32,stroke-width:1px;
    classDef risk fill:#fdecea,stroke:#c62828,stroke-width:1px;

    class A,B source;
    class C,D,E,F,G,H,I control;
    class J,K output;
```

## Дорожная карта практических работ

```mermaid
flowchart TD
    P01["Практика 01: постановка задачи, WBS, календарь, ресурсы"]
    P021["Практика 02.1: связи, критический путь, ресурсное выравнивание"]
    P022["Практика 02.2: базовый план, фактическое выполнение, отклонения"]
    P03["Практика 03: функциональная модель IDEF0"]
    P04["Практика 04: декомпозиционные IDEF0/IDEF3 диаграммы"]
    P05["Практика 05: UML Use Case и Sequence"]
    P06["Практика 06: UML Class и Activity"]
    P08["Практика 08: BPMN-процесс 1"]
    P09["Практика 09: BPMN-процесс 2"]
    P10["Практика 10: документирование BPMN"]
    P11["Практика 11: сценарии КАК ЕСТЬ / КАК ДОЛЖНО БЫТЬ"]
    P12["Практика 12: управление рисками"]

    P01 --> P021 --> P022 --> P03 --> P04 --> P05 --> P06 --> P08 --> P09 --> P10 --> P11 --> P12

    classDef done fill:#e6f4ea,stroke:#2e7d32,stroke-width:1px;
    classDef planned fill:#f5f5f5,stroke:#757575,stroke-width:1px;
    class P01,P021,P022,P03 done;
    class P04,P05,P06,P08,P09,P10,P11,P12 planned;
```

## Структура артефактов

```mermaid
flowchart TD
    R["Репозиторий IntelCarPricing"]
    R --> D["Документы"]
    R --> P["Проектное планирование"]
    R --> M["Модели"]
    R --> S["Скрипты"]
    R --> Rel["Пакеты сдачи"]

    D --> PS["Постановка задачи"]
    D --> PL["Планирование"]
    D --> Rep["Отчёты"]
    D --> Vis["Визуальный слой"]

    P --> MSP["MS Project / CSV / XML"]
    P --> GHP["GitHub Project"]

    M --> IDEF["IDEF-модели"]
    M --> UML["UML-модели"]
    M --> BPMN["BPMN-модели"]
    M --> Visual["Визуальные схемы"]

    Rel --> Sub01["Практики 01-02"]
    Rel --> Sub03["Практика 03"]
    Rel --> Sub04["Практика 04"]
    Rel --> Sub05["Практика 05"]
    Rel --> Sub06["Практика 06"]

    classDef repo fill:#eeeeee,stroke:#555555,stroke-width:1px;
    classDef docs fill:#e8f1ff,stroke:#2f6fab,stroke-width:1px;
    classDef models fill:#e6f4ea,stroke:#2e7d32,stroke-width:1px;
    classDef release fill:#fff4cc,stroke:#b58900,stroke-width:1px;

    class R repo;
    class D,P,S,Vis docs;
    class M,IDEF,UML,BPMN,Visual models;
    class Rel,Sub01,Sub03,Sub04,Sub05,Sub06 release;
```

## IDEF0-контекст проекта

```mermaid
flowchart LR
    I["Входы: продажи, каталог, остатки, рынок, себестоимость"] --> A["A-0: Управлять интеллектуальным ценообразованием"]
    C["Управление: ценовая политика, маржинальность, стратегия, регламент согласования"] --> A
    M["Механизмы: проектная команда, GitHub, данные, инфраструктура"] --> A
    A --> O["Выходы: рекомендованные цены, отчёты, обоснование, журнал расчётов"]

    classDef input fill:#e8f1ff,stroke:#2f6fab,stroke-width:1px;
    classDef control fill:#fff4cc,stroke:#b58900,stroke-width:1px;
    classDef mechanism fill:#eeeeee,stroke:#555555,stroke-width:1px;
    classDef output fill:#e6f4ea,stroke:#2e7d32,stroke-width:1px;
    classDef function fill:#ffffff,stroke:#111111,stroke-width:2px;

    class I input;
    class C control;
    class M mechanism;
    class O output;
    class A function;
```

## Контроль базового плана и фактического выполнения

```mermaid
flowchart LR
    Plan["Плановые задачи"] --> Base["Базовый план"]
    Base --> Actual["Фактическое выполнение"]
    Actual --> Var["Отклонения"]
    Var --> EV["Освоенный объём"]
    EV --> Reports["Отчёты"]
    Reports --> Decision["Управленческие решения"]

    Var --> Check1{"Отклонения допустимы?"}
    Check1 -- "Да" --> Decision
    Check1 -- "Нет" --> Risk["Корректирующее действие"]

    classDef plan fill:#e8f1ff,stroke:#2f6fab,stroke-width:1px;
    classDef control fill:#fff4cc,stroke:#b58900,stroke-width:1px;
    classDef output fill:#e6f4ea,stroke:#2e7d32,stroke-width:1px;
    classDef risk fill:#fdecea,stroke:#c62828,stroke-width:1px;

    class Plan,Base plan;
    class Actual,Var,EV,Check1 control;
    class Reports,Decision output;
    class Risk risk;
```

## Состояние готовности

| Блок | Статус |
|---|---|
| Практика 01 | Готово |
| Практика 02, часть 1 | Готово |
| Практика 02, часть 2 | Готово |
| Практика 03 | Готово |
| Визуальная панель в README | Переведена на русский |
| Визуальная панель проекта | Переведена на русский |
