/************************* Required for every parser *************************/
#ifndef OHCOUNT_JULIA_PARSER_H
#define OHCOUNT_JULIA_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *JULIA_LANG = LANG_JULIA;

// the languages entities
const char *julia_entities[] = {
  "space", "comment", "string", "any"
};

// constants associated with the entities
enum {
  JULIA_SPACE = 0, JULIA_COMMENT, JULIA_STRING, JULIA_ANY
};

/*****************************************************************************/

%%{
  machine julia;
  write data;
  include common "common.rl";

  # Line counting machine

  action julia_ccallback {
    switch(entity) {
    case JULIA_SPACE:
      ls
      break;
    case JULIA_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(JULIA_LANG)
      break;
    case NEWLINE:
      std_newline(JULIA_LANG)
    }
  }

  julia_line_comment = '#' @comment nonnewline*;
  julia_block_comment =
    '#=' @comment (
      newline %{ entity = INTERNAL_NL; } %julia_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '=#';
  julia_sq_doc_str =
    '\'\'\'' @comment (
      newline %{ entity = INTERNAL_NL; } %julia_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '\'\'\'' @comment;
  julia_dq_doc_str =
    '"""' @comment (
      newline %{ entity = INTERNAL_NL; } %julia_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '"""' @comment;
  julia_comment = julia_line_comment | julia_block_comment |
                   julia_sq_doc_str | julia_dq_doc_str;

  # make sure it's not ''' or """
  julia_sq_str =
    '\'' ([^'] | '\'' [^'] @{ fhold; }) @{ fhold; }
      ([^\r\n\f'\\] | '\\' nonnewline)* '\'';
  julia_dq_str =
    '"' ([^"] | '"' [^"] @{ fhold; }) @{ fhold; }
      ([^\r\n\f"\\] | '\\' nonnewline)* '"';
  julia_string = (julia_sq_str | julia_dq_str) @code;

  julia_line := |*
    spaces          ${ entity = JULIA_SPACE; } => julia_ccallback;
    julia_comment;
    julia_string;
    newline         ${ entity = NEWLINE;     } => julia_ccallback;
    ^space          ${ entity = JULIA_ANY;   } => julia_ccallback;
  *|;

  # Entity machine

  action julia_ecallback {
    callback(JULIA_LANG, julia_entities[entity], cint(ts), cint(te), userdata);
  }

  julia_line_comment_entity = '#' nonnewline*;
  julia_block_comment_entity = '#=' any* :>> '=#';
  julia_sq_doc_str_entity = '\'\'\'' any* :>> '\'\'\'';
  julia_dq_doc_str_entity = '"""' any* :>> '"""';
  julia_comment_entity = julia_line_comment_entity | julia_block_comment_entity |
                           julia_sq_doc_str_entity | julia_dq_doc_str_entity;

  julia_entity := |*
    space+               ${ entity = JULIA_SPACE;   } => julia_ecallback;
    julia_comment_entity ${ entity = JULIA_COMMENT; } => julia_ecallback;
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with julia code.
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
void parse_julia(char *buffer, int length, int count,
                  void (*callback) (const char *lang, const char *entity, int s,
                                    int e, void *udata),
                  void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? julia_en_julia_line : julia_en_julia_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(JULIA_LANG) }
}

#endif

/*****************************************************************************/
