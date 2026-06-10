# Project Dashboard

## Project

**Intelligent pricing for automotive products**

## Management scheme

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
    J --> K["Submission ZIP"]

    classDef source fill:#e8f1ff,stroke:#2f6fab,stroke-width:1px;
    classDef control fill:#fff4cc,stroke:#b58900,stroke-width:1px;
    classDef output fill:#e6f4ea,stroke:#2e7d32,stroke-width:1px;
    classDef risk fill:#fdecea,stroke:#c62828,stroke-width:1px;

    class A,B source;
    class C,D,E,F,G,H,I control;
    class J,K output;
```

## Practice roadmap

```mermaid
flowchart TD
    P01["Practice 01: problem statement, WBS, calendar, resources"]
    P021["Practice 02.1: dependencies, critical path, resource leveling"]
    P022["Practice 02.2: baseline, actuals, variance, reports"]
    P03["Practice 03: IDEF0 functional model"]
    P04["Practice 04: IDEF decomposition"]
    P05["Practice 05: UML Use Case and Sequence"]
    P06["Practice 06: UML Class and Activity"]
    P08["Practice 08: BPMN process 1"]
    P09["Practice 09: BPMN process 2"]
    P10["Practice 10: BPMN documentation"]
    P11["Practice 11: AS IS / TO BE simulation"]
    P12["Practice 12: risk management"]

    P01 --> P021 --> P022 --> P03 --> P04 --> P05 --> P06 --> P08 --> P09 --> P10 --> P11 --> P12

    classDef done fill:#e6f4ea,stroke:#2e7d32,stroke-width:1px;
    classDef planned fill:#f5f5f5,stroke:#757575,stroke-width:1px;
    class P01,P021,P022,P03 done;
    class P04,P05,P06,P08,P09,P10,P11,P12 planned;
```

## Artifact structure

```mermaid
flowchart TD
    R["IntelCarPricing Repository"]
    R --> D["docs"]
    R --> P["project"]
    R --> M["models"]
    R --> S["scripts"]
    R --> Rel["releases"]

    D --> PS["problem-statement"]
    D --> PL["planning"]
    D --> Rep["reports"]
    D --> Vis["visuals"]

    P --> MSP["msproject"]
    P --> GHP["github-project"]

    M --> IDEF["idef"]
    M --> UML["uml"]
    M --> BPMN["bpmn"]
    M --> Visual["visual"]

    Rel --> Sub01["submission-practice-01-02"]
    Rel --> Sub03["submission-practice-03"]

    classDef repo fill:#eeeeee,stroke:#555555,stroke-width:1px;
    classDef docs fill:#e8f1ff,stroke:#2f6fab,stroke-width:1px;
    classDef models fill:#e6f4ea,stroke:#2e7d32,stroke-width:1px;
    classDef release fill:#fff4cc,stroke:#b58900,stroke-width:1px;

    class R repo;
    class D,P,S,Vis docs;
    class M,IDEF,UML,BPMN,Visual models;
    class Rel,Sub01,Sub03 release;
```

## IDEF0 project context

```mermaid
flowchart LR
    I["Inputs: sales, catalog, stock, market, cost"] --> A["A-0: Manage intelligent pricing"]
    C["Controls: pricing policy, margin, strategy, approval rules"] --> A
    M["Mechanisms: project team, GitHub, data, infrastructure"] --> A
    A --> O["Outputs: recommended prices, reports, rationale, calculation log"]

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

## Baseline and actuals control

```mermaid
flowchart LR
    Plan["Planned tasks"] --> Base["Baseline"]
    Base --> Actual["Actuals"]
    Actual --> Var["Variance"]
    Var --> EV["Earned Value"]
    EV --> Reports["Reports"]
    Reports --> Decision["Management decisions"]

    Var --> Check1{"Variance acceptable?"}
    Check1 -- Yes --> Decision
    Check1 -- No --> Risk["Corrective action"]

    classDef plan fill:#e8f1ff,stroke:#2f6fab,stroke-width:1px;
    classDef control fill:#fff4cc,stroke:#b58900,stroke-width:1px;
    classDef output fill:#e6f4ea,stroke:#2e7d32,stroke-width:1px;
    classDef risk fill:#fdecea,stroke:#c62828,stroke-width:1px;

    class Plan,Base plan;
    class Actual,Var,EV,Check1 control;
    class Reports,Decision output;
    class Risk risk;
```

## Completion state

| Block | Status |
|---|---|
| Practice 01 | Done |
| Practice 02 part 1 | Done |
| Practice 02 part 2 | Done |
| Practice 03 | Done |
| Visual dashboard | Added |
| README visualization | Added |