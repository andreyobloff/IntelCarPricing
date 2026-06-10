#requires -Version 5.1
<#
.SYNOPSIS
    Стартовая инициализация Git-ориентированной среды проекта IntelCarPricing.

.DESCRIPTION
    Скрипт подготавливает локальный репозиторий проекта:
    - проверяет наличие docs/assignment-map.md;
    - инициализирует Git, если .git ещё нет;
    - создаёт структуру каталогов согласно assignment-map.md;
    - создаёт базовые Markdown/CSV/YAML/PlantUML-файлы;
    - настраивает .gitignore, .gitattributes, .editorconfig;
    - создаёт шаблоны GitHub Issues и Pull Request;
    - создаёт GitHub Actions workflow для проверки ключевых артефактов;
    - делает commit;
    - при ключе -Push отправляет изменения в origin/main.

.NOTES
    Авторская рамка проекта:
    Облов Андрей Андреевич, СИИ-23, 3 курс, РАНХиГС ЭМИТ.

    Версия скрипта: 1.1.1
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = "C:\PROJECTSPE\IntelCarPricing",
    [string]$RepoUrl = "https://github.com/andreyobloff/IntelCarPricing.git",
    [string]$DefaultBranch = "main",
    [switch]$Push,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Utf8NoBom = New-Object System.Text.UTF8Encoding -ArgumentList $false

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[OK]   $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Require-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Команда '$Name' не найдена. Установите '$Name' и повторите запуск."
    }
}

function Join-RepoPath {
    param([string]$RelativePath)
    return Join-Path $RepoRoot $RelativePath
}

function Ensure-Directory {
    param([string]$RelativePath)

    $path = Join-RepoPath $RelativePath

    if (-not (Test-Path $path -PathType Container)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Info "Создан каталог: $RelativePath"
    }
}

function Write-TextFile {
    param(
        [string]$RelativePath,
        [string]$Content,
        [switch]$Overwrite
    )

    $path = Join-RepoPath $RelativePath
    $parent = Split-Path -Parent $path

    if ($parent -and -not (Test-Path $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if ((Test-Path $path -PathType Leaf) -and -not $Overwrite) {
        Write-Info "Файл уже существует, не перезаписываю: $RelativePath"
        return
    }

    $normalized = $Content -replace "`r?`n", "`n"
    [System.IO.File]::WriteAllText($path, $normalized, $Utf8NoBom)
    Write-Info "Создан файл: $RelativePath"
}

function Ensure-GitKeep {
    param([string]$RelativePath)

    Ensure-Directory $RelativePath

    $gitKeep = Join-Path $RelativePath ".gitkeep"
    Write-TextFile -RelativePath $gitKeep -Content ""
}

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & git @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Git command failed: git $($Arguments -join ' ')"
    }
}

function Invoke-GitOptional {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    try {
        $output = & git @Arguments 2>$null
        $exitCode = $LASTEXITCODE

        return [pscustomobject]@{
            ExitCode = $exitCode
            Output   = (($output | Out-String).Trim())
        }
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
}

function Get-GitConfig {
    param([string]$Key)

    $result = Invoke-GitOptional -Arguments @("config", "--get", $Key)

    if ($result.ExitCode -ne 0) {
        return $null
    }

    return $result.Output
}

Require-Command "git"

if (-not (Test-Path $RepoRoot -PathType Container)) {
    New-Item -ItemType Directory -Path $RepoRoot -Force | Out-Null
    Write-Info "Создан корневой каталог проекта: $RepoRoot"
}

Set-Location $RepoRoot

$assignmentMapPath = Join-Path $RepoRoot "docs\assignment-map.md"

if (-not (Test-Path $assignmentMapPath -PathType Leaf)) {
    throw "Не найден обязательный файл: $assignmentMapPath. Сначала положите assignment-map.md в C:\PROJECTSPE\IntelCarPricing\docs."
}

Write-Ok "Найден docs/assignment-map.md"

$insideWorkTreeCheck = Invoke-GitOptional -Arguments @("rev-parse", "--is-inside-work-tree")

if ($insideWorkTreeCheck.ExitCode -ne 0 -or $insideWorkTreeCheck.Output -ne "true") {
    Write-Info "Git-репозиторий не найден. Выполняю git init."
    Invoke-Git -Arguments @("init")
    Invoke-Git -Arguments @("branch", "-M", $DefaultBranch)
}
else {
    Write-Ok "Git-репозиторий уже инициализирован."
}

$currentBranchCheck = Invoke-GitOptional -Arguments @("branch", "--show-current")
$currentBranch = $currentBranchCheck.Output

if ([string]::IsNullOrWhiteSpace($currentBranch)) {
    Invoke-Git -Arguments @("checkout", "-B", $DefaultBranch)
}
elseif ($currentBranch -ne $DefaultBranch) {
    if ($Force) {
        Write-Warn "Текущая ветка '$currentBranch' будет переименована в '$DefaultBranch'."
        Invoke-Git -Arguments @("branch", "-M", $DefaultBranch)
    }
    else {
        Write-Warn "Текущая ветка: '$currentBranch'. Ожидаемая: '$DefaultBranch'. Для принудительного переименования используйте -Force."
    }
}

$directories = @(
    "docs\problem-statement",
    "docs\planning",
    "docs\risk-management",
    "docs\presentations",
    "docs\reports\project-management-reports",
    "project\msproject\exports\reports",
    "project\github-project",
    "models\uml\exports",
    "models\idef\exports",
    "models\bpmn\simulation",
    "models\bpmn\exports",
    "scripts\powershell",
    ".github\ISSUE_TEMPLATE",
    ".github\workflows",
    "releases"
)

foreach ($dir in $directories) {
    Ensure-Directory $dir
}

$emptyDirectories = @(
    "models\uml\exports",
    "models\idef\exports",
    "models\bpmn\exports",
    "project\msproject\exports\reports",
    "docs\reports\project-management-reports",
    "releases"
)

foreach ($dir in $emptyDirectories) {
    Ensure-GitKeep $dir
}

Write-TextFile ".gitignore" @'
# OS / editor noise
.DS_Store
Thumbs.db
desktop.ini

# Office temporary files
~$*
*.tmp
*.temp
*.bak

# Logs
*.log

# Local IDE state
.idea/
.vscode/

# Local environment files
.env
.env.*
'@

Write-TextFile ".gitattributes" @'
* text=auto

*.md text eol=lf
*.csv text eol=lf
*.xml text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.json text eol=lf
*.puml text eol=lf
*.bpmn text eol=lf
*.drawio text eol=lf
*.ps1 text eol=crlf

*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.svg text eol=lf
*.pdf binary
*.doc binary
*.docx binary
*.xls binary
*.xlsx binary
*.ppt binary
*.pptx binary
*.mpp binary
*.bpm binary
'@

Write-TextFile ".editorconfig" @'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.ps1]
end_of_line = crlf

[*.md]
trim_trailing_whitespace = false
'@

Write-TextFile "README.md" @'
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
'@

Write-TextFile "PROJECT_CHARTER.md" @'
# Паспорт проекта

**Название проекта:** Интеллектуальное ценообразование на автомобильную продукцию  
**Автор:** Облов Андрей Андреевич, СИИ-23, 3 курс, РАНХиГС ЭМИТ  
**Дисциплина:** Управление проектами  
**Среда управления:** Git/GitHub как основной интерфейс проектной деятельности

## Цель проекта

Разработать и документально описать проект внедрения системы интеллектуального ценообразования на автомобильную продукцию с использованием Git/GitHub как единой управляемой среды хранения, планирования, трассировки и контроля проектных артефактов.

## Основная идея

Проект исследует возможность вести управление проектом преимущественно средствами Git/GitHub: через структуру репозитория, issues, milestones, labels, project fields, pull requests, commit history, Markdown-документацию и воспроизводимые файлы моделей.

## Ожидаемые результаты

- постановка задачи проекта;
- календарная и ресурсная модель;
- карта практических заданий и артефактов;
- IDEF0/IDEF3-модели;
- UML-диаграммы;
- BPMN-процессы;
- документация бизнес-процесса;
- сценарии «КАК ЕСТЬ» и «КАК ДОЛЖНО БЫТЬ»;
- реестр и анализ рисков;
- презентация по успешным проектам;
- комплект итоговых файлов для сдачи.
'@

Write-TextFile "CHANGELOG.md" @'
# Changelog

## 0.1.0 — Инициализация проектной среды

- Добавлена карта соответствия практических заданий `docs/assignment-map.md`.
- Подготовлена базовая структура Git-репозитория.
- Добавлены шаблоны документации, планирования и контроля артефактов.
'@

Write-TextFile "docs\problem-statement\statement.md" @'
# Постановка задачи

## Проект

Интеллектуальное ценообразование на автомобильную продукцию.

## Предварительная формулировка

Необходимо разработать проект внедрения системы, которая поддерживает анализ данных о продукции, рынке, спросе, конкурентных ценах и бизнес-ограничениях для формирования обоснованных ценовых рекомендаций по автомобильной продукции.

## Назначение документа

Документ будет использоваться для практического занятия №1 и станет основой для WBS, календарного плана, ресурсного плана, UML/BPMN/IDEF-моделей и реестра рисков.
'@

Write-TextFile "docs\planning\work-breakdown-structure.md" @'
# Иерархическая структура работ

## Назначение

Документ фиксирует предварительный состав работ проекта для дальнейшего переноса в GitHub Issues, GitHub Projects, CSV и MS Project XML.

## Верхнеуровневые этапы

1. Инициация и постановка задачи.
2. Календарное и ресурсное планирование.
3. Контроль исполнения и отчётность.
4. Функциональное моделирование.
5. UML-моделирование.
6. BPMN-моделирование.
7. Имитационное моделирование процессов.
8. Управление рисками и итоговая комплектация.

## Предварительный перечень задач

См. `project/msproject/exports/tasks.csv`.
'@

Write-TextFile "docs\planning\resource-plan.md" @'
# Ресурсный план

## Назначение

Документ фиксирует предварительный состав ресурсов проекта и будет использоваться для практических занятий №1 и №2.

## Основные ресурсы

См. `project/msproject/exports/resources.csv`.

## Правило управления ресурсами

Назначение ресурсов должно исключать конфликт доступности. При выявлении перегрузки применяется ручное выравнивание: изменение назначения, перенос задачи, увеличение длительности, замена ресурса или пересмотр критического пути.
'@

Write-TextFile "docs\planning\baseline-plan.md" @'
# Базовый план

## Назначение

Базовый план фиксирует согласованное состояние сроков, длительностей и затрат проекта до ввода фактического выполнения.

## Связанные файлы

- `project/msproject/exports/baseline.csv`
- `project/msproject/exports/actuals.csv`
- `docs/planning/actual-progress.md`
- `docs/planning/earned-value.md`
'@

Write-TextFile "docs\planning\actual-progress.md" @'
# Фактическое выполнение

## Назначение

Документ используется для фиксации процента завершения, фактических сроков, фактической длительности и отклонений от базового плана.

## Связанный источник

`project/msproject/exports/actuals.csv`
'@

Write-TextFile "docs\planning\earned-value.md" @'
# Освоенный объём

## Назначение

Документ предназначен для анализа исполнения проекта по срокам и стоимости.

## Метрики

- Planned Value.
- Earned Value.
- Actual Cost.
- Schedule Variance.
- Cost Variance.
- Schedule Performance Index.
- Cost Performance Index.
'@

Write-TextFile "docs\planning\dependencies.md" @'
# Зависимости задач

## Назначение

Документ фиксирует связи между задачами проекта, включая последовательные и параллельные работы.

## Типы связей

- FS — окончание-начало.
- SS — начало-начало.
- FF — окончание-окончание.
- SF — начало-окончание.

## Источник данных

`project/msproject/exports/tasks.csv`
'@

Write-TextFile "docs\planning\critical-path.md" @'
# Критический путь

## Назначение

Документ предназначен для фиксации задач, влияющих на общую длительность проекта.

## Правило

Задачи критического пути должны быть помечены label `critical-path` и иметь признак `Critical Path = true` в GitHub Projects.
'@

Write-TextFile "docs\planning\resource-load.md" @'
# Загрузка ресурсов

## Назначение

Документ фиксирует анализ доступности ресурсов, перегрузки и решения по выравниванию.

## Связанные файлы

- `project/msproject/exports/resources.csv`
- `project/msproject/exports/assignments.csv`
- `project/msproject/exports/resource-usage.csv`
'@

Write-TextFile "docs\planning\resource-leveling.md" @'
# Выравнивание ресурсов

## Назначение

Документ фиксирует решения по устранению конфликтов ресурсов.

## Допустимые решения

1. Перенос задачи.
2. Увеличение длительности задачи.
3. Замена перегруженного ресурса.
4. Снижение процента занятости.
5. Разделение задачи.
6. Пересмотр параллельности работ.
'@

Write-TextFile "docs\risk-management\risk-register.md" @'
# Реестр рисков

| ID | Риск | Категория | Вероятность | Влияние | Уровень | Реакция | Ответственный | Статус |
|---|---|---|---:|---:|---|---|---|---|
| R-001 | Недостаточное качество исходных данных для ценообразования | Данные | 0.6 | 0.8 | high | Очистка, профилирование, контроль качества данных | Data Scientist | planned |
| R-002 | Перегрузка ключевых ресурсов проекта | Ресурсы | 0.5 | 0.7 | medium | Выравнивание загрузки и пересмотр зависимостей | Руководитель проекта | planned |
| R-003 | Несогласованность бизнес-правил ценообразования | Бизнес | 0.4 | 0.8 | high | Валидация с бизнес-экспертом | Системный аналитик | planned |
| R-004 | Сложность интеграции модели в процесс принятия решений | Технологии | 0.4 | 0.7 | medium | Прототипирование и staged rollout | Backend-разработчик | planned |
| R-005 | Неполная трассировка учебных требований | Управление | 0.3 | 0.8 | medium | Контроль через assignment-map.md и GitHub Issues | Руководитель проекта | planned |
'@

Write-TextFile "docs\risk-management\risk-register.csv" @'
ID,Risk,Category,Probability,Impact,Level,Response,Owner,Status
R-001,"Недостаточное качество исходных данных для ценообразования","Данные",0.6,0.8,high,"Очистка, профилирование, контроль качества данных","Data Scientist",planned
R-002,"Перегрузка ключевых ресурсов проекта","Ресурсы",0.5,0.7,medium,"Выравнивание загрузки и пересмотр зависимостей","Руководитель проекта",planned
R-003,"Несогласованность бизнес-правил ценообразования","Бизнес",0.4,0.8,high,"Валидация с бизнес-экспертом","Системный аналитик",planned
R-004,"Сложность интеграции модели в процесс принятия решений","Технологии",0.4,0.7,medium,"Прототипирование и staged rollout","Backend-разработчик",planned
R-005,"Неполная трассировка учебных требований","Управление",0.3,0.8,medium,"Контроль через assignment-map.md и GitHub Issues","Руководитель проекта",planned
'@

Write-TextFile "docs\risk-management\risk-matrix.md" @'
# Матрица вероятности и влияния

| Влияние \ Вероятность | Низкая | Средняя | Высокая |
|---|---|---|---|
| Высокое | medium | high | high |
| Среднее | low | medium | high |
| Низкое | low | low | medium |
'@

Write-TextFile "docs\risk-management\risk-response-plan.md" @'
# План реагирования на риски

## Назначение

Документ фиксирует меры по снижению вероятности и последствий ключевых рисков проекта.

## Принцип

Для каждого значимого риска должны быть определены владелец, стратегия реагирования, действие, срок контроля и статус.
'@

Write-TextFile "docs\presentations\successful-projects.md" @'
# Успешные проекты по предметной области

## Назначение

Исходный материал для презентации по практической работе №7.

## Предметная область

Интеллектуальное ценообразование, pricing analytics, dynamic pricing, automotive retail analytics, AI pricing.
'@

Write-TextFile "docs\reports\practice-10-business-process-report.md" @'
# Документирование бизнес-процесса

## Практическая работа №10

Документ будет использоваться для описания выбранного BPMN-процесса, его дорожек, задач, событий, подпроцессов, объектов данных, хранилищ данных и логических операторов.
'@

Write-TextFile "models\bpmn\simulation\as-is-scenario.md" @'
# Сценарий бизнес-процесса «КАК ЕСТЬ»

## Назначение

Сценарий описывает текущее состояние процесса формирования ценовых решений без полноценной интеллектуальной автоматизации.
'@

Write-TextFile "models\bpmn\simulation\to-be-scenario.md" @'
# Сценарий бизнес-процесса «КАК ДОЛЖНО БЫТЬ»

## Назначение

Сценарий описывает целевое состояние процесса с применением системы интеллектуального ценообразования.
'@

Write-TextFile "models\bpmn\simulation\as-is-parameters.csv" @'
Parameter,Value,Unit,Comment
AverageDataPreparationTime,16,hours,"Высокая доля ручной подготовки данных"
ManualOperationsCount,12,count,"Много ручных операций"
DataErrorProbability,0.25,probability,"Средняя или высокая вероятность ошибки"
PriceApprovalTime,8,hours,"Длительное согласование цены"
'@

Write-TextFile "models\bpmn\simulation\to-be-parameters.csv" @'
Parameter,Value,Unit,Comment
AverageDataPreparationTime,6,hours,"Сокращение времени подготовки данных"
ManualOperationsCount,5,count,"Снижение количества ручных операций"
DataErrorProbability,0.08,probability,"Контроль качества данных"
PriceApprovalTime,3,hours,"Ускоренное согласование цены"
'@

Write-TextFile "project\msproject\README.md" @'
# MS Project совместимый слой

## Назначение

Каталог содержит совместимые представления календарного и ресурсного плана проекта.

## Принцип

GitHub Issues и GitHub Projects используются как основной интерфейс управления.  
MS Project XML, CSV и отчёты используются как формализованные представления для календарного планирования, базового плана, ресурсов, назначений и контроля исполнения.

## Следующий шаг

На следующем этапе из CSV-файлов будет сформирован корректный `IntelCarPricing.xml`.
'@

Write-TextFile "project\msproject\exports\tasks.csv" @'
UID,WBS,Title,Practice,Summary,Milestone,DurationDays,Start,Finish,Predecessors,DependencyType,ConstraintType,ConstraintDate,ResourceNames,Critical,Status,DeliverablePath
1,1,"Инициация проекта","practice-01",true,false,1,,,,,,,"Руководитель проекта",false,planned,"PROJECT_CHARTER.md"
2,1.1,"Уточнение темы проекта","practice-01",false,false,1,,,,,,,"Руководитель проекта",false,planned,"PROJECT_CHARTER.md"
3,1.2,"Формирование паспорта проекта","practice-01",false,false,1,,"",2,FS,,,"Руководитель проекта",false,planned,"PROJECT_CHARTER.md"
4,1.3,"Анализ требований практических работ","practice-01",false,false,2,,"",3,FS,,,"Системный аналитик",true,planned,"docs/assignment-map.md"
5,1.4,"Подготовка карты соответствия заданий","practice-01",false,true,1,,"",4,FS,,,"Системный аналитик",true,planned,"docs/assignment-map.md"
6,2,"Календарное и ресурсное планирование","practice-02-1",true,false,1,,,,,,,"Руководитель проекта",false,planned,"docs/planning/"
7,2.1,"Формирование WBS","practice-01",false,false,2,,"",5,FS,,,"Руководитель проекта",true,planned,"docs/planning/work-breakdown-structure.md"
8,2.2,"Подготовка календаря проекта","practice-01",false,false,1,,"",7,FS,,,"Руководитель проекта",true,planned,"project/msproject/"
9,2.3,"Настройка проектных ресурсов","practice-02-1",false,false,1,,"",8,FS,,,"Руководитель проекта",true,planned,"docs/planning/resource-plan.md"
10,2.4,"Определение длительности задач","practice-01",false,false,1,,"",9,FS,,,"Руководитель проекта",true,planned,"project/msproject/exports/tasks.csv"
11,2.5,"Настройка связей задач","practice-02-1",false,false,1,,"",10,FS,,,"Руководитель проекта",true,planned,"docs/planning/dependencies.md"
12,2.6,"Определение параллельных работ","practice-02-1",false,false,1,,"",11,SS,,,"Руководитель проекта",false,planned,"docs/planning/dependencies.md"
13,2.7,"Определение критического пути","practice-02-1",false,true,1,,"",11,FS,,,"Руководитель проекта",true,planned,"docs/planning/critical-path.md"
14,2.8,"Назначение ресурсов задачам","practice-02-1",false,false,1,,"",13,FS,,,"Руководитель проекта",true,planned,"project/msproject/exports/assignments.csv"
15,2.9,"Анализ ресурсных перегрузок","practice-02-1",false,false,1,,"",14,FS,,,"Руководитель проекта",true,planned,"docs/planning/resource-load.md"
16,2.10,"Выравнивание загрузки ресурсов","practice-02-1",false,true,1,,"",15,FS,,,"Руководитель проекта",true,planned,"docs/planning/resource-leveling.md"
17,3,"Контроль исполнения и отчётность","practice-02-2",true,false,1,,,,,,,"Руководитель проекта",false,planned,"docs/planning/"
18,3.1,"Создание базового плана","practice-02-2",false,true,1,,"",16,FS,,,"Руководитель проекта",true,planned,"docs/planning/baseline-plan.md"
19,3.2,"Ввод фактических данных","practice-02-2",false,false,1,,"",18,FS,,,"Руководитель проекта",false,planned,"project/msproject/exports/actuals.csv"
20,3.3,"Анализ отклонений по срокам","practice-02-2",false,false,1,,"",19,FS,,,"Руководитель проекта",false,planned,"docs/planning/actual-progress.md"
21,3.4,"Анализ отклонений по стоимости","practice-02-2",false,false,1,,"",19,FS,,,"Руководитель проекта",false,planned,"docs/planning/earned-value.md"
22,3.5,"Подготовка отчётов по проекту","practice-02-2",false,true,1,,"",20,FS,,,"Руководитель проекта",false,planned,"project/msproject/exports/reports/"
23,4,"Функциональное моделирование","practice-03",true,false,1,,,,,,,"Системный аналитик",false,planned,"models/idef/"
24,4.1,"Создание IDEF0-модели","practice-03",false,true,2,,"",22,FS,,,"Системный аналитик",false,planned,"models/idef/idef0-context.drawio"
25,4.2,"Создание IDEF3-модели","practice-04",false,true,2,,"",24,FS,,,"Системный аналитик",false,planned,"models/idef/idef3-process.drawio"
26,5,"UML-моделирование","practice-05",true,false,1,,,,,,,"Системный аналитик",false,planned,"models/uml/"
27,5.1,"Создание UML Use Case","practice-05",false,true,1,,"",25,FS,,,"Системный аналитик",false,planned,"models/uml/use-case.puml"
28,5.2,"Создание UML Sequence","practice-05",false,true,1,,"",27,FS,,,"Системный аналитик",false,planned,"models/uml/sequence.puml"
29,5.3,"Создание UML Class Diagram","practice-06",false,true,1,,"",28,FS,,,"Системный аналитик",false,planned,"models/uml/class-diagram.puml"
30,5.4,"Создание UML Activity Diagram","practice-06",false,true,1,,"",29,FS,,,"Системный аналитик",false,planned,"models/uml/activity.puml"
31,6,"BPMN-моделирование","practice-08",true,false,1,,,,,,,"Системный аналитик",false,planned,"models/bpmn/"
32,6.1,"Создание первого BPMN-процесса","practice-08",false,true,2,,"",30,FS,,,"Системный аналитик;Data Scientist",false,planned,"models/bpmn/pricing-data-preparation.bpmn"
33,6.2,"Создание второго BPMN-процесса","practice-09",false,true,2,,"",32,FS,,,"Системный аналитик;Data Scientist",false,planned,"models/bpmn/pricing-model-deployment.bpmn"
34,6.3,"Документирование BPMN-процесса","practice-10",false,true,2,,"",33,FS,,,"Системный аналитик",false,planned,"docs/reports/practice-10-business-process-report.md"
35,7,"Имитационное моделирование","practice-11",true,false,1,,,,,,,"Системный аналитик",false,planned,"models/bpmn/simulation/"
36,7.1,"Подготовка сценария КАК ЕСТЬ","practice-11",false,false,1,,"",34,FS,,,"Системный аналитик",false,planned,"models/bpmn/simulation/as-is-scenario.md"
37,7.2,"Подготовка сценария КАК ДОЛЖНО БЫТЬ","practice-11",false,false,1,,"",36,FS,,,"Системный аналитик;Data Scientist",false,planned,"models/bpmn/simulation/to-be-scenario.md"
38,7.3,"Сравнение сценариев бизнес-процесса","practice-11",false,true,1,,"",37,FS,,,"Системный аналитик",false,planned,"docs/reports/practice-11-as-is-simulation.xlsx"
39,8,"Риски и итоговая комплектация","practice-12",true,false,1,,,,,,,"Руководитель проекта",false,planned,"docs/risk-management/"
40,8.1,"Формирование реестра рисков","practice-12",false,false,1,,"",38,FS,,,"Руководитель проекта",false,planned,"docs/risk-management/risk-register.md"
41,8.2,"Количественный анализ рисков","practice-12",false,false,1,,"",40,FS,,,"Руководитель проекта;Data Scientist",false,planned,"docs/risk-management/probability-distribution.svg"
42,8.3,"Подготовка презентации по успешным проектам","practice-07",false,false,2,,"",25,SS,,,"Руководитель проекта",false,planned,"docs/presentations/practice-07-successful-projects.pptx"
43,8.4,"Финальная комплектация артефактов","practice-12",false,true,1,,"",41,FS,,,"Руководитель проекта",true,planned,"releases/"
'@

Write-TextFile "project\msproject\exports\resources.csv" @'
ResourceID,ResourceName,Type,MaxUnits,StandardRate,OvertimeRate,CostPerUse,Calendar,Owner,Notes
R-001,"Руководитель проекта","Work",100%,0,0,0,"Standard","Облов Андрей Андреевич","Планирование, контроль, координация"
R-002,"Системный аналитик","Work",100%,0,0,0,"Standard","Облов Андрей Андреевич","Требования, постановка задачи, UML, BPMN"
R-003,"Data Scientist","Work",100%,0,0,0,"Standard","Облов Андрей Андреевич","Логика интеллектуального ценообразования, модель, метрики"
R-004,"Backend-разработчик","Work",100%,0,0,0,"Standard","Облов Андрей Андреевич","Интеграционная логика, API, хранение данных"
R-005,"Бизнес-эксперт по автомобильной продукции","Work",50%,0,0,0,"Standard","Облов Андрей Андреевич","Валидация правил ценообразования"
R-006,"Тестировщик","Work",50%,0,0,0,"Standard","Облов Андрей Андреевич","Проверка сценариев и качества результатов"
R-007,"Репозиторий GitHub","Cost",,0,0,0,"","Облов Андрей Андреевич","Хранение артефактов, issues, project board"
R-008,"Рабочая станция","Material",,0,0,0,"","Облов Андрей Андреевич","Подготовка документации, моделей, расчётов"
R-009,"Данные о ценах и продуктах","Material",,0,0,0,"","Облов Андрей Андреевич","Источник для модели ценообразования"
R-010,"Облачная среда/сервер","Cost",,0,0,0,"","Облов Андрей Андреевич","Размещение прототипа и расчётов"
'@

Write-TextFile "project\msproject\exports\assignments.csv" @'
AssignmentID,TaskUID,ResourceID,ResourceName,Units,WorkHours,Cost,Notes
A-001,1,R-001,"Руководитель проекта",100%,8,0,"Инициация проекта"
A-002,4,R-002,"Системный аналитик",100%,16,0,"Анализ требований практических работ"
A-003,9,R-001,"Руководитель проекта",100%,8,0,"Настройка проектных ресурсов"
A-004,24,R-002,"Системный аналитик",100%,16,0,"IDEF0"
A-005,32,R-002,"Системный аналитик",50%,8,0,"BPMN процесс подготовки данных"
A-006,32,R-003,"Data Scientist",50%,8,0,"BPMN процесс подготовки данных"
A-007,41,R-003,"Data Scientist",50%,8,0,"Количественный анализ рисков"
'@

Write-TextFile "project\msproject\exports\baseline.csv" @'
TaskUID,BaselineStart,BaselineFinish,BaselineDurationDays,BaselineCost
1,,,,0
'@

Write-TextFile "project\msproject\exports\actuals.csv" @'
TaskUID,ActualStart,ActualFinish,ActualDurationDays,PercentComplete,ActualCost
1,,,,0,0
'@

Write-TextFile "project\github-project\labels.md" @'
# GitHub labels

| Label | Назначение |
|---|---|
| `practice-01` | Практическое занятие №1 |
| `practice-02-1` | Практическое занятие №2, часть 1 |
| `practice-02-2` | Практическое занятие №2, часть 2 |
| `practice-03` | Практическая работа №3 |
| `practice-04` | Практическая работа №4 |
| `practice-05` | Практическая работа №5 |
| `practice-06` | Практическое задание №6 |
| `practice-07` | Практическая работа №7 |
| `practice-08` | Практическая работа №8 |
| `practice-09` | Практическая работа №9 |
| `practice-10` | Практическая работа №10 |
| `practice-11` | Практическая работа №11 |
| `practice-12` | Практическая работа №12 |
| `artifact:doc` | Документ |
| `artifact:model` | Модель или диаграмма |
| `artifact:plan` | План проекта |
| `artifact:risk` | Риски |
| `artifact:report` | Отчёт |
| `artifact:presentation` | Презентация |
| `artifact:xml` | XML-артефакт |
| `artifact:csv` | Табличный источник |
| `artifact:export` | Производный экспорт |
| `status:planned` | Запланировано |
| `status:in-progress` | В работе |
| `status:review` | На проверке |
| `status:done` | Завершено |
| `risk:high` | Высокий риск |
| `risk:medium` | Средний риск |
| `risk:low` | Низкий риск |
| `critical-path` | Задача критического пути |
| `resource-overload` | Ресурсная перегрузка |
| `baseline` | Связано с базовым планом |
| `actuals` | Связано с фактическим выполнением |
| `simulation` | Имитационное моделирование |
'@

Write-TextFile "project\github-project\milestones.md" @'
# GitHub milestones

| Milestone | Содержание |
|---|---|
| `M1 — Инициация и постановка задачи` | Постановка задачи, паспорт проекта, WBS, первичный календарный план |
| `M2 — Календарное и ресурсное планирование` | Связи задач, критический путь, ресурсы, назначения, выравнивание ресурсов, базовый план |
| `M3 — Контроль исполнения и отчётность` | Фактическое выполнение, отклонения, освоенный объём, отчёты по затратам и ресурсам |
| `M4 — Функциональное моделирование` | IDEF0 и IDEF3 модели |
| `M5 — UML-моделирование` | Use Case, Sequence, Class, Activity diagrams |
| `M6 — BPMN-моделирование` | Два бизнес-процесса, документация, обновлённые модели |
| `M7 — Имитационное моделирование процессов` | Сценарии «КАК ЕСТЬ» и «КАК ДОЛЖНО БЫТЬ», Excel-отчёты, обновлённая модель |
| `M8 — Риски и итоговая комплектация` | Реестр рисков, план реагирования, количественный анализ, финальные экспорты |
'@

Write-TextFile "project\github-project\fields.md" @'
# GitHub Project fields

| Поле | Тип | Назначение |
|---|---|---|
| `Status` | Single select | Текущий статус задачи |
| `Practice` | Single select | Номер практической работы |
| `Artifact Type` | Single select | Тип результата |
| `Priority` | Single select | Приоритет |
| `Start Date` | Date | Плановая дата начала |
| `Target Date` | Date | Плановая дата завершения |
| `Actual Start` | Date | Фактическая дата начала |
| `Actual Finish` | Date | Фактическая дата завершения |
| `Planned Duration` | Number | Плановая длительность |
| `Actual Duration` | Number | Фактическая длительность |
| `% Complete` | Number | Процент завершения |
| `Baseline Cost` | Number | Базовые затраты |
| `Actual Cost` | Number | Фактические затраты |
| `Cost Variance` | Number | Отклонение по стоимости |
| `Schedule Variance` | Number | Отклонение по длительности или сроку |
| `MS Project UID` | Text/Number | Связь с задачей в XML-плане |
| `Resource` | Text | Назначенный ресурс |
| `Risk Level` | Single select | Уровень риска |
| `Deliverable Path` | Text | Путь к итоговому файлу в репозитории |
| `Review Status` | Single select | Статус проверки результата |
| `Blocked By` | Text | Зависимость от другой задачи |
| `Critical Path` | Boolean | Признак задачи критического пути |
'@

Write-TextFile "project\github-project\issue-map.md" @'
# Карта GitHub Issues

## Назначение

Документ связывает практические работы, GitHub Issues, milestones, labels и deliverables.

## Правило

Одна практическая работа может быть представлена несколькими issues, если в ней есть независимые deliverables: документ, модель, отчёт, презентация, CSV, XML, экспорт.
'@

Write-TextFile "project\github-project\project-views.md" @'
# Представления GitHub Project

## Table view

Основное представление для контроля всех задач и полей.

## Board view

Kanban-представление по статусам: planned, in-progress, review, done.

## Roadmap view

Дорожная карта по Start Date и Target Date.

## Risk view

Отдельный фильтр задач и артефактов, связанных с рисками.
'@

Write-TextFile "project\github-project\issues.seed.csv" @'
Title,Practice,Milestone,Labels,DeliverablePath
"Практика 01: постановка задачи и первичный календарный план","practice-01","M1 — Инициация и постановка задачи","practice-01;artifact:plan;status:planned","docs/problem-statement/statement.md"
"Практика 02.1: связи, ресурсы и критический путь","practice-02-1","M2 — Календарное и ресурсное планирование","practice-02-1;artifact:plan;status:planned","docs/planning/critical-path.md"
"Практика 02.2: базовый план и отчётность","practice-02-2","M3 — Контроль исполнения и отчётность","practice-02-2;artifact:report;baseline;actuals;status:planned","docs/planning/earned-value.md"
"Практика 03: IDEF0 модель","practice-03","M4 — Функциональное моделирование","practice-03;artifact:model;status:planned","models/idef/idef0-context.drawio"
"Практика 04: IDEF3 и декомпозиция","practice-04","M4 — Функциональное моделирование","practice-04;artifact:model;status:planned","models/idef/idef3-process.drawio"
"Практика 05: Use Case и Sequence","practice-05","M5 — UML-моделирование","practice-05;artifact:model;status:planned","models/uml/"
"Практика 06: Class и Activity","practice-06","M5 — UML-моделирование","practice-06;artifact:model;status:planned","models/uml/"
"Практика 07: успешные проекты и презентация","practice-07","M8 — Риски и итоговая комплектация","practice-07;artifact:presentation;status:planned","docs/presentations/"
"Практика 08: первый BPMN-процесс","practice-08","M6 — BPMN-моделирование","practice-08;artifact:model;status:planned","models/bpmn/pricing-data-preparation.bpmn"
"Практика 09: второй BPMN-процесс","practice-09","M6 — BPMN-моделирование","practice-09;artifact:model;status:planned","models/bpmn/pricing-model-deployment.bpmn"
"Практика 10: документация бизнес-процесса","practice-10","M6 — BPMN-моделирование","practice-10;artifact:report;status:planned","docs/reports/practice-10-business-process-report.md"
"Практика 11: сценарии КАК ЕСТЬ / КАК ДОЛЖНО БЫТЬ","practice-11","M7 — Имитационное моделирование процессов","practice-11;simulation;artifact:report;status:planned","models/bpmn/simulation/"
"Практика 12: управление рисками","practice-12","M8 — Риски и итоговая комплектация","practice-12;artifact:risk;status:planned","docs/risk-management/risk-register.md"
'@

Write-TextFile ".github\ISSUE_TEMPLATE\practice-artifact.yml" @'
name: Практическая работа / артефакт
description: Задача по практической работе дисциплины «Управление проектами»
title: "[practice-XX] "
labels:
  - status:planned
body:
  - type: input
    id: practice
    attributes:
      label: Практическая работа
      description: Например, practice-01, practice-08, practice-12
      placeholder: practice-XX
    validations:
      required: true
  - type: input
    id: deliverable
    attributes:
      label: Deliverable path
      description: Путь к итоговому артефакту в репозитории
      placeholder: docs/... или models/...
    validations:
      required: true
  - type: textarea
    id: scope
    attributes:
      label: Содержание работ
      description: Что должно быть выполнено
    validations:
      required: true
  - type: textarea
    id: acceptance
    attributes:
      label: Критерии готовности
      description: Как понять, что задача завершена
    validations:
      required: true
'@

Write-TextFile ".github\ISSUE_TEMPLATE\risk.yml" @'
name: Проектный риск
description: Фиксация риска проекта IntelCarPricing
title: "[risk] "
labels:
  - artifact:risk
  - status:planned
body:
  - type: input
    id: risk_id
    attributes:
      label: Risk ID
      placeholder: R-XXX
    validations:
      required: true
  - type: textarea
    id: description
    attributes:
      label: Описание риска
    validations:
      required: true
  - type: dropdown
    id: probability
    attributes:
      label: Вероятность
      options:
        - Низкая
        - Средняя
        - Высокая
    validations:
      required: true
  - type: dropdown
    id: impact
    attributes:
      label: Влияние
      options:
        - Низкое
        - Среднее
        - Высокое
    validations:
      required: true
  - type: textarea
    id: response
    attributes:
      label: План реакции
    validations:
      required: true
'@

Write-TextFile ".github\PULL_REQUEST_TEMPLATE.md" @'
# Pull Request

## Назначение изменения

Кратко описать, какой практической работе или проектному артефакту соответствует изменение.

## Связанные практические работы

- [ ] practice-01
- [ ] practice-02-1
- [ ] practice-02-2
- [ ] practice-03
- [ ] practice-04
- [ ] practice-05
- [ ] practice-06
- [ ] practice-07
- [ ] practice-08
- [ ] practice-09
- [ ] practice-10
- [ ] practice-11
- [ ] practice-12

## Проверка

- [ ] Артефакт расположен в согласованном каталоге.
- [ ] Исходный файл хранится в Git-совместимом формате.
- [ ] Производный экспорт отделён от исходника.
- [ ] Изменение отражено в `docs/assignment-map.md` или не требует обновления карты.
- [ ] Нет конфликтов ресурсов или неотслеживаемых зависимостей.
'@

Write-TextFile ".github\workflows\validate-project-artifacts.yml" @'
name: Validate project artifacts

on:
  push:
  pull_request:

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Validate required files
        shell: pwsh
        run: |
          $required = @(
            "README.md",
            "PROJECT_CHARTER.md",
            "CHANGELOG.md",
            "docs/assignment-map.md",
            "project/github-project/labels.md",
            "project/github-project/milestones.md",
            "project/github-project/fields.md",
            "project/msproject/exports/tasks.csv",
            "project/msproject/exports/resources.csv",
            "project/msproject/exports/assignments.csv",
            "docs/risk-management/risk-register.md"
          )

          $missing = @()

          foreach ($file in $required) {
            if (-not (Test-Path $file)) {
              $missing += $file
            }
          }

          if ($missing.Count -gt 0) {
            Write-Error ("Missing required files: " + ($missing -join ", "))
          }

      - name: Validate assignment map is not empty
        shell: pwsh
        run: |
          $content = Get-Content "docs/assignment-map.md" -Raw

          if ([string]::IsNullOrWhiteSpace($content)) {
            Write-Error "docs/assignment-map.md is empty"
          }

          if ($content -notmatch "Интеллектуальное ценообразование") {
            Write-Error "assignment-map.md does not contain expected project topic"
          }
'@

Write-TextFile "scripts\README.md" @'
# Scripts

Каталог предназначен для воспроизводимых операций проекта.

## Принцип

Скрипты должны автоматизировать только те действия, которые уже описаны в проектной документации и не подменяют методологическое решение.
'@

Write-TextFile "scripts\powershell\README.md" @'
# PowerShell scripts

Планируемые скрипты:

- `Export-GitHubIssuesToCsv.ps1`
- `Build-MSProjectXml.ps1`
- `Build-MermaidGantt.ps1`
- `Check-ResourceOverload.ps1`
- `Build-AssignmentChecklist.ps1`
'@

Write-TextFile "models\uml\use-case.puml" @'
@startuml
left to right direction

actor "Руководитель проекта" as PM
actor "Бизнес-эксперт" as BE
actor "Data Scientist" as DS
actor "Пользователь системы" as User

rectangle "Система интеллектуального ценообразования" {
  usecase "Загрузить данные о продукции" as UC1
  usecase "Проверить качество данных" as UC2
  usecase "Рассчитать рекомендованную цену" as UC3
  usecase "Согласовать ценовую рекомендацию" as UC4
  usecase "Сформировать отчёт" as UC5
}

PM --> UC5
BE --> UC4
DS --> UC1
DS --> UC2
User --> UC3
User --> UC5
@enduml
'@

Write-TextFile "models\uml\sequence.puml" @'
@startuml
actor "Пользователь" as User
participant "Web/API интерфейс" as API
participant "Pricing Service" as Service
participant "ML-модель" as Model
database "Хранилище данных" as DB

User -> API: Запросить рекомендованную цену
API -> Service: Передать параметры продукта
Service -> DB: Получить данные о продукте и рынке
DB --> Service: Данные
Service -> Model: Рассчитать рекомендацию
Model --> Service: Рекомендованная цена
Service --> API: Результат расчёта
API --> User: Показать рекомендацию
@enduml
'@

Write-TextFile "models\uml\class-diagram.puml" @'
@startuml
class Product {
  +id: string
  +name: string
  +category: string
  +basePrice: decimal
}

class MarketSignal {
  +competitorPrice: decimal
  +demandIndex: decimal
  +seasonalityIndex: decimal
}

class PricingModel {
  +version: string
  +calculateRecommendation(product, signals): PriceRecommendation
}

class PriceRecommendation {
  +recommendedPrice: decimal
  +confidence: decimal
  +explanation: string
}

class ApprovalDecision {
  +status: string
  +comment: string
}

Product "1" --> "*" MarketSignal
PricingModel --> Product
PricingModel --> MarketSignal
PricingModel --> PriceRecommendation
PriceRecommendation --> ApprovalDecision
@enduml
'@

Write-TextFile "models\uml\activity.puml" @'
@startuml
start
:Получить данные о продукте;
:Получить рыночные данные;
:Проверить качество данных;

if (Данные пригодны?) then (да)
  :Рассчитать рекомендованную цену;
  :Сформировать объяснение рекомендации;
  :Передать на согласование;
  if (Цена согласована?) then (да)
    :Опубликовать ценовую рекомендацию;
  else (нет)
    :Отправить на корректировку;
  endif
else (нет)
  :Вернуть данные на очистку;
endif

stop
@enduml
'@

Write-TextFile "models\idef\README.md" @'
# IDEF models

Каталог предназначен для IDEF0 и IDEF3 моделей проекта.

## Планируемые файлы

- `idef0-context.drawio`
- `idef0-decomposition.drawio`
- `idef3-process.drawio`
'@

Write-TextFile "models\bpmn\README.md" @'
# BPMN models

Каталог предназначен для BPMN-процессов проекта.

## Планируемые процессы

1. Подготовка данных для интеллектуального ценообразования.
2. Внедрение модели расчёта рекомендованной цены.
3. Сравнение сценариев «КАК ЕСТЬ» и «КАК ДОЛЖНО БЫТЬ».
'@

$userName = Get-GitConfig "user.name"
$userEmail = Get-GitConfig "user.email"

if ([string]::IsNullOrWhiteSpace($userName)) {
    Write-Warn "git user.name не задан. Устанавливаю локально: Облов Андрей Андреевич"
    Invoke-Git -Arguments @("config", "user.name", "Облов Андрей Андреевич")
}

if ([string]::IsNullOrWhiteSpace($userEmail)) {
    throw @"
git user.email не задан.

Задайте email перед commit, например:
    git config --global user.email "ВАШ_EMAIL"

После этого повторите запуск скрипта.
"@
}

$originCheck = Invoke-GitOptional -Arguments @("remote", "get-url", "origin")
$originUrl = $originCheck.Output

if ($originCheck.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($originUrl)) {
    Write-Info "origin не задан. Добавляю origin: $RepoUrl"
    Invoke-Git -Arguments @("remote", "add", "origin", $RepoUrl)
}
elseif ($originUrl -ne $RepoUrl) {
    if ($Force) {
        Write-Warn "origin отличается от ожидаемого. Перезаписываю origin на $RepoUrl"
        Invoke-Git -Arguments @("remote", "set-url", "origin", $RepoUrl)
    }
    else {
        Write-Warn "origin уже задан и отличается от ожидаемого: $originUrl"
        Write-Warn "Ожидаемый origin: $RepoUrl"
        Write-Warn "Для принудительной замены используйте -Force."
    }
}
else {
    Write-Ok "origin настроен корректно: $RepoUrl"
}

Invoke-Git -Arguments @("add", "-A")

$statusCheck = Invoke-GitOptional -Arguments @("status", "--porcelain")
$status = $statusCheck.Output

if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Ok "Нет изменений для commit."
}
else {
    Write-Info "Формирую commit."
    Invoke-Git -Arguments @(
        "commit",
        "-m", "chore: initialize Git-based project workspace",
        "-m", "Add assignment map, repository structure, planning stubs, GitHub templates, CSV seeds and validation workflow."
    )
    Write-Ok "Commit создан."
}

if ($Push) {
    Write-Info "Выполняю push в origin/$DefaultBranch."
    Invoke-Git -Arguments @("push", "-u", "origin", $DefaultBranch)
    Write-Ok "Push выполнен."
}
else {
    Write-Warn "Push не выполнялся. Для отправки в GitHub запустите скрипт с ключом -Push."
}

Write-Ok "Стартовая инициализация проектной среды завершена."