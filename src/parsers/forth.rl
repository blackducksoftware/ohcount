// forth.rl 
// derived from code written by Mitchell Foral. mitchell<att>caladbolg<dott>net.

/************************* Required for every parser *************************/
#ifndef OHCOUNT_FORTH_PARSER_H
#define OHCOUNT_FORTH_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *FORTH_LANG = LANG_FORTH;

// the languages entities
const char *forth_entities[] = {
  "space", "comment", "string", "any",
};

// constants associated with the entities
enum {
  FORTH_SPACE = 0, FORTH_COMMENT, FORTH_STRING, FORTH_ANY
};

/*****************************************************************************/

%%{
  machine forth;
  write data;
  include common "common.rl";

  # Line counting machine

  action forth_ccallback {
    switch(entity) {
    case FORTH_SPACE:
      ls
      break;
    case FORTH_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(FORTH_LANG)
      break;
    case NEWLINE:
      std_newline(FORTH_LANG)
    }
  }

  forth_line_comment = '\\' @comment nonnewline*;
  forth_block_comment =
    '(' @comment (
      newline %{ entity = INTERNAL_NL; } %forth_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> ')';
  forth_comment = forth_line_comment | forth_block_comment;

  forth_string = '"' @code ([^\r\n\f"])* '"';

  forth_line := |*
    spaces         ${ entity = FORTH_SPACE; } => forth_ccallback;
    forth_comment;
    forth_string;
    newline        ${ entity = NEWLINE;     } => forth_ccallback;
    ^space         ${ entity = FORTH_ANY;   } => forth_ccallback;
  *|;

  # Entity machine

  action forth_ecallback {
    callback(FORTH_LANG, forth_entities[entity], cint(ts), cint(te), userdata);
  }

  forth_line_comment_entity = '\\' nonnewline*;
  forth_block_comment_entity = '(' any* :>> ')';
  forth_comment_entity = forth_line_comment_entity | forth_block_comment_entity;

  forth_entity := |*
    space+               ${ entity = FORTH_SPACE;   } => forth_ecallback;
    forth_comment_entity ${ entity = FORTH_COMMENT; } => forth_ecallback;
    # TODO:
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with Forth code.
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
void parse_forth(char *buffer, int length, int count,
                 void (*callback) (const char *lang, const char *entity, int s,
                                   int e, void *udata),
                 void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? forth_en_forth_line : forth_en_forth_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(FORTH_LANG) }
}

#endif

/*****************************************************************************/
