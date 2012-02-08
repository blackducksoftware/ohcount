// detector.c written by Mitchell Foral. mitchell<att>caladbolg.net.
// See COPYING for license information.

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "detector.h"
#include "languages.h"
#include "log.h"

#include "hash/cppheader_hash.h"
#include "hash/disambiguatefunc_hash.h"
#include "hash/extension_hash.h"
#include "hash/filename_hash.h"

#define ISBINARY(x) (x[0] == '\1')
#define ISAMBIGUOUS(x) (x[0] == '\2')
#define DISAMBIGUATEWHAT(x) &x[1]

#ifdef _WIN32
# include <fcntl.h>
# define mkstemp(p) _open(_mktemp(p), _O_CREAT | _O_SHORT_LIVED | _O_EXCL)
#endif

/* Replaces single quotes (') with an escape sequence ('\'')
 * suitable for use on the command line.
 */
void escape_path(char *safe, const char *unsafe) {
  do {
    switch (*unsafe) {
    case  '\'':
      *safe++ = '\'';
      *safe++ = '\\';
      *safe++ = '\'';
      *safe++ = '\'';
      break;
    default:
      *safe++ = *unsafe;
      break;
    }
  } while (*unsafe++);
}

const char *ohcount_detect_language(SourceFile *sourcefile) {
  const char *language = NULL;
  char *p, *pe;
  int length;

  // Attempt to detect using Emacs mode line (/^-\*-\s*mode[\s:]*\w/i).
  char line[81] = { '\0' }, buf[81];
  p = ohcount_sourcefile_get_contents(sourcefile);
  pe = p;
  char *eof = p + ohcount_sourcefile_get_contents_size(sourcefile);
  while (pe < eof) {
    // Get the contents of the first line.
    while (pe < eof && *pe != '\r' && *pe != '\n') pe++;
    length = (pe - p <= sizeof(line)) ? pe - p : sizeof(line);
    strncpy(line, p, length);
    line[length] = '\0';
    if (*line == '#' && *(line + 1) == '!') {
      // First line was sh-bang; loop to get contents of second line.
      while (*pe == '\r' || *pe == '\n') pe++;
      p = pe;
    } else break;
  }
  p = strstr(line, "-*-");
  if (p) {
    p += 3;
    while (*p == ' ' || *p == '\t') p++;
    // detect "mode" (any capitalization)
    if (strncasecmp(p, "mode", 4) == 0) {
      p += 4;
      while (*p == ' ' || *p == '\t' || *p == ':') p++;
    }
    pe = p;
    while (!isspace(*pe) && *pe != ';' && pe != strstr(pe, "-*-")) pe++;
    length = (pe - p <= sizeof(buf)) ? pe - p : sizeof(buf);
    strncpy(buf, p, length);
    buf[length] = '\0';

		// Special case for "c" or "C" emacs mode header: always means C, not C++
		if (strcasecmp(buf, "c") == 0) {
				return LANG_C;
		}

    // First try it with the language name.
    struct LanguageMap *rl = ohcount_hash_language_from_name(buf, length);
    if (rl) language = rl->name;
    if(!language) {
      // Then try it with the extension table.
      struct ExtensionMap *re = ohcount_hash_language_from_ext(buf, length);
      if (re) language = re->value;
    }
    if (!language) {
      // Try the lower-case version of this modeline.
      for (pe = buf; pe < buf+length; pe++) *pe = tolower(*pe);
      // First try it with the language name.
      rl = ohcount_hash_language_from_name(buf, length);
      if (rl) language = rl->name;
    }
    if (!language) {
      // Then try it with the extension table.
      struct ExtensionMap *re = ohcount_hash_language_from_ext(buf, length);
      if (re) language = re->value;
    }
  }

  // Attempt to detect based on file extension.
  if(!language) {
      length = strlen(sourcefile->ext);
      struct ExtensionMap *re = ohcount_hash_language_from_ext(sourcefile->ext,
                                                               length);
      if (re) language = re->value;
    if (!language) {
      // Try the lower-case version of this extension.
      char lowerext[length + 1];
      strncpy(lowerext, sourcefile->ext, length);
      lowerext[length] = '\0';
      for (p = lowerext; p < lowerext + length; p++) *p = tolower(*p);
      struct ExtensionMap *re = ohcount_hash_language_from_ext(lowerext, length);
      if (re) language = re->value;
    }
  }

  // Attempt to detect based on filename.
  if(!language) {
    length = strlen(sourcefile->filename);
    struct FilenameMap *rf =
      ohcount_hash_language_from_filename(sourcefile->filename, length);
    if (rf) language = rf->value;
  }

  // Attempt to detect based on Unix 'file' command.
  if(!language) {
    int tmpfile = 0;
    char *path = sourcefile->filepath;
    if (sourcefile->diskpath)
      path = sourcefile->diskpath;
    if (access(path, F_OK) != 0) { // create temporary file
      path = malloc(21);
      strncpy(path, "/tmp/ohcount_XXXXXXX\0", 21);
      int fd = mkstemp(path);
      char *contents = ohcount_sourcefile_get_contents(sourcefile);
      log_it("contents:");
      log_it(contents);
      length = contents ? strlen(contents) : 0;
      if (write(fd, contents, length) != length) {
        fprintf(stderr, "src/detector.c: Could not write temporary file %s.\n", path);
        exit(1);
      }
      close(fd);
      tmpfile = 1;
    }

    /* Filenames may include single quotes, which must be escaped */
    char escaped_path[strlen(path) * 4 + 1];
    escape_path(escaped_path, path);

    char command[strlen(escaped_path) + 11];
    sprintf(command, "file -b '%s'", escaped_path);
    FILE *f = popen(command, "r");
    if (f) {
      if (fgets(line, sizeof(line), f) == NULL) {
        fprintf(stderr, "src/detector.c: fgets() failed\n");
        exit(1);
      }
      char *eol = line + strlen(line);
      for (p = line; p < eol; p++) *p = tolower(*p);
      p = strstr(line, "script text");
      if (p && p == line) { // /^script text(?: executable)? for \w/
        p = strstr(line, "for ");
        if (p) {
          p += 4;
          pe = p;
          while (isalnum(*pe)) pe++;
          length = pe - p;
          strncpy(buf, p, length);
          buf[length] = '\0';
          struct LanguageMap *rl = ohcount_hash_language_from_name(buf, length);
          if (rl) language = rl->name;
        }
      } else if (p) { // /(\w+)(?: -\w+)* script text/
        do {
          p--;
          pe = p;
          while (*p == ' ') p--;
          while (p != line && isalnum(*(p - 1))) p--;
          if (p != line && *(p - 1) == '-') p--;
        } while (*p == '-'); // Skip over any switches.
        length = pe - p;
        strncpy(buf, p, length);
        buf[length] = '\0';
        struct LanguageMap *rl = ohcount_hash_language_from_name(buf, length);
        if (rl) language = rl->name;
      } else if (strstr(line, "xml")) language = LANG_XML;
      pclose(f);
      if (tmpfile) {
        remove(path);
        free(path);
      }
    }
  }
  if (language) {
    if (ISAMBIGUOUS(language)) {
      // Call the appropriate function for disambiguation.
      length = strlen(DISAMBIGUATEWHAT(language));
      struct DisambiguateFuncsMap *rd =
        ohcount_hash_disambiguate_func_from_id(DISAMBIGUATEWHAT(language),
                                               length);
      if (rd) language = rd->value(sourcefile);
    } else language = ISBINARY(language) ? NULL : language;
  }
  return language;
}

const char *disambiguate_aspx(SourceFile *sourcefile) {
  char *p = ohcount_sourcefile_get_contents(sourcefile);
  char *eof = p + ohcount_sourcefile_get_contents_size(sourcefile);
  for (; p < eof; p++) {
    // /<%@\s*Page[^>]+Language="VB"[^>]+%>/
    p = strstr(p, "<%@");
    if (!p)
			break;
    char *pe = strstr(p, "%>");
    if (p && pe) {
      p += 3;
      const int length = pe - p;
      char buf[length];
      strncpy(buf, p, length);
      buf[length] = '\0';
      char *eol = buf + strlen(buf);
      for (p = buf; p < eol; p++) *p = tolower(*p);
      p = buf;
      while (*p == ' ' || *p == '\t') p++;
      if (strncmp(p, "page", 4) == 0) {
        p += 4;
        if (strstr(p, "language=\"vb\""))
          return LANG_VB_ASPX;
      }
    }
  }
  return LANG_CS_ASPX;
}

// 6502 assembly or XML-based Advanced Stream Redirector ?
const char *disambiguate_asx(SourceFile *sourcefile) {
  char *p = ohcount_sourcefile_get_contents(sourcefile);
  char *eof = p + ohcount_sourcefile_get_contents_size(sourcefile);
  for (; p < eof; p++) {
    switch (*p) {
    case ' ':
    case '\t':
    case '\n':
    case '\r':
      break;
    case '<':
    case '\0':
    // byte-order marks:
    case (char) 0xef:
    case (char) 0xfe:
    case (char) 0xff:
      return NULL; // XML
    default:
      return LANG_ASSEMBLER;
    }
  }
  return LANG_ASSEMBLER; // only blanks - not valid XML, may be valid asm
}

const char *disambiguate_b(SourceFile *sourcefile) {
  char *p = ohcount_sourcefile_get_contents(sourcefile);
  char *eof = p + ohcount_sourcefile_get_contents_size(sourcefile);
  while (p < eof) {
    // /(implement[ \t])|(include[ \t]+"[^"]*";)|
    //  ((return|break|continue).*;|(pick|case).*\{)/
    if (strncmp(p, "implement", 9) == 0 &&
        (*(p + 9) == ' ' || *(p + 9) == '\t'))
      return LANG_LIMBO;
    else if (strncmp(p, "include", 7) == 0 &&
        (*(p + 7) == ' ' || *(p + 7) == '\t')) {
      p += 7;
      while (*p == ' ' || *p == '\t') p++;
      if (*p == '"') {
        while (*p != '"' && p < eof) p++;
        if (*p == '"' && *(p + 1) == ';')
          return LANG_LIMBO;
      }
    } else if (strncmp(p, "return", 6) == 0 ||
               strncmp(p, "break", 5) == 0 ||
               strncmp(p, "continue", 8) == 0) {
      if (strstr(p, ";"))
        return LANG_LIMBO;
    } else if (strncmp(p, "pick", 4) == 0 ||
               strncmp(p, "case", 4) == 0) {
      if (strstr(p, "{"))
        return LANG_LIMBO;
    }
    p++;
  }
  return disambiguate_basic(sourcefile);
}

const char *disambiguate_basic(SourceFile *sourcefile) {
  char *p, *pe;
  int length;

  // Attempt to detect based on file contents.
  char line[81];
  p = ohcount_sourcefile_get_contents(sourcefile);
  pe = p;
  char *eof = p + ohcount_sourcefile_get_contents_size(sourcefile);
  while (pe < eof) {
    // Get a line at a time.
    while (pe < eof && *pe != '\r' && *pe != '\n') pe++;
    length = (pe - p <= sizeof(line)) ? pe - p : sizeof(line);
    strncpy(line, p, length);
    line[length] = '\0';
    char *line_end = pe;

    p = line;
    if (isdigit(*p)) {
      // /^\d+\s+\w/
      p++;
      while (isdigit(*p)) p++;
      if (*p == ' ' || *p == '\t') {
        p++;
        while (*p == ' ' || *p == '\t') p++;
        if (isalnum(*p))
          return LANG_CLASSIC_BASIC;
      }
    }

    // Next line.
    pe = line_end;
    while (*pe == '\r' || *pe == '\n') pe++;
    p = pe;
  }

  // Attempt to detect from associated VB files in file context.
  char **filenames = sourcefile->filenames;
  if (filenames) {
    int i;
    for (i = 0; filenames[i] != NULL; i++) {
      pe = filenames[i] + strlen(filenames[i]);
      p = pe;
      while (p > filenames[i] && *(p - 1) != '.') p--;
      length = pe - p;
      if (length == 3 &&
          (strncmp(p, "frm", length) == 0 ||
           strncmp(p, "frx", length) == 0 ||
           strncmp(p, "vba", length) == 0 ||
           strncmp(p, "vbp", length) == 0 ||
           strncmp(p, "vbs", length) == 0)) {
        return LANG_VISUALBASIC;
      }
    }
  }

  return LANG_STRUCTURED_BASIC;
}

const char *disambiguate_cs(SourceFile *sourcefile) {
  // Attempt to detect based on file contents.
	char *contents = ohcount_sourcefile_get_contents(sourcefile);
  if (contents && strstr(contents, "<?cs"))
    return LANG_CLEARSILVER_TEMPLATE;
  else
    return LANG_CSHARP;
}

const char *disambiguate_def(SourceFile *sourcefile) {
  char *p = ohcount_sourcefile_get_contents(sourcefile);
  char *eof = p + ohcount_sourcefile_get_contents_size(sourcefile);
  for (; p < eof; p++) {
    switch (*p) {
    case ' ':
    case '\t':
    case '\n':
    case '\r':
      break;
    case '(':
      if (p[1] == '*') // Modula-2 comment
        return LANG_MODULA2;
      return NULL;
    case 'D':
      if (strncmp(p, "DEFINITION", 10) == 0) // Modula-2 "DEFINITION MODULE"
        return LANG_MODULA2;
      return NULL;
    default:
      return NULL; // not Modula-2
    }
  }
  return NULL; // only blanks
}

const char *disambiguate_fortran(SourceFile *sourcefile) {
  char *p, *pe;

  p = ohcount_sourcefile_get_contents(sourcefile);
  char *eof = p + ohcount_sourcefile_get_contents_size(sourcefile);
  while (p < eof) {
    if (*p == ' ' && p + 5 < eof) {
      int i;
      for (i = 1; i <= 5; i++)
        if (!isdigit(*(p + i)) && *(p + i) != ' ')
          return LANG_FORTRANFIXED; // definately not f77
      // Possibly fixed (doesn't match /^\s*\d+\s*$/).
      pe = p;
      while (*pe == ' ' || *pe == '\t') pe++;
      if (pe - p <= 5) {
        if (!isdigit(*pe))
          return LANG_FORTRANFIXED;
        while (isdigit(*pe)) pe++;
        while (*pe == ' ' || *pe == '\t') pe++;
        if (*pe != '\r' && *pe != '\n' && pe - p == 5)
          return LANG_FORTRANFIXED;
      }
    }
    while (*p != '\r' && *p != '\n' && *p != '&' && p < eof) p++;
    if (*p == '&') {
      p++;
      // Look for free-form continuation.
      while (*p == ' ' || *p == '\t') p++;
      if (*p == '\r' || *p == '\n') {
        pe = p;
        while (*pe == '\r' || *pe == '\n' || *pe == ' ' || *pe == '\t') pe++;
        if (*pe == '&')
          return LANG_FORTRANFREE;
      }
    }
    while (*p == '\r' || *p == '\n') p++;
  }
  return LANG_FORTRANFREE; // might as well be free-form
}

const char *disambiguate_h(SourceFile *sourcefile) {
  char *p, *pe, *bof;
  int length;

  // If the directory contains a matching *.m file, likely Objective C.
  length = strlen(sourcefile->filename);
  if (strcmp(sourcefile->ext, "h") == 0) {
    char path[length];
    strncpy(path, sourcefile->filename, length);
    path[length] = '\0';
    *(path + length - 1) = 'm';
    char **filenames = sourcefile->filenames;
    if (filenames) {
      int i;
      for (i = 0; filenames[i] != NULL; i++)
        if (strcmp(path, filenames[i]) == 0)
          return LANG_OBJECTIVE_C;
    }
  }

  // Attempt to detect based on file contents.
  char line[81], buf[81];
  bof = ohcount_sourcefile_get_contents(sourcefile);
  p = bof;
  pe = p;
  char *eof = p + ohcount_sourcefile_get_contents_size(sourcefile);
  while (pe < eof) {
    // Get a line at a time.
    while (pe < eof && *pe != '\r' && *pe != '\n') pe++;
    length = (pe - p <= sizeof(line)) ? pe - p : sizeof(line);
    strncpy(line, p, length);
    line[length] = '\0';
    char *eol = line + strlen(line);
    char *line_end = pe;

    // Look for C++ headers.
    if (*line == '#') {
      p = line + 1;
      while (*p == ' ' || *p == '\t') p++;
      if (strncmp(p, "include", 7) == 0 &&
          (*(p + 7) == ' ' || *(p + 7) == '\t')) {
        // /^#\s*include\s+[<"][^>"]+[>"]/
        p += 8;
        while (*p == ' ' || *p == '\t') p++;
        if (*p == '<' || *p == '"') {
          // Is the header file a C++ header file?
          p++;
          pe = p;
          while (pe < eol && *pe != '>' && *pe != '"') pe++;
          length = pe - p;
          strncpy(buf, p, length);
          buf[length] = '\0';
          if (ohcount_hash_is_cppheader(buf, length))
            return LANG_CPP;
          // Is the extension for the header file a C++ file?
          p = pe;
          while (p > line && *(p - 1) != '.') p--;
          length = pe - p;
          strncpy(buf, p, length);
          buf[length] = '\0';
          struct ExtensionMap *re = ohcount_hash_language_from_ext(buf, length);
          if (re && strcmp(re->value, LANG_CPP) == 0)
            return LANG_CPP;
        }
      }
    }

    // Look for C++ keywords.
    p = line;
    while (p < eol) {
      if (islower(*p) && p != bof && !isalnum(*(p - 1)) && *(p - 1) != '_') {
        pe = p;
        while (islower(*pe)) pe++;
        if (!isalnum(*pe) && *pe != '_') {
          length = pe - p;
          strncpy(buf, p, length);
          buf[length] = '\0';
          if (strcmp(buf, "class") == 0 ||
              strcmp(buf, "namespace") == 0 ||
              strcmp(buf, "template") == 0 ||
              strcmp(buf, "typename") == 0)
            return LANG_CPP;
        }
        p = pe + 1;
      } else p++;
    }

    // Next line.
    pe = line_end;
    while (*pe == '\r' || *pe == '\n') pe++;
    p = pe;
  }

  // Nothing to suggest C++.
  return LANG_C;
}

const char *disambiguate_in(SourceFile *sourcefile) {
  char *p, *pe;
  int length;
  const char *language = NULL;

  p = sourcefile->filepath;
  pe = p + strlen(p) - 3;
  if (strstr(p, ".") <= pe) {
    // Only if the filename has an extension prior to the .in
    length = pe - p;
    char buf[length];
    strncpy(buf, p, length);
    buf[length] = '\0';
    SourceFile *undecorated = ohcount_sourcefile_new(buf);
    p = ohcount_sourcefile_get_contents(sourcefile);
		if (!p) {
			return NULL;
		}
    // The filepath without the '.in' extension does not exist on disk. The
    // sourcefile->diskpath field must be set incase the detector needs to run
    // 'file -b' on the file.
    ohcount_sourcefile_set_diskpath(undecorated, sourcefile->filepath);
    ohcount_sourcefile_set_contents(undecorated, p);
		undecorated->filenames = sourcefile->filenames;
    language = ohcount_sourcefile_get_language(undecorated);
    ohcount_sourcefile_free(undecorated);
  }
  return language;
}

const char *disambiguate_inc(SourceFile *sourcefile) {
  char *p = ohcount_sourcefile_get_contents(sourcefile);
	if (p) {
		char *eof = p + strlen(p);
		while (p < eof) {
			if (*p == '\0')
				return BINARY;
			else if (*p == '?' && strncmp(p + 1, "php", 3) == 0)
				return LANG_PHP;
			p++;
		}
	}
  return NULL;
}

const char *disambiguate_m(SourceFile *sourcefile) {
  char *p, *pe;
  int length;

  // Attempt to detect based on a weighted heuristic of file contents.
  int matlab_score = 0;
  int objective_c_score = 0;
  int limbo_score = 0;
  int octave_syntax_detected = 0;

  int i, has_h_headers = 0, has_c_files = 0;
  char **filenames = sourcefile->filenames;
  if (filenames) {
    for (i = 0; filenames[i] != NULL; i++) {
      p = filenames[i];
      pe = p + strlen(p);
      if (pe - p >= 4) {
        if (*(pe - 4) == '.' && *(pe - 3) == 'c' &&
            ((*(pe - 2) == 'p' && *(pe - 1) == 'p') ||
             (*(pe - 2) == '+' && *(pe - 1) == '+') ||
             (*(pe - 2) == 'x' && *(pe - 1) == 'x'))) {
          has_c_files = 1;
          break; // short circuit
        }
      } else if (pe - p >= 3) {
        if (*(pe - 3) == '.' && *(pe - 2) == 'c' && *(pe - 1) == 'c') {
          has_c_files = 1;
          break; // short circuit
        }
      } else if (pe - p >= 2) {
        if (*(pe - 2) == '.') {
          if (*(pe - 1) == 'h')
            has_h_headers = 1;
          else if (*(pe - 1) == 'c' || *(pe - 1) == 'C') {
            has_c_files = 1;
            break; // short circuit
          }
        }
      }
    }
  }
  if (has_h_headers && !has_c_files)
    objective_c_score += 5;

  char line[81], buf[81];
  p = ohcount_sourcefile_get_contents(sourcefile);
  pe = p;
  char *eof = p + ohcount_sourcefile_get_contents_size(sourcefile);
  while (pe < eof) {
    // Get a line at a time.
    while (pe < eof && *pe != '\r' && *pe != '\n') pe++;
    length = (pe - p <= sizeof(line)) ? pe - p : sizeof(line);
    strncpy(line, p, length);
    line[length] = '\0';
    char *eol = line + strlen(line);
    char *line_end = pe;

    // Look for tell-tale lines.
    p = line;
    while (*p == ' ' || *p == '\t') p++;
    if (*p == '%') { // Matlab comment
      matlab_score++;
		} else if (*p == '#' && strncmp(p, "#import", 7) == 0) { // Objective C
			objective_c_score++;
    } else if (*p == '#') { // Limbo or Octave comment
      while (*p == '#') p++;
      if (*p == ' ' || *p == '\t') {
        limbo_score++;
        matlab_score++;
        octave_syntax_detected = 1;
      }
    } else if (*p == '/' && *(p + 1) == '/' || *(p + 1) == '*') {
      objective_c_score++; // Objective C comment
    } else if (*p == '+' || *p == '-') { // Objective C method signature
      objective_c_score++;
    } else if (*p == '@' || *p == '#') { // Objective C method signature
      if (strncmp(p, "@implementation", 15) == 0 ||
          strncmp(p, "@interface", 10) == 0)
        objective_c_score++;
    } else if (strncmp(p, "function", 8) == 0) { // Matlab or Octave function
      p += 8;
      while (*p == ' ' || *p == '\t') p++;
      if (*p == '(')
        matlab_score++;
    } else if (strncmp(p, "include", 7) == 0) { // Limbo include
      // /^include[ \t]+"[^"]+\.m";/
      p += 7;
      if (*p == ' ' || *p == '\t') {
        while (*p == ' ' || *p == '\t') p++;
        if (*p == '"') {
          while (*p != '"' && p < eol) p++;
          if (*p == '"' && *(p - 2) == '.' && *(p - 1) == 'm')
            limbo_score++;
        }
      }
    }

    // Look for Octave keywords.
    p = line;
    while (p < eol) {
      if (islower(*p) && p != line && !isalnum(*(p - 1))) {
        pe = p;
        while (islower(*pe) || *pe == '_') pe++;
        if (!isalnum(*pe)) {
          length = pe - p;
          strncpy(buf, p, length);
          buf[length] = '\0';
          if (strcmp(buf, "end_try_catch") == 0 ||
              strcmp(buf, "end_unwind_protect") == 0 ||
              strcmp(buf, "endfunction") == 0 ||
              strcmp(buf, "endwhile") == 0)
            octave_syntax_detected = 1;
        }
        p = pe + 1;
      } else p++;
    }

    // Look for Limbo declarations
    p = line;
    while (p < eol) {
      if (*p == ':' && (*(p + 1) == ' ' || *(p + 1) == '\t')) {
        // /:[ \t]+(module|adt|fn ?\(|con[ \t])/
        p += 2;
        if (strncmp(p, "module", 6) == 0 && !isalnum(*(p + 6)) ||
            strncmp(p, "adt", 3) == 0 && !isalnum(*(p + 3)) ||
            strncmp(p, "fn", 2) == 0 &&
              (*(p + 2) == ' ' && *(p + 3) == '(' || *(p + 2) == '(') ||
            strncmp(p, "con", 3) == 0 &&
              (*(p + 3) == ' ' || *(p + 3) == '\t'))
          limbo_score++;
      } else p++;
    }

    // Next line.
    pe = line_end;
    while (*pe == '\r' || *pe == '\n') pe++;
    p = pe;
  }

  if (limbo_score > objective_c_score && limbo_score > matlab_score)
    return LANG_LIMBO;
  else if (objective_c_score > matlab_score)
    return LANG_OBJECTIVE_C;
  else
    return octave_syntax_detected ? LANG_OCTAVE : LANG_MATLAB;
}

#include <pcre.h>

// strnlen is not available on OS X, so we roll our own
size_t mystrnlen(const char *begin, size_t maxlen) {
  const char *end = memchr(begin, '\0', maxlen);
  return end ? (end - begin) : maxlen;
}

const char *disambiguate_pp(SourceFile *sourcefile) {
	char *p = ohcount_sourcefile_get_contents(sourcefile);
  char *eof = p + ohcount_sourcefile_get_contents_size(sourcefile);

	/* prepare regular expressions */
	pcre *re;
	const char *error;
	int erroffset;
	re = pcre_compile("(define\\s+\\w+\\s*\\(|class \\s+\\w+\\s*{)", 0, &error, &erroffset, NULL);

	for (; p < eof; p++) {
		if (strncmp(p, "$include", 8) == 0 ||
				strncmp(p, "$INCLUDE", 8) == 0 ||
				strncmp(p, "end.", 4) == 0)
			return LANG_PASCAL;
		if (strncmp(p, "enable =>", 9) == 0 ||
				strncmp(p, "ensure =>", 9) == 0 ||
				strncmp(p, "content =>", 10) == 0 ||
				strncmp(p, "source =>", 9) == 0 ||
				strncmp(p, "include ", 8) == 0)
			return LANG_PUPPET;

		/* regexp for checking for define and class declarations */

		int rc;
		int ovector[30];
		rc = pcre_exec(re, NULL, p, mystrnlen(p, 100), 0, 0, ovector, 30);
		if(rc > 0) {
			return LANG_PUPPET;
		}

	}
	return LANG_PASCAL;
}

const char *disambiguate_pl(SourceFile *sourcefile) {
	char *contents = ohcount_sourcefile_get_contents(sourcefile);
  if (!contents)
    return NULL;

  // Check for a perl shebang on first line of file
	const char *error;
	int erroffset;
	pcre *re = pcre_compile("#![^\\n]*perl", PCRE_CASELESS, &error, &erroffset, NULL);
  if (pcre_exec(re, NULL, contents, mystrnlen(contents, 100), 0, PCRE_ANCHORED, NULL, 0) > -1)
    return LANG_PERL;

  // Check for prolog :- rules
  if (strstr(contents, ":- ") || strstr(contents, ":-\n"))
    return LANG_PROLOG;

  // Perl by default.
  return LANG_PERL;
}

#define QMAKE_SOURCES_SPACE "SOURCES +="
#define QMAKE_SOURCES "SOURCES+="
#define QMAKE_CONFIG_SPACE "CONFIG +="
#define QMAKE_CONFIG "CONFIG+="

const char *disambiguate_pro(SourceFile *sourcefile) {
	char *p = ohcount_sourcefile_get_contents(sourcefile);
  char *eof = p + ohcount_sourcefile_get_contents_size(sourcefile);
	for (; p < eof; p++) {
		if (strncmp(p, QMAKE_SOURCES_SPACE, strlen(QMAKE_SOURCES_SPACE)) == 0 ||
				strncmp(p, QMAKE_SOURCES, strlen(QMAKE_SOURCES)) == 0 ||
				strncmp(p, QMAKE_CONFIG_SPACE, strlen(QMAKE_CONFIG_SPACE)) == 0 ||
				strncmp(p, QMAKE_CONFIG, strlen(QMAKE_CONFIG)) == 0)
			return LANG_MAKE; // really QMAKE
	}
	return LANG_IDL_PVWAVE;
}

const char *disambiguate_r(SourceFile *sourcefile) {
  char *contents = ohcount_sourcefile_get_contents(sourcefile);
  if (!contents)
    return LANG_R;

  char *eof = contents + ohcount_sourcefile_get_contents_size(sourcefile);

  // Detect REBOL by looking for the occurence of "rebol" in the contents
  // (case-insensitive). Correct REBOL scripts have a "REBOL [...]" header
  // block.
  char *needle = "rebol";
  int len = strlen(needle);
  for (; contents < eof - len; ++contents)
    if (tolower(*contents) == *needle &&
          !strncasecmp(contents, needle, len))
      return LANG_REBOL;

  return LANG_R;
}

const char *disambiguate_st(SourceFile *sourcefile) {
  char *p, *pe;
  int length;

  // Attempt to detect based on file contents.
  int found_assignment = 0, found_block_start = 0, found_block_end = 0;

  char line[81];
  p = ohcount_sourcefile_get_contents(sourcefile);
  pe = p;
  char *eof = p + ohcount_sourcefile_get_contents_size(sourcefile);
  while (pe < eof) {
    // Get a line at a time.
    while (pe < eof && *pe != '\r' && *pe != '\n') pe++;
    length = (pe - p <= sizeof(line)) ? pe - p : sizeof(line);
    strncpy(line, p, length);
    line[length] = '\0';
    char *eol = line + strlen(line);
    char *line_end = pe;

    for (p = line; p < eol; p++) {
      if (*p == ':') {
        p++;
        while (p < eol && (*p == ' ' || *p == '\t')) p++;
        if (*p == '=')
          found_assignment = 1;
        else if (*p == '[')
          found_block_start = 1;
      } else if (*p == ']' && *(p + 1) == '.') found_block_end = 1;
      if (found_assignment && found_block_start && found_block_end)
        return LANG_SMALLTALK;
    }

    // Next line.
    pe = line_end;
    while (*pe == '\r' || *pe == '\n') pe++;
    p = pe;
  }

  return NULL;
}

int ohcount_is_binary_filename(const char *filename) {
  char *p = (char *)filename + strlen(filename);
  while (p > filename && *(p - 1) != '.') p--;
  if (p > filename) {
    struct ExtensionMap *re;
    int length = strlen(p);
    re = ohcount_hash_language_from_ext(p, length);
    if (re) return ISBINARY(re->value);
    // Try the lower-case version of this extension.
    char lowerext[length];
    strncpy(lowerext, p, length);
    lowerext[length] = '\0';
    for (p = lowerext; p < lowerext + length; p++) *p = tolower(*p);
    re = ohcount_hash_language_from_ext(lowerext, length);
    if (re) return ISBINARY(re->value);
  }
  return 0;
}
