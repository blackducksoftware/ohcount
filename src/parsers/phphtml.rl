// phtml.rl written by Mitchell Foral. mitchell<att>caladbolg<dott>net.

/************************* Required for every parser *************************/
#ifndef OHCOUNT_PHTML_PARSER_H
#define OHCOUNT_PHTML_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *PHTML_LANG = LANG_HTML;

// the languages entities
const char *phtml_entities[] = {
  "space", "comment", "doctype",
  "tag", "entity", "any"
};

// constants associated with the entities
enum {
  PHTML_SPACE = 0, PHTML_COMMENT, PHTML_DOCTYPE,
  PHTML_TAG, PHTML_ENTITY, PHTML_ANY
};

/*****************************************************************************/

#include "css.h"
#include "javascript.h"
#include "php.h"

%%{
  machine phtml;
  write data;
  include common "common.rl";
  #EMBED(css)
  #EMBED(javascript)
  #EMBED(php)

  # Line counting machine

  action phtml_ccallback {
    switch(entity) {
    case PHTML_SPACE:
      ls
      break;
    case PHTML_ANY:
      code
      break;
    case INTERNAL_NL:
      emb_internal_newline(PHTML_LANG)
      break;
    case NEWLINE:
      emb_newline(PHTML_LANG)
      break;
    case CHECK_BLANK_ENTRY:
      check_blank_entry(PHTML_LANG)
    }
  }

  phtml_comment := (
    newline %{ entity = INTERNAL_NL; } %phtml_ccallback
    |
    ws
    |
    ^(space | [\-<]) @comment
    |
    '<' '?php' @{ saw(PHP_LANG); fcall phtml_php_line; }
    |
    '<' !'?php'
  )* :>> '-->' @comment @{ fgoto phtml_line; };

  phtml_sq_str := (
    newline %{ entity = INTERNAL_NL; } %phtml_ccallback
    |
    ws
    |
    [^\r\n\f\t '\\<] @code
    |
    '\\' nonnewline @code
    |
    '<' '?php' @{ saw(PHP_LANG); fcall phtml_php_line; }
    |
    '<' !'?php'
  )* '\'' @{ fgoto phtml_line; };
  phtml_dq_str := (
    newline %{ entity = INTERNAL_NL; } %phtml_ccallback
    |
    ws
    |
    [^\r\n\f\t "\\<] @code
    |
    '\\' nonnewline @code
    |
    '<' '?php' @{ saw(PHP_LANG); fcall phtml_php_line; }
    |
    '<' !'?php'
  )* '"' @{ fgoto phtml_line; };

  ws_or_inl = (ws | newline @{ entity = INTERNAL_NL; } %phtml_ccallback);

  phtml_css_entry = '<' /style/i [^>]+ :>> 'text/css' [^>]+ '>' @code;
  phtml_css_outry = '</' /style/i ws_or_inl* '>' @check_blank_outry @code;
  phtml_css_line := |*
    phtml_css_outry @{ p = ts; fret; };
    # unmodified CSS patterns
    spaces      ${ entity = CSS_SPACE; } => css_ccallback;
    css_comment;
    css_string;
    newline     ${ entity = NEWLINE;   } => css_ccallback;
    ^space      ${ entity = CSS_ANY;   } => css_ccallback;
  *|;

  phtml_js_entry = '<' /script/i [^>]+ :>> 'text/javascript' [^>]+ '>' @code;
  phtml_js_outry = '</' /script/i ws_or_inl* '>' @check_blank_outry @code;
  phtml_js_line := |*
    phtml_js_outry @{ p = ts; fret; };
    # unmodified Javascript patterns
    spaces     ${ entity = JS_SPACE; } => js_ccallback;
    js_comment;
    js_string;
    newline    ${ entity = NEWLINE;  } => js_ccallback;
    ^space     ${ entity = JS_ANY;   } => js_ccallback;
  *|;

  phtml_php_entry = ('<?' 'php'?) @code;
  phtml_php_outry = '?>' @check_blank_outry @code;
  phtml_php_line := |*
    phtml_php_outry ${ p = ts; fret; };
    # unmodified PHP patterns
    spaces       ${ entity = PHP_SPACE; } => php_ccallback;
    php_comment;
    php_string;
    newline      ${ entity = NEWLINE;   } => php_ccallback;
    ^space       ${ entity = PHP_ANY;   } => php_ccallback;
  *|;

  phtml_line := |*
    phtml_css_entry @{ entity = CHECK_BLANK_ENTRY; } @phtml_ccallback
      @{ saw(CSS_LANG); } => { fcall phtml_css_line; };
    phtml_js_entry @{ entity = CHECK_BLANK_ENTRY; } @phtml_ccallback
      @{ saw(JS_LANG); } => { fcall phtml_js_line; };
    phtml_php_entry @{ entity = CHECK_BLANK_ENTRY; } @php_ccallback
      @{ saw(PHP_LANG); } => { fcall phtml_php_line; };
    # standard PHTML patterns
    spaces       ${ entity = PHTML_SPACE; } => phtml_ccallback;
    '<!--'       @comment                   => { fgoto phtml_comment; };
    '\''         @code                      => { fgoto phtml_sq_str;  };
    '"'          @code                      => { fgoto phtml_dq_str;  };
    newline      ${ entity = NEWLINE;     } => phtml_ccallback;
    ^space       ${ entity = PHTML_ANY;   } => phtml_ccallback;
  *|;

  # Entity machine

  action phtml_ecallback {
    callback(PHTML_LANG, phtml_entities[entity], cint(ts), cint(te), userdata);
  }

  phtml_css_entry_entity = '<' /style/i [^>]+ :>> 'text/css' [^>]+ '>';
  phtml_css_outry_entity = '</' /style/i ws_or_inl* '>';
  phtml_css_entity := |*
    phtml_css_outry_entity @{ fret; };
    # unmodified CSS patterns
    space+             ${ entity = CSS_SPACE;   } => css_ecallback;
    css_comment_entity ${ entity = CSS_COMMENT; } => css_ecallback;
    # TODO:
    ^space;
  *|;

  phtml_js_entry_entity = '<' /script/i [^>]+ :>> 'text/javascript' [^>]+ '>';
  phtml_js_outry_entity = '</' /script/i ws_or_inl* '>';
  phtml_js_entity := |*
    phtml_js_outry_entity @{ fret; };
    # unmodified Javascript patterns
    space+            ${ entity = JS_SPACE;   } => js_ecallback;
    js_comment_entity ${ entity = JS_COMMENT; } => js_ecallback;
    # TODO:
    ^space;
  *|;

  phtml_php_entry_entity = '<?' 'php'?;
  phtml_php_outry_entity = '?>';
  phtml_php_entity := |*
    phtml_php_outry_entity @{ fret; };
    # unmodified PHP patterns
    space+             ${ entity = PHP_SPACE;   } => php_ecallback;
    php_comment_entity ${ entity = PHP_COMMENT; } => php_ecallback;
    # TODO:
    ^space;
  *|;

  phtml_comment_entity = '<!--' any* :>> '-->';

  phtml_entity := |*
    # TODO: phtml_ecallback for phtml_*_{entry,outry}_entity
    phtml_css_entry_entity => { fcall phtml_css_entity; };
    phtml_js_entry_entity  => { fcall phtml_js_entity;  };
    phtml_php_entry_entity => { fcall phtml_php_entity; };
    # standard PHML patterns
    space+               ${ entity = PHTML_SPACE;   } => phtml_ecallback;
    phtml_comment_entity ${ entity = PHTML_COMMENT; } => phtml_ecallback;
    # TODO:
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with PHP code (in HTML).
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
void parse_phtml(char *buffer, int length, int count,
                 void (*callback) (const char *lang, const char *entity, int s,
                                   int e, void *udata),
                 void *userdata
  ) {
  init

  const char *seen = 0;

  %% write init;
  cs = (count) ? phtml_en_phtml_line : phtml_en_phtml_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(PHTML_LANG) }
}

#endif

/*****************************************************************************/
