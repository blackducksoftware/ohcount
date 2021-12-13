// elixir.rl written by Mitchell Foral. mitchell<att>caladbolg<dott>net

/************************* Required for every parser *************************/
#ifndef OHCOUNT_ELIXIR_PARSER_H
#define OHCOUNT_ELIXIR_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *ELIXIR_LANG = LANG_ELIXIR;

// the languages entities
const char *elixir_entities[] = {
  "space", "comment", "string", "any"
};

// constants associated with the entities
enum {
  ELIXIR_SPACE = 0, ELIXIR_COMMENT, ELIXIR_STRING, ELIXIR_ANY
};

/*****************************************************************************/

%%{
  machine elixir;
  write data;
  include common "common.rl";

  # Line counting machine

  action elixir_ccallback {
    switch(entity) {
    case ELIXIR_SPACE:
      ls
      break;
    case ELIXIR_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(ELIXIR_LANG)
      break;
    case NEWLINE:
      std_newline(ELIXIR_LANG)
    }
  }

  elixir_line_comment = '#' @comment nonnewline*;
  elixir_dq_doc_str =
    '"""' @comment (
      newline %{ entity = INTERNAL_NL; } %elixir_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '"""' @comment;
  elixir_comment = elixir_line_comment | elixir_dq_doc_str;

  elixir_sq_str =
    '\'' @enqueue @code (
      newline %{ entity = INTERNAL_NL; } %elixir_ccallback
      |
      ws
      |
      [^\r\n\f\t '\\] @code
      |
      '\\' nonnewline @code
    )* '\'' @commit @code;
  elixir_dq_str =
    '"' @enqueue @code (
      newline %{ entity = INTERNAL_NL; } %elixir_ccallback
      |
      ws
      |
      [^\r\n\f\t "\\] @code
      |
      '\\' nonnewline @code
    )* '"' @commit @code;
  # TODO: true literal string detection
  # Turns out any non-alphanum char can be after the initial '%' for a literal
  # string. I only have '(', '[', '{' for now because they are common(?). Their
  # respective closing characters need to be escaped though, which is not
  # accurate; only the single closing character needs to be escaped in a literal
  # string.
  # We need to detect which non-alphanum char opens a literal string, somehow
  # let Ragel know what it is (currently unsupported), and put its respective
  # closing char in the literal string below.
  elixir_lit_str =
    '%' [qQ]? [(\[{] @enqueue @code (
      newline %{ entity = INTERNAL_NL; } %elixir_ccallback
      |
      ws
      |
      [^\r\n\f\t )\]}\\] @code
      |
      '\\' nonnewline @code
    )* [)\]}] @commit @code;
  elixir_cmd_str =
    '`' @enqueue @code (
      newline %{ entity = INTERNAL_NL; } %elixir_ccallback
      |
      ws
      |
      [^\r\n\f\t `\\] @code
      |
      '\\' nonnewline @code
    )* '`' @commit @code;
  elixir_regex = '/' ([^\r\n\f/\\] | '\\' nonnewline)* '/' @code;
  # TODO: true literal array and command detection
  # See TODO above about literal string detection
  elixir_lit_other =
    '%' [wrx] [(\[{] @enqueue @code (
      newline %{ entity = INTERNAL_NL; } %elixir_ccallback
      |
      ws
      |
      [^\r\n\f\t )\]}\\] @code
      |
      '\\' nonnewline @code
    )* [)\]}] @commit @code;
  # TODO: heredoc detection
  # This is impossible with current Ragel. We need to extract what the end
  # delimiter should be from the heredoc and search up to it on a new line.
  # elixir_heredoc =
  elixir_string =
    elixir_sq_str | elixir_dq_str | elixir_lit_str | elixir_cmd_str | elixir_regex |
    elixir_lit_other;

  elixir_line := |*
    spaces        ${ entity = ELIXIR_SPACE; } => elixir_ccallback;
    elixir_comment;
    elixir_string;
    newline       ${ entity = NEWLINE;    } => elixir_ccallback;
    ^space        ${ entity = ELIXIR_ANY;   } => elixir_ccallback;
  *|;

  # Entity machine

  action elixir_ecallback {
    callback(ELIXIR_LANG, elixir_entities[entity], cint(ts), cint(te), userdata);
  }

  elixir_line_comment_entity = '#' nonnewline*;
  elixir_dq_doc_str_entity = '"""' any* :>> '"""';
  elixir_comment_entity = elixir_line_comment_entity | elixir_dq_doc_str_entity;

  elixir_entity := |*
    space+              ${ entity = ELIXIR_SPACE;   } => elixir_ecallback;
    elixir_comment_entity ${ entity = ELIXIR_COMMENT; } => elixir_ecallback;
    # TODO:
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with elixir code.
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
void parse_elixir(char *buffer, int length, int count,
                void (*callback) (const char *lang, const char *entity, int s,
                                  int e, void *udata),
                void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? elixir_en_elixir_line : elixir_en_elixir_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(ELIXIR_LANG) }
}

#endif

/*****************************************************************************/
