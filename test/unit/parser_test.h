// parser_test.h written by Mitchell Foral. mitchell<att>caladbolg.net.
// See COPYING for license information.

#include <assert.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../../src/sourcefile.h"

SourceFile *test_parser_sourcefile(const char *language, const char *contents) {
  SourceFile *sf = ohcount_sourcefile_new("foo");
  ohcount_sourcefile_set_contents(sf, contents);
  ohcount_sourcefile_set_language(sf, language);
  return sf;
}

void test_parser_verify_parse(SourceFile *sf, const char *language,
                              const char *code, const char *comments,
                              int blanks) {
  ohcount_sourcefile_parse(sf);
  ParsedLanguageList *list = ohcount_sourcefile_get_parsed_language_list(sf);
  assert(strcmp(list->head->pl->name, language) == 0);
  assert(strcmp(list->head->pl->code, code) == 0);
  assert(strcmp(list->head->pl->comments, comments) == 0);
  assert(list->head->pl->blanks_count == blanks);
  ohcount_sourcefile_free(sf);
}

void test_parser_verify_parse2(SourceFile *sf, const char *language,
                               const char *code, const char *comments,
                               int blanks, const char *language2,
                               const char *code2, const char *comments2,
                               int blanks2) {
  ohcount_sourcefile_parse(sf);
  ParsedLanguageList *list = ohcount_sourcefile_get_parsed_language_list(sf);
  assert(strcmp(list->head->pl->name, language) == 0);
  assert(strcmp(list->head->pl->code, code) == 0);
  assert(strcmp(list->head->pl->comments, comments) == 0);
  assert(list->head->pl->blanks_count == blanks);
  assert(strcmp(list->head->next->pl->name, language2) == 0);
  assert(strcmp(list->head->next->pl->code, code2) == 0);
  assert(strcmp(list->head->next->pl->comments, comments2) == 0);
  assert(list->head->next->pl->blanks_count == blanks2);
  ohcount_sourcefile_free(sf);
}

typedef struct {
  SourceFile *sf;
  const char *entity;
  const char *expected;
} TestParserEntityUData;

void test_parser_entity_callback(const char *language, const char *entity,
                                 int start, int end, void *userdata) {
  TestParserEntityUData *udata = (TestParserEntityUData *)userdata;
  if (strcmp(entity, udata->entity) == 0) {
    char *buffer = ohcount_sourcefile_get_contents(udata->sf);
    assert(strncmp(udata->expected, buffer + start, end - start) == 0);
  }
}

void test_parser_verify_entity(SourceFile *sf, const char *entity,
                               const char *expected) {
  TestParserEntityUData *udata = malloc(sizeof(TestParserEntityUData));
  udata->sf = sf;
  udata->entity = entity;
  udata->expected = expected;
  ohcount_sourcefile_parse_entities_with_callback(sf,
    test_parser_entity_callback, udata);
  ohcount_sourcefile_free(sf);
  free(udata);
}

#include "parsers/test_actionscript.h"
#include "parsers/test_ada.h"
#include "parsers/test_ampl.h"
#include "parsers/test_assembler.h"
#include "parsers/test_augeas.h"
#include "parsers/test_autoconf.h"
#include "parsers/test_automake.h"
#include "parsers/test_awk.h"
#include "parsers/test_basic.h"
#include "parsers/test_bat.h"
#include "parsers/test_blitzmax.h"
#include "parsers/test_boo.h"
#include "parsers/test_brainfuck.h"
#include "parsers/test_bfpp.h"
#include "parsers/test_c.h"
#include "parsers/test_chaiscript.h"
#include "parsers/test_clearsilvertemplate.h"
#include "parsers/test_clearsilver.h"
#include "parsers/test_clojure.h"
#include "parsers/test_coq.h"
#include "parsers/test_crystal.h"
#include "parsers/test_cs_aspx.h"
#include "parsers/test_csharp.h"
#include "parsers/test_css.h"
#include "parsers/test_d.h"
#include "parsers/test_dart.h"
#include "parsers/test_dcl.h"
#include "parsers/test_dylan.h"
#include "parsers/test_ebuild.h"
#include "parsers/test_eiffel.h"
#include "parsers/test_elm.h"
#include "parsers/test_emacs_lisp.h"
#include "parsers/test_erlang.h"
#include "parsers/test_exheres.h"
#include "parsers/test_factor.h"
#include "parsers/test_forth.h"
#include "parsers/test_fortran.h"
#include "parsers/test_fsharp.h"
#include "parsers/test_glsl.h"
#include "parsers/test_golang.h"
#include "parsers/test_groovy.h"
#include "parsers/test_haml.h"
#include "parsers/test_haskell.h"
#include "parsers/test_haxe.h"
#include "parsers/test_html.h"
#include "parsers/test_idl_pvwave.h"
#include "parsers/test_jam.h"
#include "parsers/test_java.h"
#include "parsers/test_javascript.h"
#include "parsers/test_julia.h"
#include "parsers/test_jsp.h"
#include "parsers/test_lisp.h"
#include "parsers/test_livecode.h"
#include "parsers/test_logtalk.h"
#include "parsers/test_lua.h"
#include "parsers/test_make.h"
#include "parsers/test_mathematica.h"
#include "parsers/test_matlab.h"
#include "parsers/test_metafont.h"
#include "parsers/test_metapost.h"
#include "parsers/test_mxml.h"
#include "parsers/test_nix.h"
#include "parsers/test_nsis.h"
#include "parsers/test_objective_j.h"
#include "parsers/test_ocaml.h"
#include "parsers/test_octave.h"
#include "parsers/test_pascal.h"
#include "parsers/test_perl.h"
#include "parsers/test_pike.h"
#include "parsers/test_postscript.h"
#include "parsers/test_powershell.h"
#include "parsers/test_puppet.h"
#include "parsers/test_python.h"
#include "parsers/test_qml.h"
#include "parsers/test_r.h"
#include "parsers/test_racket.h"
#include "parsers/test_rebol.h"
#include "parsers/test_rexx.h"
#include "parsers/test_rhtml.h"
#include "parsers/test_ruby.h"
#include "parsers/test_scala.h"
#include "parsers/test_scheme.h"
#include "parsers/test_scilab.h"
#include "parsers/test_shell.h"
#include "parsers/test_smalltalk.h"
#include "parsers/test_sql.h"
#include "parsers/test_stratego.h"
#include "parsers/test_swift.h"
#include "parsers/test_tcl.h"
#include "parsers/test_tex.h"
#include "parsers/test_umple.h"
#include "parsers/test_unrealscript.h"
#include "parsers/test_typescript.h"
#include "parsers/test_vala.h"
#include "parsers/test_vb_aspx.h"
#include "parsers/test_vhdl.h"
#include "parsers/test_visualbasic.h"
#include "parsers/test_xaml.h"
#include "parsers/test_xml.h"
#include "parsers/test_xmlschema.h"
#include "parsers/test_xslt.h"

typedef struct {
  SourceFile *sf;
  FILE *f;
} TestParserUData;

void test_parser_callback(const char *language, const char *entity,
                                 int start, int end, void *userdata) {
  TestParserUData *udata = (TestParserUData *)userdata;
  char line[512], line2[512];
  assert(fgets(line, sizeof(line), udata->f) != NULL);
  if (strcmp(entity, "lcode") == 0)
    entity = "code";
  else if (strcmp(entity, "lcomment") == 0)
    entity = "comment";
  else if (strcmp(entity, "lblank") == 0)
    entity = "blank";
  sprintf(line2, "%s\t%s\t", language, entity);
  char *buffer = ohcount_sourcefile_get_contents(udata->sf);
  strncpy(line2 + strlen(language) + strlen(entity) + 2, buffer + start,
          end - start);
  line2[strlen(language) + strlen(entity) + 2 + (end - start)] = '\0';
	if (strcmp(line, line2) != 0) {
		fprintf(stderr, "FAIL: Parser test failure in %s:\nExpected: %sGot:      %s", udata->sf->filename, line, line2);
		assert(strcmp(line, line2) == 0);
	}
}

char *test_parser_filenames[] = { "", 0 };

void test_parser_verify_parses() {
  const char *src_dir = "../src_dir/";
  char src[FILENAME_MAX];
  strncpy(src, src_dir, strlen(src_dir));
  char *s_p = src + strlen(src_dir);

  const char *expected_dir = "../expected_dir/";
  char expected[FILENAME_MAX];
  strncpy(expected, expected_dir, strlen(expected_dir));
  char *e_p = expected + strlen(expected_dir);

  struct dirent *file;
  DIR *d = opendir(src_dir);
  if (d) {
    while ((file = readdir(d))) {
      if (strcmp((const char *)file->d_name, ".") != 0 &&
          strcmp((const char *)file->d_name, "..") != 0) {
        int length = strlen(file->d_name);
        strncpy(s_p, (const char *)file->d_name, length);
        *(s_p + length) = '\0';
        strncpy(e_p, (const char *)file->d_name, length);
        *(e_p + length) = '\0';

        FILE *f = fopen((const char *)expected, "rb");
        if (f) {
          SourceFile *sf = ohcount_sourcefile_new((const char *)src);

          // Disambiguators in the detector may access the directory contents of
          // the file in question. This could lead to mis-detections for these
          // unit tests. By default the directory contents are set to "". If
          // this is not desired, add your cases here.
          if (strcmp(s_p, "visual_basic.bas") == 0)
            // This file needs frx1.frx in the directory contents to be
            // detected as Visual Basic.
						sf->filenames = test_basic_vb_filenames;
          else
						sf->filenames = test_parser_filenames;

          TestParserUData *udata = malloc(sizeof(TestParserUData));
          udata->sf = sf;
          udata->f = f;

          // If the expected file not empty, then the source file should be
          // detected as something. Un-detected files are not parsed so no
          // failing assertions would be made, resulting in erroneously passed
          // tests.
          const char *language = ohcount_sourcefile_get_language(sf);
          fseek(f, 0, SEEK_END);
          if (ftell(f) > 0)
            assert(language);
          rewind(f);

          ohcount_sourcefile_parse_with_callback(sf, test_parser_callback,
                                                 (void *)udata);
          fclose(f);
          ohcount_sourcefile_free(sf);
          free(udata);
        }
      }
    }
    closedir(d);
  }
}

void all_parser_tests() {
  test_parser_verify_parses();
  all_actionscript_tests();
  all_ada_tests();
  all_ampl_tests();
  all_assembler_tests();
  all_augeas_tests();
  all_autoconf_tests();
  all_automake_tests();
  all_awk_tests();
  all_basic_tests();
  all_bat_tests();
  all_blitzmax_tests();
  all_boo_tests();
  all_brainfuck_tests();
  all_bfpp_tests();
  all_c_tests();
  all_chaiscript_tests();
  all_clearsilver_template_tests();
  all_clearsilver_tests();
  all_clojure_tests();
  all_coq_tests();
  all_crystal_tests();
  all_cs_aspx_tests();
  all_csharp_tests();
  all_css_tests();
  all_dart_tests();
  all_dmd_tests();
  all_dcl_tests();
  all_dylan_tests();
  all_ebuild_tests();
  all_eiffel_tests();
  all_elm_tests();
  all_emacs_lisp_tests();
  all_erlang_tests();
  all_exheres_tests();
  all_factor_tests();
  all_forth_tests();
  all_fortran_tests();
  all_fsharp_tests();
  all_glsl_tests();
  all_groovy_tests();
  all_haml_tests();
  all_haskell_tests();
  all_haxe_tests();
  all_html_tests();
  all_idl_pvwave_tests();
  all_jam_tests();
  all_java_tests();
  all_javascript_tests();
  all_julia_tests();
  all_jsp_tests();
  all_lisp_tests();
  all_livecode_tests();
  all_logtalk_tests();
  all_lua_tests();
  all_make_tests();
  all_mathematica_tests();
  all_matlab_tests();
  all_metafont_tests();
  all_metapost_tests();
  all_mxml_tests();
  all_nix_tests();
  all_nsis_tests();
  all_objective_j_tests();
  all_ocaml_tests();
  all_octave_tests();
  all_pascal_tests();
  all_perl_tests();
  all_pike_tests();
  all_postscript_tests();
  all_powershell_tests();
  all_python_tests();
  all_r_tests();
  all_racket_tests();
  all_rebol_tests();
  all_rexx_tests();
  all_rhtml_tests();
  all_ruby_tests();
  all_scala_tests();
  all_scheme_tests();
  all_scilab_tests();
  all_shell_tests();
  all_smalltalk_tests();
  all_sql_tests();
  all_stratego_tests();
  all_swift_tests();
  all_tcl_tests();
  all_tex_tests();
  all_umple_tests();
  all_unrealscript_tests();
  all_vala_tests();
  all_vb_aspx_tests();
  all_vhdl_tests();
  all_visualbasic_tests();
  all_xaml_tests();
  all_xml_tests();
  all_xmlschema_tests();
  all_xslt_tests();
}
