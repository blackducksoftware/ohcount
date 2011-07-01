// golang.rl written by Scott Lawrence <bytbox@gmail.com>

/************************* Required for every parser *************************/
#ifndef OHCOUNT_GOLANG_PARSER_H
#define OHCOUNT_GOLANG_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *GOLANG_LANG = LANG_GOLANG;

// the languages entities
const char *golang_entities[] = {
  "space", "comment", "string", "number", "preproc",
  "keyword", "identifier", "operator", "any"
};

// constants associated with the entities
enum {
  GOLANG_SPACE = 0, GOLANG_COMMENT, GOLANG_STRING, GOLANG_NUMBER, GOLANG_PREPROC,
  GOLANG_KEYWORD, GOLANG_IDENTIFIER, GOLANG_OPERATOR, GOLANG_ANY
};

/*****************************************************************************/

%%{
  machine golang;
  write data;
  include common "common.rl";

  # Line counting machine

  action golang_ccallback {
    switch(entity) {
    case GOLANG_SPACE:
      ls
      break;
    case GOLANG_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(GOLANG_LANG)
      break;
    case NEWLINE:
      std_newline(GOLANG_LANG)
    }
  }

  golang_line_comment =
    '//' @comment (
      escaped_newline %{ entity = INTERNAL_NL; } %golang_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )*;
  golang_block_comment =
    '/*' @comment (
      newline %{ entity = INTERNAL_NL; } %golang_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '*/';
  golang_comment = golang_line_comment | golang_block_comment;

  golang_sq_str =
    '\'' @code (
      escaped_newline %{ entity = INTERNAL_NL; } %golang_ccallback
      |
      ws
      |
      [^\t '\\] @code
      |
      '\\' nonnewline @code
    )* '\'';
  golang_dq_str =
    '"' @code (
      escaped_newline %{ entity = INTERNAL_NL; } %golang_ccallback
      |
      ws
      |
      [^\t "\\] @code
      |
      '\\' nonnewline @code
    )* '"';
  golang_string = golang_sq_str | golang_dq_str;

  golang_line := |*
    spaces    ${ entity = GOLANG_SPACE; } => golang_ccallback;
    golang_comment;
    golang_string;
    newline   ${ entity = NEWLINE; } => golang_ccallback;
    ^space    ${ entity = GOLANG_ANY;   } => golang_ccallback;
  *|;

  # Entity machine

  action golang_ecallback {
    callback(GOLANG_LANG, golang_entities[entity], cint(ts), cint(te), userdata);
  }

  golang_line_comment_entity = '//' (escaped_newline | nonnewline)*;
  golang_block_comment_entity = '/*' any* :>> '*/';
  golang_comment_entity = golang_line_comment_entity | golang_block_comment_entity;

  golang_string_entity = sq_str_with_escapes | dq_str_with_escapes;

  golang_number_entity = float | integer;

  golang_preprogolang_word =
    'define' | 'elif' | 'else' | 'endif' | 'error' | 'if' | 'ifdef' |
    'ifndef' | 'import' | 'include' | 'line' | 'pragma' | 'undef' |
    'using' | 'warning';
  # TODO: find some way of making preproc match the beginning of a line.
  # Putting a 'when starts_line' conditional throws an assertion error.
  golang_preprogolang_entity =
    '#' space* (golang_block_comment_entity space*)?
      golang_preprogolang_word (escaped_newline | nonnewline)*;

  golang_identifier_entity = (alpha | '_') (alnum | '_')*;

  golang_keyword_entity =
    'and' | 'and_eq' | 'asm' | 'auto' | 'bitand' | 'bitor' | 'bool' |
    'break' | 'case' | 'catch' | 'char' | 'class' | 'compl' | 'const' |
    'const_cast' | 'continue' | 'default' | 'delete' | 'do' | 'double' |
    'dynamigolang_cast' | 'else' | 'enum' | 'explicit' | 'export' | 'extern' |
    'false' | 'float' | 'for' | 'friend' | 'goto' | 'if' | 'inline' | 'int' |
    'long' | 'mutable' | 'namespace' | 'new' | 'not' | 'not_eq' |
    'operator' | 'or' | 'or_eq' | 'private' | 'protected' | 'public' |
    'register' | 'reinterpret_cast' | 'return' | 'short' | 'signed' |
    'sizeof' | 'static' | 'statigolang_cast' | 'struct' | 'switch' |
    'template' | 'this' | 'throw' | 'true' | 'try' | 'typedef' | 'typeid' |
    'typename' | 'union' | 'unsigned' | 'using' | 'virtual' | 'void' |
    'volatile' | 'wchar_t' | 'while' | 'xor' | 'xor_eq';

  golang_operator_entity = [+\-/*%<>!=^&|?~:;.,()\[\]{}];

  golang_entity := |*
    space+              ${ entity = GOLANG_SPACE;      } => golang_ecallback;
    golang_comment_entity    ${ entity = GOLANG_COMMENT;    } => golang_ecallback;
    golang_string_entity     ${ entity = GOLANG_STRING;     } => golang_ecallback;
    golang_number_entity     ${ entity = GOLANG_NUMBER;     } => golang_ecallback;
    golang_preprogolang_entity    ${ entity = GOLANG_PREPROC;    } => golang_ecallback;
    golang_identifier_entity ${ entity = GOLANG_IDENTIFIER; } => golang_ecallback;
    golang_keyword_entity    ${ entity = GOLANG_KEYWORD;    } => golang_ecallback;
    golang_operator_entity   ${ entity = GOLANG_OPERATOR;   } => golang_ecallback;
    ^(space | digit)    ${ entity = GOLANG_ANY;        } => golang_ecallback;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with C/C++ code.
 *
 * @param *buffer The string to parse.
 * @param length The length of the string to parse.
 * @param count Integer flag specifying whether or not to count lines. If yes,
 *   uses the Ragel machine optimized for counting. Otherwise uses the Ragel
 *   machine optimized for returning entity positions.
 * @param *callback Callback function. If count is set, callback is called for
 *   every line of code, comment, or blank with 'lcode', 'lcomment', and
 *   'lblank' respectively. Otherwise callback is called for each entity found.
 */
void parse_golang(char *buffer, int length, int count,
             void (*callback) (const char *lang, const char *entity, int s,
                               int e, void *udata),
             void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? golang_en_golang_line : golang_en_golang_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(GOLANG_LANG) }
}

const char *ORIG_GOLANG_LANG = LANG_GOLANG;

#endif

/*****************************************************************************/
