# IntelCarPricing

**Проект:** Интеллектуальное ценообразование на автомобильную продукцию  
**Дисциплина:** Управление проектами  
**Автор:** Облов Андрей Андреевич, СИИ-23, 3 курс, РАНХиГС ЭМИТ

## Назначение репозитория

Репозиторий используется как Git-ориентированная среда управления учебным проектом.

Основная исследовательская позиция проекта: Git/GitHub рассматривается как самодостаточный интерфейс ведения проектной деятельности, включая документацию, планирование, задачи, статусы, диаграммы, риски, отчёты, историю изменений и воспроизводимые артефакты.

## Ключевые документы

- `docs/assignment-map.md` — карта соответствия практических заданий и Git-артефактов.
- `PROJECT_CHARTER.md` — паспорт проекта.
- `docs/problem-statement/statement.md` — постановка задачи.
- `docs/planning/work-breakdown-structure.md` — иерархическая структура работ.
- `project/github-project/fields.md` — проектные поля GitHub Projects.
- `project/github-project/labels.md` — система labels.
- `project/github-project/milestones.md` — система milestones.

## Принцип работы

Исходные артефакты хранятся в открытых или текстовых форматах: Markdown, CSV, XML, PlantUML, BPMN XML, Draw.io XML.

Бинарные файлы DOCX, XLSX, PPTX, MPP, BPM допускаются как производные или совместимые форматы сдачи.

<!-- VISUAL_DASHBOARD_START -->

## Visual Project Dashboard

Project: **Intelligent pricing for automotive products**

### Management loop

```mermaid
flowchart LR
    A["Assignments"] --> B["GitHub Issues"]
    B --> C["GitHub Project"]
    C --> D["Schedule planning"]
    C --> E["Resource planning"]
    C --> F["Execution control"]
    D --> G["Baseline"]
    E --> H["Resource leveling"]
    F --> I["Actuals and variance"]
    G --> J["Reports"]
    H --> J
    I --> J
    J --> K["Submission packages"]

    classDef source fill:#e8f1ff,stroke:#2f6fab,stroke-width:1px;
    classDef control fill:#fff4cc,stroke:#b58900,stroke-width:1px;
    classDef output fill:#e6f4ea,stroke:#2e7d32,stroke-width:1px;

    class A,B source;
    class C,D,E,F,G,H,I control;
    class J,K output;
```

### Practice roadmap

```mermaid
flowchart TD
    P01["Practice 01: problem statement, WBS, calendar"]
    P021["Practice 02.1: dependencies, critical path, resources"]
    P022["Practice 02.2: baseline, actuals, variance"]
    P03["Practice 03: IDEF0 model"]
    P04["Practice 04: IDEF decomposition"]
    P05["Practice 05: UML Use Case and Sequence"]
    P06["Practice 06: UML Class and Activity"]
    P08["Practice 08: BPMN process 1"]
    P09["Practice 09: BPMN process 2"]
    P10["Practice 10: BPMN documentation"]
    P11["Practice 11: AS IS / TO BE"]
    P12["Practice 12: Risk management"]

    P01 --> P021 --> P022 --> P03 --> P04 --> P05 --> P06 --> P08 --> P09 --> P10 --> P11 --> P12

    classDef done fill:#e6f4ea,stroke:#2e7d32,stroke-width:1px;
    classDef planned fill:#f5f5f5,stroke:#757575,stroke-width:1px;

    class P01,P021,P022,P03 done;
    class P04,P05,P06,P08,P09,P10,P11,P12 planned;
```

### Repository structure

```mermaid
flowchart TD
    R["IntelCarPricing"]
    R --> D["docs"]
    R --> P["project"]
    R --> M["models"]
    R --> S["scripts"]
    R --> Rel["releases"]

    D --> Problem["problem-statement"]
    D --> Planning["planning"]
    D --> Reports["reports"]
    D --> Visuals["visuals"]

    P --> MSProject["msproject"]
    P --> GitHubProject["github-project"]

    M --> IDEF["idef"]
    M --> UML["uml"]
    M --> BPMN["bpmn"]
    M --> Visual["visual"]

    Rel --> Sub0102["submission-practice-01-02"]
    Rel --> Sub03["submission-practice-03"]
```

### IDEF0 context

```mermaid
flowchart LR
    I["Inputs: sales, catalog, stock, market, cost"] --> A["A-0: Manage intelligent pricing"]
    C["Controls: policy, margin, strategy, approval rules"] --> A
    M["Mechanisms: team, GitHub, data, infrastructure"] --> A
    A --> O["Outputs: prices, reports, rationale, calculation log"]
```

Detailed dashboard: [`docs/visuals/project-dashboard.md`](docs/visuals/project-dashboard.md)

<!-- VISUAL_DASHBOARD_END -->
