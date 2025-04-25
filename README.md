# AQL to MongoDB Translator

This project is a program developed using **FLEX** and **YACC (Bison)** to translate AQL (Archetype Query Language) queries in openEHR format into MongoDB-compatible queries. The program includes a user interface (UI) developed in **Python**, which facilitates user interaction with the tool for executing AQL queries and viewing the resulting MongoDB queries.
<p align="center">
  <img src="https://github.com/user-attachments/assets/6055fef0-2166-4786-be68-9cd4ce32e40d" width="700"/>
</p>

## Features

- **AQL to MongoDB Translation**: The program parses AQL queries and generates corresponding MongoDB queries, supporting key AQL syntax such as `SELECT`, `FROM`, `WHERE`, `ORDER BY`, and `TIMEWINDOW`.
- **Python UI**: A simple and intuitive user interface to enter and submit AQL queries.
- **MongoDB Output**: Translated AQL queries are output as MongoDB-compatible code, including support for `.sort()` for `ORDER BY` clauses and filter handling for `TIMEWINDOW`.

## Installation

### Prerequisites

- **Flex** and **Bison**: Used for lexical analysis and parsing AQL queries.
- **Python 3.x**: For the user interface.

## Installation Steps

You can either use the one-click installation or follow the manual steps:

### Option 1: One-click Installation
Simply run the `run.bat` file to install and set up the environment automatically.

### Option 2: Manual Installation

1. **Clone the repository**:
```bash
git clone https://github.com/yourusername/aql-to-mongodb-translator.git
cd aql-to-mongodb-translator
```
2. **Install required Python packages:**
```bash
pip install -r requirements.txt
```
3. **Install Flex and Bison (Platform Specific)**
4. **Compile the FLEX and Bison files**
```bash
flex aql_lexer.l
bison -d aql_parser.y
gcc lex.yy.c aql_parser.tab.c -o aql_parser -lfl
```
5. **Run server.py and basic.html**


## Example Usage

### AQL Query Example

This is an example of an AQL query for fetching systolic and diastolic blood pressure values, along with the timestamp:

```sql
SELECT                                                       -- Select clause
   o/data[at0001]/.../items[at0004]/value AS systolic,       -- Identified path with alias
   o/data[at0001]/.../items[at0005]/value AS diastolic,
   c/context/start_time AS date_time
FROM                                                         -- From clause
   EHR[ehr_id/value=$ehrUid]                                 -- RM class expression
      CONTAINS                                               -- containment
         COMPOSITION c                                       -- RM class expression
            [openEHR-EHR-COMPOSITION.encounter.v1]           -- archetype predicate
         CONTAINS
            OBSERVATION o [openEHR-EHR-OBSERVATION.blood_pressure.v1]
WHERE                                                        -- Where clause
   o/data[at0001]/.../items[at0004]/value/value >= 140 OR    -- value comparison
   o/data[at0001]/.../items[at0005]/value/value >= 90
ORDER BY                                                     -- order by datetime, latest first
   c/context/start_time DESC
```
Equivalent MongoDB query:

```bash
b.ehr_data.find(
  {
    "ehr.ehr_id.value": ehrUid,
    "$or": [
      { "composition.observation.data.items.at0004.value.value": { "$gte": 140 } },
      { "composition.observation.data.items.at0005.value.value": { "$gte": 90 } }
    ],
    "composition.archetype_node_id": "openEHR-EHR-COMPOSITION.encounter.v1",
    "composition.observation.archetype_node_id": "openEHR-EHR-OBSERVATION.blood_pressure.v1"
  },
  {
    "composition.observation.data.items.at0004.value": 1,
    "composition.observation.data.items.at0005.value": 1,
    "composition.context.start_time": 1
  }
).sort({ "composition.context.start_time": -1 })
```
## Contributions
If you'd like to contribute to this project, feel free to fork the repository, make your changes, and create a pull request. We welcome improvements to the code and UI.
