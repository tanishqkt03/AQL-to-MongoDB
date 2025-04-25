%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);

typedef struct {
    char* path;
    char* alias;
} SelectField;

typedef struct {
    char* path;
    char* value;
} Condition;

typedef struct {
    char* field;
    char* direction;
} OrderField;

SelectField select_fields[50];
Condition where_conditions[50];
OrderField order_fields[10];
int select_count = 0;
int where_count = 0;
int order_count = 0;
char* timewindow_start = NULL;
char* timewindow_end = NULL;
%}

%union {
    char* str;
}

%token <str> IDENTIFIER STRING
%token SELECT FROM WHERE CONTAINS AS EQUALS AND ORDER BY TIMEWINDOW
%token LBRACKET RBRACKET SLASH COMMA

%%

query:
    SELECT select_list FROM from_clause WHERE condition_list optional_order optional_timewindow {
        printf("db.ehr.find(\n");

        // WHERE clause
        printf("  { ");
        for (int i = 0; i < where_count; ++i) {
            printf("\"%s\": %s", where_conditions[i].path, where_conditions[i].value);
            if (i < where_count - 1 || timewindow_start) printf(", ");
        }
        if (timewindow_start) {
            printf("\"/context/start_time\": { \"$gte\": \"%s\", \"$lte\": \"%s\" }", timewindow_start, timewindow_end);
        }
        printf(" },\n");

        // Projection
        printf("  { ");
        for (int i = 0; i < select_count; ++i) {
            printf("\"%s\": 1", select_fields[i].path);
            if (i < select_count - 1) printf(", ");
        }
        printf(" }\n");

        printf(")");

        // ORDER BY
        if (order_count > 0) {
            printf(".sort({ ");
            for (int i = 0; i < order_count; ++i) {
                printf("\"%s\": \"%s\"", order_fields[i].field, order_fields[i].direction);
                if (i < order_count - 1) printf(", ");
            }
            printf(" })");
        }

        printf(";\n");
    }
;

select_list:
    select_item
    | select_list COMMA select_item
;

select_item:
    IDENTIFIER {
        select_fields[select_count++] = (SelectField){ $1, NULL };
    }
    | IDENTIFIER AS IDENTIFIER {
        select_fields[select_count++] = (SelectField){ $1, $3 };
    }
;

from_clause:
    IDENTIFIER IDENTIFIER CONTAINS IDENTIFIER IDENTIFIER
;

condition_list:
    condition
    | condition_list AND condition
;

condition:
    IDENTIFIER EQUALS STRING {
        where_conditions[where_count++] = (Condition){ $1, $3 };
    }
;

optional_order:
    /* empty */
    | ORDER BY IDENTIFIER {
        order_fields[order_count++] = (OrderField){ $3, "asc" };
    }
;

optional_timewindow:
    /* empty */
    | TIMEWINDOW STRING COMMA STRING {
        timewindow_start = $2;
        timewindow_end = $4;
    }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}


extern FILE *yyin;

int main() {
    yyin = fopen("input.aql", "r");
    if (!yyin) {
        perror("Failed to open input.aql");
        return 1;
    }
    yyparse();
    fclose(yyin);
    return 0;
}

