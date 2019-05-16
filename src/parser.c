// parser.c written by Mitchell Foral. mitchell<att>caladbolg.net.
// See COPYING for license information.

#include <string.h>

#include "sourcefile.h"
#include "log.h"
#include "hash/parser_hash.h"

struct ParserMap * ohcount_hash_parser_from_language (register const char *str, register unsigned int len);

int ohcount_parse(SourceFile *sourcefile, int count,
                  void (*callback) (const char *, const char *, int, int,
                                    void *),
                  void *userdata) {
  const char *language = ohcount_sourcefile_get_language(sourcefile);
  if (language) {
    struct ParserMap *rp =
      ohcount_hash_parser_from_language(language, strlen(language));
    if (rp) {
      char *buffer = ohcount_sourcefile_get_contents(sourcefile);
      int buffer_len = ohcount_sourcefile_get_contents_size(sourcefile);
      if (callback)
        rp->parser(buffer, buffer_len, count, callback, userdata);
      return 1;
    }
  }

  return 0;
}
