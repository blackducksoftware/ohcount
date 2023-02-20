// elm.rl written by Mitchell Foral. mitchell<att>caladbolg<dott>net

/************************* Required for every parser *************************/
#ifndef OHCOUNT_ELM_PARSER_H
#define OHCOUNT_ELM_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *ELM_LANG = LANG_ELM;

// the languages entities
const char *elm_entities[] = {
  "space", "comment", "string", "any"
};

// constants associated with the entities
enum {
  ELM_SPACE = 0, ELM_COMMENT, ELM_STRING, ELM_ANY
};

/*****************************************************************************/

%%{
  machine elm;
  write data;
  include common "common.rl";

  # Line counting machine

  action elm_ccallback {
    switch(entity) {
    case ELM_SPACE:
      ls
      break;
    case ELM_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(ELM_LANG)
      break;
    case NEWLINE:
      std_newline(ELM_LANG)
    }
  }

  action elm_comment_nc_res { nest_count = 0; }
  action elm_comment_nc_inc { nest_count++; }
  action elm_comment_nc_dec { nest_count--; }

  # TODO: |-- is not a comment
  elm_line_comment = '--' [^>] @{ fhold; } @comment nonnewline*;
  elm_nested_block_comment =
    '{-' >elm_comment_nc_res @comment (
      newline %{ entity = INTERNAL_NL; } %elm_ccallback
      |
      ws
			|
			'{-' @elm_comment_nc_inc @comment
			|
			'-}' @elm_comment_nc_dec @comment
      |
      (nonnewline - ws) @comment
    )* :>> ('-}' when { nest_count == 0 }) @comment;
  elm_comment = elm_line_comment | elm_nested_block_comment;

  elm_char = '\'' @code ([^\r\n\f'\\] | '\\' nonnewline) '\'';
  elm_dq_str =
    '"' @code (
      escaped_newline %{ entity = INTERNAL_NL; } %elm_ccallback
      |
      ws
      |
      [^\t "\\] @code
      |
      '\\' nonnewline @code
    )* '"';
  elm_string = elm_char | elm_dq_str;

  elm_line := |*
    spaces           ${ entity = ELM_SPACE; } => elm_ccallback;
    elm_comment;
    elm_string;
    newline          ${ entity = NEWLINE;       } => elm_ccallback;
    ^space           ${ entity = ELM_ANY;   } => elm_ccallback;
  *|;

  # Entity machine

  action elm_ecallback {
    callback(ELM_LANG, elm_entities[entity], cint(ts), cint(te),
             userdata);
  }

  elm_line_comment_entity = '--' [^>] @{ fhold; } nonnewline*;
  elm_block_comment_entity = '{-' >elm_comment_nc_res (
    '{-' @elm_comment_nc_inc
    |
    '-}' @elm_comment_nc_dec
    |
    any
  )* :>> ('-}' when { nest_count == 0 });
  elm_comment_entity =
    elm_line_comment_entity | elm_block_comment_entity;

  elm_entity := |*
    space+                 ${ entity = ELM_SPACE;   } => elm_ecallback;
    elm_comment_entity ${ entity = ELM_COMMENT; } => elm_ecallback;
    # TODO:
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with elm code.
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
void parse_elm(char *buffer, int length, int count,
                   void (*callback) (const char *lang, const char *entity,
                                     int s, int e, void *udata),
                   void *userdata
  ) {
  init

  int nest_count = 0;

  %% write init;
  cs = (count) ? elm_en_elm_line : elm_en_elm_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(ELM_LANG) }
}

#endif

/*****************************************************************************/
