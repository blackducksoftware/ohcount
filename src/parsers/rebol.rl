// rebol.rl written by Andreas Bolka.

/************************* Required for every parser *************************/
#ifndef OHCOUNT_REBOL_PARSER_H
#define OHCOUNT_REBOL_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *REBOL_LANG = LANG_REBOL;

// the languages entities
const char *rebol_entities[] = {
  "space", "comment", "string", "any"
};

// constants associated with the entities
enum {
  REBOL_SPACE = 0, REBOL_COMMENT, REBOL_STRING, REBOL_ANY
};

/*****************************************************************************/

%%{
  machine rebol;
  write data;
  include common "common.rl";

  action rebol_inc_string { ++rebol_string_level; }
  action rebol_dec_string { --rebol_string_level; }
  action rebol_is_nested { rebol_string_level > 0 }

  rebol_cb_str_nest = '{'                       %rebol_inc_string
                    | '}' when rebol_is_nested  %rebol_dec_string;

  # Line counting machine

  action rebol_ccallback {
    switch(entity) {
    case REBOL_SPACE:
      ls
      break;
    case REBOL_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(REBOL_LANG)
      break;
    case NEWLINE:
      std_newline(REBOL_LANG)
    }
  }

  rebol_line_comment = ';' @comment nonnewline*;
  rebol_comment = rebol_line_comment;

  rebol_dq_str = '"' @code ([^\r\n\f"] | '^"')* [\r\n\f"];
  rebol_cb_str_inner = [^{}] | '^{' | '^}'
                     | newline %{ entity = INTERNAL_NL; } %rebol_ccallback
                     | rebol_cb_str_nest;
  rebol_cb_str = '{' @code rebol_cb_str_inner* @code '}' @code;
  rebol_string = rebol_dq_str | rebol_cb_str;

  rebol_line := |*
    spaces                  ${ entity = REBOL_SPACE; }      => rebol_ccallback;
    rebol_comment;
    rebol_string;
    newline                 ${ entity = NEWLINE; }          => rebol_ccallback;
    ^space                  ${ entity = REBOL_ANY; }        => rebol_ccallback;
  *|;

  # Entity machine

  action rebol_ecallback {
    callback(REBOL_LANG, rebol_entities[entity], cint(ts), cint(te), userdata);
  }

  rebol_line_comment_entity = ';' nonnewline*;
  rebol_comment_entity = rebol_line_comment_entity;

  rebol_dq_str_entity = '"' ([^\r\n\f"] | '^"')* [\r\n\f"];
  rebol_cb_str_entity = '{' ([^{}] | '^{' | '^}' | rebol_cb_str_nest)* '}';
  rebol_string_entiy = rebol_dq_str_entity | rebol_cb_str_entity;

  rebol_entity := |*
    space+                  ${ entity = REBOL_SPACE; }      => rebol_ecallback;
    rebol_comment_entity    ${ entity = REBOL_COMMENT; }    => rebol_ecallback;
    rebol_string_entiy      ${ entity = REBOL_STRING; }     => rebol_ecallback;
    ^space                  ${ entity = REBOL_ANY; }        => rebol_ecallback;
  *|;

}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with REBOL code.
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
void parse_rebol(char *buffer, int length, int count,
                 void (*callback) (const char *lang, const char *entity, int s,
                                   int e, void *udata),
                 void *userdata
  ) {
  // For {..} multi-line strings which require proper balancing of {}'s.
  int rebol_string_level = 0;
  init

  %% write init;
  cs = (count) ? rebol_en_rebol_line : rebol_en_rebol_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(REBOL_LANG) }
}

#endif

/*****************************************************************************/

// vim: set ts=2 syn=c:
