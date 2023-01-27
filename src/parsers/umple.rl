// umple.rl written by Mitchell Foral. mitchell<att>caladbolg<dott>net.

/************************* Required for every parser *************************/
#ifndef OHCOUNT_UMPLE_PARSER_H
#define OHCOUNT_UMPLE_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *UMPLE_LANG = LANG_UMPLE;

// the languages entities
const char *umple_entities[] = {
  "space", "comment", "string", "number",
  "keyword", "identifier", "operator", "any"
};

// constants associated with the entities
enum {
  UMPLE_SPACE = 0, UMPLE_COMMENT, UMPLE_STRING, UMPLE_NUMBER,
  UMPLE_KEYWORD, UMPLE_IDENTIFIER, UMPLE_OPERATOR, UMPLE_ANY
};

/*****************************************************************************/

%%{
  machine umple;
  write data;
  include common "common.rl";

  # Line counting machine

  action umple_ccallback {
    switch(entity) {
    case UMPLE_SPACE:
      ls
      break;
    case UMPLE_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(UMPLE_LANG)
      break;
    case NEWLINE:
      std_newline(UMPLE_LANG)
    }
  }

  umple_line_comment = '//' @comment nonnewline*;
  umple_block_comment =
    '/*' @comment (
      newline %{ entity = INTERNAL_NL; } %umple_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '*/';
  umple_comment = umple_line_comment | umple_block_comment;

  umple_sq_str = '\'' @code ([^\r\n\f'\\] | '\\' nonnewline)* '\'';
  umple_dq_str = '"' @code ([^\r\n\f"\\] | '\\' nonnewline)* '"';
  umple_string = umple_sq_str | umple_dq_str;

  umple_line := |*
    spaces        ${ entity = UMPLE_SPACE; } => umple_ccallback;
    umple_comment;
    umple_string;
    newline       ${ entity = NEWLINE;    } => umple_ccallback;
    ^space        ${ entity = UMPLE_ANY;   } => umple_ccallback;
  *|;

  # Entity machine

  action umple_ecallback {
    callback(UMPLE_LANG, umple_entities[entity], cint(ts), cint(te), userdata);
  }

  umple_line_comment_entity = '//' nonnewline*;
  umple_block_comment_entity = '/*' any* :>> '*/';
  umple_comment_entity = umple_line_comment_entity | umple_block_comment_entity;

  umple_entity := |*
    space+              ${ entity = UMPLE_SPACE;   } => umple_ecallback;
    umple_comment_entity ${ entity = UMPLE_COMMENT; } => umple_ecallback;
    # TODO:
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with umple code.
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
void parse_umple(char *buffer, int length, int count,
                void (*callback) (const char *lang, const char *entity, int s,
                                  int e, void *udata),
                void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? umple_en_umple_line : umple_en_umple_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(UMPLE_LANG) }
}

#endif

/*****************************************************************************/
