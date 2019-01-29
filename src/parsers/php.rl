// php.rl written by Mitchell Foral. mitchell<att>caladbolg<dott>net.

/************************* Required for every parser *************************/
#ifndef OHCOUNT_PHP_PARSER_H
#define OHCOUNT_PHP_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *PHP_LANG = LANG_PHP;

// the languages entities
const char *php_entities[] = {
  "space", "comment", "string", "any"
};

// constants associated with the entities
enum {
  PHP_SPACE = 0, PHP_COMMENT, PHP_STRING, PHP_ANY
};

/*****************************************************************************/

%%{
  machine php;
  write data;
  include common "common.rl";

  # Line counting machine

  action php_ccallback {
    switch(entity) {
    case PHP_SPACE:
      ls
      break;
    case PHP_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(PHP_LANG)
      break;
    case NEWLINE:
      std_newline(PHP_LANG)
      break;
    case CHECK_BLANK_ENTRY:
      check_blank_entry(PHP_LANG)
      break;
    }
  }

  php_line_comment = ('//' | '#') @comment nonnewline*;
  php_block_comment =
    '/*' @comment (
      newline %{ entity = INTERNAL_NL; } %php_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '*/';
  php_comment = php_line_comment | php_block_comment;

  php_sq_str =
    '\'' @enqueue @code (
      newline %{ entity = INTERNAL_NL; } %php_ccallback
      |
      ws
      |
      [^\r\n\f'\\] @code
      |
      '\\' nonnewline @code
    )* '\'' @commit @code;
  php_dq_str =
    '"' @enqueue @code (
      newline %{ entity = INTERNAL_NL; } %php_ccallback
      |
      ws
      |
      [^\r\n\f"\\] @code
      |
      '\\' nonnewline @code
    )* '"' @commit @code;
  # TODO: heredoc; see ruby.rl for details.
  php_string = php_sq_str | php_dq_str;

  php_line := |*
    spaces       ${ entity = PHP_SPACE; } => php_ccallback;
    php_comment;
    php_string;
    newline      ${ entity = NEWLINE;   } => php_ccallback;
    ^space       ${ entity = PHP_ANY;   } => php_ccallback;
  *|;

  # Entity machine

  action php_ecallback {
    callback(PHP_LANG, php_entities[entity], cint(ts), cint(te), userdata);
  }

  php_line_comment_entity = ('#' | '//') nonnewline*;
  php_block_comment_entity = '/*' any* :>> '*/';
  php_comment_entity = php_line_comment_entity | php_block_comment_entity;

  php_entity := |*
    space+             ${ entity = PHP_SPACE;   } => php_ecallback;
    php_comment_entity ${ entity = PHP_COMMENT; } => php_ecallback;
    # TODO:
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with PHP code (not in HTML).
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
void parse_php(char *buffer, int length, int count,
               void (*callback) (const char *lang, const char *entity, int s,
                                 int e, void *udata),
               void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? php_en_php_line : php_en_php_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(PHP_LANG) }
}

#endif

/*****************************************************************************/
