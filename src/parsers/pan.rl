// pan.rl written by James Adams. james<dott>adams<att>stfc<dott>ac<dott>uk
// based on shell.rl written by Mitchell Foral. mitchell<att>caladbolg<dott>net

/************************* Required for every parser *************************/
#ifndef OHCOUNT_PAN_PARSER_H
#define OHCOUNT_PAN_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *PAN_LANG = LANG_PAN;

// the languages entities
const char *pan_entities[] = {
  "space", "comment", "string", "any"
};

// constants associated with the entities
enum {
  PAN_SPACE = 0, PAN_COMMENT, PAN_STRING, PAN_ANY
};

/*****************************************************************************/

%%{
  machine pan;
  write data;
  include common "common.rl";

  # Line counting machine

  action pan_ccallback {
    switch(entity) {
    case PAN_SPACE:
      ls
      break;
    case PAN_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(PAN_LANG)
      break;
    case NEWLINE:
      std_newline(PAN_LANG)
    }
  }

  pan_comment = '#' @comment nonnewline*;

  pan_sq_str =
    '\'' @enqueue @code (
      newline %{ entity = INTERNAL_NL; } %pan_ccallback
      |
      ws
      |
      [^\r\n\f\t '\\] @code
      |
      '\\' nonnewline @code
    )* '\'' @commit;
  pan_dq_str =
    '"' @enqueue @code (
      newline %{ entity = INTERNAL_NL; } %pan_ccallback
      |
      ws
      |
      [^\r\n\f\t "\\] @code
      |
      '\\' nonnewline @code
    )* '"' @commit;
  # TODO: heredocs; see ruby.rl for details
  pan_string = pan_sq_str | pan_dq_str;

  pan_line := |*
    spaces         ${ entity = PAN_SPACE; } => pan_ccallback;
    pan_comment;
    pan_string;
    newline        ${ entity = NEWLINE;     } => pan_ccallback;
    ^space         ${ entity = PAN_ANY;   } => pan_ccallback;
  *|;

  # Entity machine

  action pan_ecallback {
    callback(PAN_LANG, pan_entities[entity], cint(ts), cint(te), userdata);
  }

  pan_comment_entity = '#' nonnewline*;

  pan_entity := |*
    space+               ${ entity = PAN_SPACE;   } => pan_ecallback;
    pan_comment_entity ${ entity = PAN_COMMENT; } => pan_ecallback;
    # TODO:
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with Pan code.
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
void parse_pan(char *buffer, int length, int count,
                 void (*callback) (const char *lang, const char *entity, int s,
                                   int e, void *udata),
                 void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? pan_en_pan_line : pan_en_pan_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(PAN_LANG) }
}

#endif

/*****************************************************************************/
