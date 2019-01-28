// modelica.rl written by Martin Sjölund. martin.sjolund<att>liu<dott>se

/************************* Required for every parser *************************/
#ifndef OHCOUNT_MODELICA_PARSER_H
#define OHCOUNT_MODELICA_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *MODELICA_LANG = LANG_MODELICA;

// the languages entities
const char *modelica_entities[] = {
  "space", "comment", "string", "any"
};

// constants associated with the entities
enum {
  MODELICA_SPACE = 0, MODELICA_COMMENT, MODELICA_STRING, MODELICA_ANY
};

/*****************************************************************************/

%%{
  machine modelica;
  write data;
  include common "common.rl";

  # Line counting machine

  action modelica_ccallback {
    switch(entity) {
    case MODELICA_SPACE:
      ls
      break;
    case MODELICA_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(MODELICA_LANG)
      break;
    case NEWLINE:
      std_newline(MODELICA_LANG)
    }
  }

  modelica_line_comment = '//' @comment nonnewline*;

  modelica_block_comment =
    '/*' @comment (
      newline %{ entity = INTERNAL_NL; } %modelica_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '*/';

  modelica_comment = modelica_line_comment | modelica_block_comment;
  identifier = (alpha | '_') (alnum | '_')*;
  string = '\"' @code
    (newline %{ entity = INTERNAL_NL; } %modelica_ccallback
    |ws
    |[^ \t\n"\\] @code
    |'\\\"' @code
    )* '\"' @code;

  modelica_line := |*
    spaces       ${ entity = MODELICA_SPACE; } => modelica_ccallback;
    modelica_comment;
    newline      ${ entity = NEWLINE;   } => modelica_ccallback;
    identifier   ${ entity = MODELICA_ANY; } => modelica_ccallback;
    string       ${ entity = MODELICA_ANY; } => modelica_ccallback;
    ^space       ${ entity = MODELICA_ANY;   } => modelica_ccallback;
  *|;

  # Entity machine

  action modelica_ecallback {
    callback(MODELICA_LANG, modelica_entities[entity], cint(ts), cint(te), userdata);
  }

  modelica_eline_comment = '//' @comment nonnewline*;

  modelica_eblock_comment =
    '/*' @comment (
      newline %{ entity = INTERNAL_NL; } %modelica_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '*/';

  modelica_ecomment = modelica_line_comment | modelica_block_comment;

  modelica_entity := |*
    space+             ${ entity = MODELICA_SPACE;   } => modelica_ecallback;
    modelica_ecomment ${ entity = MODELICA_COMMENT; } => modelica_ecallback;
    identifier   ${ entity = MODELICA_ANY; } => modelica_ecallback;
    string       ${ entity = MODELICA_ANY; } => modelica_ecallback;
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with Modelica code.
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
void parse_modelica(char *buffer, int length, int count,
               void (*callback) (const char *lang, const char *entity, int s,
                                 int e, void *udata),
               void *userdata
  ) {
  init
  %% write init;
  cs = (count) ? modelica_en_modelica_line : modelica_en_modelica_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(MODELICA_LANG) }
}

#endif

/*****************************************************************************/
