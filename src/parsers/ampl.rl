// ampl.rl written by Victor Zverovich. victor.zverovich@gmail.com

/************************* Required for every parser *************************/
#ifndef OHCOUNT_AMPL_PARSER_H
#define OHCOUNT_AMPL_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *AMPL_LANG = LANG_AMPL;

// the languages entities
const char *ampl_entities[] = {
  "space", "comment", "any"
};

// constants associated with the entities
enum {
  AMPL_SPACE = 0, AMPL_COMMENT, AMPL_ANY
};

/*****************************************************************************/

%%{
  machine ampl;
  write data;
  include common "common.rl";

  # Line counting machine

  action ampl_ccallback {
    switch(entity) {
    case AMPL_SPACE:
      ls
      break;
    case AMPL_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(AMPL_LANG)
      break;
    case NEWLINE:
      std_newline(AMPL_LANG)
    }
  }

  ampl_comment = '#' @comment nonnewline*;

  ampl_line := |*
    spaces       ${ entity = AMPL_SPACE; } => ampl_ccallback;
    ampl_comment;
    newline      ${ entity = NEWLINE;    } => ampl_ccallback;
    ^space       ${ entity = AMPL_ANY;   } => ampl_ccallback;
  *|;

  # Entity machine

  action ampl_ecallback {
    callback(AMPL_LANG, ampl_entities[entity], cint(ts), cint(te), userdata);
  }

  ampl_comment_entity = '#' nonnewline*;

  ampl_entity := |*
    space+              ${ entity = AMPL_SPACE;   } => ampl_ecallback;
    ampl_comment_entity ${ entity = AMPL_COMMENT; } => ampl_ecallback;
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with AMPL code.
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
void parse_ampl(char *buffer, int length, int count,
               void (*callback) (const char *lang, const char *entity, int s,
                                 int e, void *udata),
               void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? ampl_en_ampl_line : ampl_en_ampl_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(AMPL_LANG) }
}

#endif

/*****************************************************************************/
