/************************* Required for every parser *************************/
#ifndef OHCOUNT_COQ_PARSER_H
#define OHCOUNT_COQ_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *COQ_LANG = LANG_COQ;

// the languages entities
const char *coq_entities[] = {
  "space", "comment", "string", "any"
};

// constants associated with the entities
enum {
  COQ_SPACE = 0, COQ_COMMENT, COQ_STRING, COQ_ANY
};

/*****************************************************************************/

%%{
  machine coq;
  write data;
  include common "common.rl";

  # Line counting machine

  action coq_ccallback {
    switch(entity) {
    case COQ_SPACE:
      ls
      break;
    case COQ_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(COQ_LANG)
      break;
    case NEWLINE:
      std_newline(COQ_LANG)
    }
  }

  action coq_comment_nc_res { nest_count = 0; }
  action coq_comment_nc_inc { nest_count++; }
  action coq_comment_nc_dec { nest_count--; }

  coq_nested_block_comment =
    '(*' >coq_comment_nc_res @comment (
      newline %{ entity = INTERNAL_NL; } %coq_ccallback
      |
      ws
      |
      '(*' @coq_comment_nc_inc @comment
      |
      '*)' @coq_comment_nc_dec @comment
      |
      (nonnewline - ws) @comment
    )* :>> ('*)' when { nest_count == 0 }) @comment;

  coq_comment = coq_nested_block_comment;

  coq_string =
    '"' @code (
      newline %{ entity = INTERNAL_NL; } %coq_ccallback
      |
      ws
      |
      [^"] @code
    )* '"';

  coq_line := |*
    spaces          ${ entity = COQ_SPACE; } => coq_ccallback;
    coq_comment;
    coq_string;
    newline         ${ entity = NEWLINE;   } => coq_ccallback;
    ^space          ${ entity = COQ_ANY;   } => coq_ccallback;
  *|;

  # Entity machine

  action coq_ecallback {
    callback(COQ_LANG, coq_entities[entity], cint(ts), cint(te), userdata);
  }

  coq_comment_entity = '(*' >coq_comment_nc_res (
    '(*' @coq_comment_nc_inc
    |
    '*)' @coq_comment_nc_dec
    |
    any
  )* :>> ('*)' when { nest_count == 0 });

  coq_entity := |*
    space+             ${ entity = COQ_SPACE;   } => coq_ecallback;
    coq_comment_entity ${ entity = COQ_COMMENT; } => coq_ecallback;
    # TODO:
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with Coq code.
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
void parse_coq(char *buffer, int length, int count,
               void (*callback) (const char *lang, const char *entity, int s,
                                 int e, void *udata),
               void *userdata
  ) {
  init

  int nest_count = 0;

  %% write init;
  cs = (count) ? coq_en_coq_line : coq_en_coq_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(COQ_LANG) }
}

#endif

/*****************************************************************************/
