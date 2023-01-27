// detector_test.h written by Mitchell Foral. mitchell<att>caladbolg.net.
// See COPYING for license information.

#include <assert.h>
#include <dirent.h>
#include <stdlib.h>
#include <string.h>

#include "../../src/detector.h"
#include "../../src/languages.h"
#include "../../src/sourcefile.h"

char **get_filenames(SourceFile *sourcefile) {
	if (sourcefile->filenames == NULL) {
		char dirpath[FILENAME_MAX];
		strncpy(dirpath, sourcefile->filepath, sourcefile->dirpath);
		dirpath[sourcefile->dirpath] = '\0';
		struct dirent *file;
		DIR *d = opendir((const char *)dirpath);
		if (d) {
			int length = 0;
			while ((file = readdir(d))) length++;
			closedir(d);

			char **filenames = calloc(length + 1, sizeof(char *));
			int i = 0;
			d = opendir((const char *)dirpath);
			while ((file = readdir(d))) {
				int len = strlen(file->d_name);
				char *filename = malloc(len + 1);
				strncpy(filename, file->d_name, len);
				filename[len] = '\0';
				filenames[i++] = filename;
			}
			closedir(d);
			sourcefile->filenames = filenames;
		}
	}
	return sourcefile->filenames;
}

#define ASSERT_DETECT(x, y) { \
  SourceFile *sf = ohcount_sourcefile_new("../detect_files/" y); \
	get_filenames(sf); \
  const char *lang = ohcount_detect_language(sf); \
  assert(lang); \
  assert(strcmp(x, lang) == 0); \
  ohcount_sourcefile_free(sf); \
}
#define ASSERT_NODETECT(x) { \
  SourceFile *sf = ohcount_sourcefile_new("../detect_files/" x); \
	get_filenames(sf); \
  assert(ohcount_detect_language(sf) == NULL); \
  ohcount_sourcefile_free(sf); \
}

void test_detector_smalltalk() {
  ASSERT_DETECT(LANG_SMALLTALK, "example.st");
  ASSERT_NODETECT("english.st");
}

void test_detector_disambiguate_asx() {
  ASSERT_DETECT(LANG_ASSEMBLER, "assembler6502.asx");
  ASSERT_NODETECT("AdvancedStreamRedirector.asx");
}

void test_detector_disambiguate_def() {
  ASSERT_DETECT(LANG_MODULA2, "sampleDef.def");
  ASSERT_NODETECT("module-definition.def");
}

void test_detector_disambiguate_m() {
  ASSERT_DETECT(LANG_OBJECTIVE_C, "t1.m");
  ASSERT_DETECT(LANG_OBJECTIVE_C, "t2.m");
  ASSERT_DETECT(LANG_OBJECTIVE_C, "TCPSocket.m");
  ASSERT_DETECT(LANG_OBJECTIVE_C, "foo_objective_c.m");
  ASSERT_DETECT(LANG_MATHEMATICA, "foo_mathematica.m");
  ASSERT_DETECT(LANG_MATLAB, "foo_matlab.m");
  ASSERT_DETECT(LANG_OCTAVE, "foo_octave.m");
}

void test_detector_disambiguate_in() {
  ASSERT_NODETECT("empty.in");
  ASSERT_NODETECT("foo.in.in");
}

void test_detector_disambiguate_pl() {
  ASSERT_DETECT(LANG_PERL, "foo_perl1.pl");
  ASSERT_DETECT(LANG_PERL, "foo_perl2.pl");
  ASSERT_DETECT(LANG_PROLOG, "foo_prolog1.pl");
  ASSERT_DETECT(LANG_PERL, "perl_with_smiley.pl");
  ASSERT_DETECT(LANG_PERL, "perl_shebang_prolog_body.pl");
}

void test_detector_disambiguate_pro() {
  ASSERT_DETECT(LANG_IDL_PVWAVE, "foo.pro");
  ASSERT_DETECT(LANG_MAKE, "qmake.pro");
}

void test_detector_disambiguate_r() {
  ASSERT_DETECT(LANG_R, "foo_r.R");
  ASSERT_DETECT(LANG_REBOL, "foo_rebol_lower.r");
  ASSERT_DETECT(LANG_REBOL, "foo_rebol_upper.r");
}

void test_detector_disambiguate_mod() {
  ASSERT_DETECT(LANG_AMPL, "ampl.mod");
  ASSERT_DETECT(LANG_MODULA2, "modula2.mod");
}

void test_detector_disambiguate_dat() {
  ASSERT_DETECT(LANG_AMPL, "ampl.dat");
  ASSERT_DETECT("\1", "binary.dat");
}

void test_detector_fortran_fixedfree() {
  ASSERT_DETECT(LANG_FORTRANFIXED, "fortranfixed.f");
  ASSERT_DETECT(LANG_FORTRANFREE, "fortranfree.f");
}

void test_detector_detect_polyglot() {
  ASSERT_DETECT(LANG_C, "foo.c");
  ASSERT_DETECT(LANG_C, "uses_no_cpp.h");
  ASSERT_DETECT(LANG_CPP, "uses_cpp_headers.h");
  ASSERT_DETECT(LANG_CPP, "uses_cpp_stdlib_headers.h");
  ASSERT_DETECT(LANG_CPP, "uses_cpp_keywords.h");
  ASSERT_DETECT(LANG_RUBY, "foo.rb");
  ASSERT_DETECT(LANG_CRYSTAL, "foo.cr");
  ASSERT_DETECT(LANG_MAKE, "foo.mk");
  ASSERT_DETECT(LANG_MATHEMATICA, "foo.mt");
  ASSERT_DETECT(LANG_MATHEMATICA, "foo.wl");
  ASSERT_DETECT(LANG_MATHEMATICA, "foo.wlt");
  ASSERT_DETECT(LANG_MODELICA, "foo.mo");
  ASSERT_DETECT(LANG_OBJECTIVE_C, "foo_objective_c.h");
  ASSERT_DETECT(LANG_PHP, "upper_case_php");
  ASSERT_DETECT(LANG_SMALLTALK, "example.st");
  ASSERT_DETECT(LANG_VALA, "foo.vala");
  ASSERT_DETECT(LANG_TEX_DTX, "foo.dtx");
  ASSERT_DETECT(LANG_TEX, "foo.tex");
  ASSERT_DETECT(LANG_TYPESCRIPT, "foo.ts");
  ASSERT_DETECT(LANG_TYPESCRIPT, "foo.tsx");
  ASSERT_DETECT(LANG_XSLT, "example.xsl");
  ASSERT_DETECT(LANG_LOGTALK, "foo.lgt");
  ASSERT_DETECT(LANG_LISP, "core.lisp");
  ASSERT_DETECT(LANG_DMD, "foo.d");
  ASSERT_DETECT(LANG_VIM, "foo.vim");
  ASSERT_DETECT(LANG_EC, "foo.ec");
  ASSERT_DETECT(LANG_EC, "foo.eh");
  ASSERT_DETECT(LANG_EBUILD, "foo.ebuild");
  ASSERT_DETECT(LANG_EBUILD, "foo.eclass");
  ASSERT_DETECT(LANG_EXHERES, "foo.exheres-0");
  ASSERT_DETECT(LANG_EXHERES, "foo.exlib");
  ASSERT_DETECT(LANG_EIFFEL, "eiffel.e");
  ASSERT_DETECT(LANG_OCAML, "ocaml.ml");
  ASSERT_DETECT(LANG_AUGEAS, "augeas.aug");
  ASSERT_DETECT(LANG_STRATEGO, "stratego.str");
  ASSERT_DETECT(LANG_GLSL, "foo.glsl");
  ASSERT_DETECT(LANG_GLSL, "foo_glsl.vert");
  ASSERT_DETECT(LANG_GLSL, "foo_glsl.frag");
  ASSERT_DETECT(LANG_IDL_PVWAVE, "foo.pro");
  ASSERT_DETECT(LANG_ASSEMBLER, "foo.z80");
  ASSERT_DETECT(LANG_PHP, "php.inc");
  ASSERT_DETECT(LANG_FORTH, "forth.4th");
  ASSERT_DETECT(LANG_FORTH, "forth.fr");
  ASSERT_DETECT(LANG_FSHARP, "fs1.fs");
  ASSERT_DETECT(LANG_GRACE, "grace1.grace");
  ASSERT_DETECT(LANG_GRACE, "grace2.grc");
  ASSERT_DETECT(LANG_FORTH, "forth.fs");
  ASSERT_DETECT(LANG_AUTOCONF, "m4.m4");
  ASSERT_DETECT(LANG_NSIS, "foo.nsi");
  ASSERT_DETECT(LANG_NSIS, "foo.nsh");
  ASSERT_DETECT(LANG_COFFEESCRIPT, "foo.coffee");
  ASSERT_DETECT(LANG_QML, "foo.qml");
  ASSERT_DETECT(LANG_COQ, "coq.v");
  ASSERT_DETECT(LANG_UNREALSCRIPT, "foo.uc");
  ASSERT_DETECT(LANG_AMPL, "foo.run");
  ASSERT_DETECT(LANG_LIVECODE, "foo.lc");
  ASSERT_DETECT(LANG_LIVECODE, "script.utf8");
  ASSERT_DETECT(LANG_POSTSCRIPT, "foo.ps");
  ASSERT_DETECT(LANG_SWIFT, "foo.swift");
  ASSERT_DETECT(LANG_UMPLE, "foo.umple");
  ASSERT_NODETECT("empty.inc");
}

void test_detector_upper_case_extensions() {
  ASSERT_DETECT(LANG_CPP, "foo_upper_case.C");
  ASSERT_DETECT(LANG_RUBY, "foo_upper_case.RB");
}

void test_detector_no_extensions() {
  ASSERT_DETECT(LANG_PYTHON, "py_script");
  ASSERT_DETECT(LANG_RUBY, "ruby_script");
  ASSERT_DETECT(LANG_SHELL, "bourne_again_script");
  ASSERT_DETECT(LANG_SHELL, "bash_script");
  ASSERT_DETECT(LANG_PERL, "perl_w");
  ASSERT_DETECT(LANG_DMD, "d_script");
  ASSERT_DETECT(LANG_TCL, "tcl_script");
  ASSERT_DETECT(LANG_PYTHON, "python.data");
  ASSERT_DETECT(LANG_PYTHON, "python2.data");
  ASSERT_DETECT(LANG_CPP, "uses_cpp_modeline");
}

void test_detector_csharp_or_clearsilver() {
  ASSERT_DETECT(LANG_CSHARP, "cs1.cs");
  ASSERT_DETECT(LANG_CLEARSILVER_TEMPLATE, "clearsilver_template1.cs");
}

void test_detector_basic() {
  ASSERT_DETECT(LANG_VISUALBASIC, "visual_basic.bas");
  ASSERT_DETECT(LANG_CLASSIC_BASIC, "classic_basic.b");
  assert(system("mv ../detect_files/frx1.frx ../detect_files/frx1.frx2") == 0);
  ASSERT_DETECT(LANG_STRUCTURED_BASIC, "visual_basic.bas");
  ASSERT_DETECT(LANG_STRUCTURED_BASIC, "structured_basic.b");
  assert(system("mv ../detect_files/frx1.frx2 ../detect_files/frx1.frx") == 0);
}

void test_detector_xml_with_custom_extension() {
  ASSERT_DETECT(LANG_XML, "xml.custom_ext");
}

void test_detector_brainfuck() {
  ASSERT_DETECT(LANG_BRAINFUCK, "foo.bf");
  ASSERT_DETECT(LANG_BFPP, "foo.bfpp");
}

void test_detector_dart() {
  ASSERT_DETECT(LANG_DART, "foo.dart");
}

void test_detector_emacs_mode() {
	ASSERT_DETECT(LANG_C, "emacs_mode_c");
}

void test_detector_emacs_with_extension() {
  ASSERT_DETECT(LANG_RUBY, "java_emac.rb");
  ASSERT_DETECT(LANG_JAVASCRIPT, "javascript_emac.js");
}

void test_detector_puppet(){
  ASSERT_DETECT(LANG_PUPPET, "puppet_import.pp");
  ASSERT_DETECT(LANG_PUPPET, "puppet_test.pp");
}

void test_detector_genie(){
  ASSERT_DETECT(LANG_GENIE, "client-osx.gs");
}

void test_detector_rust(){
  ASSERT_DETECT(LANG_RUST, "rust.rs");
  // When RenderScript is implemented, this will, of course, need to be removed.
  ASSERT_NODETECT("renderscript.rs");
}

void test_detector_ampl(){
  ASSERT_DETECT(LANG_AMPL, "foo.run");
}

void test_non_existent_file(){
  ASSERT_NODETECT("xxx_non_exists_xxxi.pp");
}

void all_detector_tests() {
  test_detector_smalltalk();
  test_detector_disambiguate_asx();
  test_detector_disambiguate_def();
  test_detector_disambiguate_m();
  test_detector_disambiguate_in();
  test_detector_disambiguate_pl();
  test_detector_disambiguate_pro();
  test_detector_disambiguate_r();
  test_detector_disambiguate_mod();
  test_detector_disambiguate_dat();
  test_detector_fortran_fixedfree();
  test_detector_detect_polyglot();
  test_detector_upper_case_extensions();
  test_detector_no_extensions();
  test_detector_csharp_or_clearsilver();
  test_detector_basic();
  test_detector_xml_with_custom_extension();
  test_detector_brainfuck();
  test_detector_dart();
  test_detector_emacs_mode();
  test_detector_emacs_with_extension();
  test_detector_puppet();
  test_detector_genie();
  test_detector_rust();
  test_detector_ampl();
  test_non_existent_file();
}
