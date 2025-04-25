%{
#include "aql.tab.h"
#include <string.h>
%}

%%

"SELECT"              { return SELECT; }
"FROM"                { return FROM; }
"WHERE"               { return WHERE; }
"CONTAINS"            { return CONTAINS; }
"AS"                  { return AS; }
"="                   { return EQUALS; }
"AND"                 { return AND; }
"ORDER"               { return ORDER; }
"BY"                  { return BY; }
"TIMEWINDOW"          { return TIMEWINDOW; }

"["                   { return LBRACKET; }
"]"                   { return RBRACKET; }
"/"                   { return SLASH; }
","                   { return COMMA; }

\'[^\']*\'            { yylval.str = strdup(yytext); return STRING; }

[a-zA-Z_][a-zA-Z0-9_/.\[\]@]*   { yylval.str = strdup(yytext); return IDENTIFIER; }

[ \t\r\n]+            /* skip whitespace */
.                     { /* skip unknown */ }

%%

int yywrap(void) {
    return 1;
}
