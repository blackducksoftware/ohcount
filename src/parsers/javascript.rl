// Javascript.rl written by Mitchell Foral. mitchell<att>caladbolg<dott>net.

/************************* Required for every parser *************************/
#ifndef OHCOUNT_JAVASCRIPT_PARSER_H
#define OHCOUNT_JAVASCRIPT_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *JS_LANG = LANG_JAVASCRIPT;

// the languages entities
const char *js_entities[] = {
  "space", "comment", "string", "number", "keyword",
  "identifier", "operator", "any"
};

// constants associated with the entities
enum {
  JS_SPACE = 0, JS_COMMENT, JS_STRING, JS_NUMBER, JS_KEYWORD,
  JS_IDENTIFIER, JS_OPERATOR, JS_ANY
};

/*****************************************************************************/

%%{
  machine javascript;
  write data;
  include common "common.rl";

  # Line counting machine

  action js_ccallback {
    switch(entity) {
    case JS_SPACE:
      ls
      break;
    case JS_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(JS_LANG)
      break;
    case NEWLINE:
      std_newline(JS_LANG)
    }
  }

  js_line_comment = '//' @comment nonnewline*;
  js_block_comment =
    '/*' @comment (
      newline %{ entity = INTERNAL_NL; } %js_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '*/';
  js_comment = js_line_comment | js_block_comment;

  # Does Javascript allow newlines inside strings?
  # I can't find a definitive answer.
  js_sq_str =
    '\'' @code (
      escaped_newline %{ entity = INTERNAL_NL; } %js_ccallback
      |
      ws
      |
      [^\t '\\] @code
      |
      '\\' nonnewline @code
    )* '\'';
  js_dq_str =
    '"' @code (
      escaped_newline %{ entity = INTERNAL_NL; } %js_ccallback
      |
      ws
      |
      [^\t "\\] @code
      |
      '\\' nonnewline @code
    )* '"';
  js_regex_str = '/' [^/*] ([^\r\n\f/\\] | '\\' nonnewline)* '/' @code;
  js_string = js_sq_str | js_dq_str | js_regex_str;

  js_line := |*
    spaces     ${ entity = JS_SPACE; } => js_ccallback;
    js_comment;
    js_string;
    newline    ${ entity = NEWLINE;  } => js_ccallback;
    ^space     ${ entity = JS_ANY;   } => js_ccallback;
  *|;

  # Entity machine

  action js_ecallback {
    callback(JS_LANG, js_entities[entity], cint(ts), cint(te), userdata);
  }

  js_line_comment_entity = '//' nonnewline*;
  js_block_comment_entity = '/*' any* :>> '*/';
  js_comment_entity = js_line_comment_entity | js_block_comment_entity;

  js_entity := |*
    space+            ${ entity = JS_SPACE;   } => js_ecallback;
    js_comment_entity ${ entity = JS_COMMENT; } => js_ecallback;
    # TODO:
    ^space;
  *|;
}%%

/* Parses a string buffer with Javascript code.
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
void parse_javascript(char *buffer, int length, int count,
                      void (*callback) (const char *lang, const char *entity,
                                        int s, int e, void *udata),
                      void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? javascript_en_js_line : javascript_en_js_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(JS_LANG) }
}

const char *QML_LANG = LANG_QML;
const char *ORIG_JS_LANG = LANG_JAVASCRIPT;
void parse_qml(char *buffer, int length, int count,
               void (*callback) (const char *lang, const char *entity,
                                 int s, int e, void *udata),
               void *userdata
  ) {
  JS_LANG = QML_LANG;
  parse_javascript(buffer, length, count, callback, userdata);
  JS_LANG = ORIG_JS_LANG;
}

const char *JSON_LANG = LANG_JSON;
const char *ORIG_JS_LANG = LANG_JAVASCRIPT;
void parse_json(char *buffer, int length, int count,
               void (*callback) (const char *lang, const char *entity,
                                 int s, int e, void *udata),
               void *userdata
  ) {
  JS_LANG = JSON_LANG;
  parse_javascript(buffer, length, count, callback, userdata);
  JS_LANG = ORIG_JS_LANG;
}

#endif
