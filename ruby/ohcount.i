
%module ohcount
%{
#include "../src/detector.h"
#include "../src/languages.h"
#include "../src/sourcefile.h"
%}

%include typemaps.i

#if defined(SWIGRUBY)

%typemap(in) (register const char *str, register unsigned int len) {
  Check_Type($input, T_STRING);
  $1 = StringValuePtr($input);
  $2 = RSTRING_LEN($input);
};

%typemap(out) char ** {
  VALUE arr = rb_ary_new();
  int i;
  for (i = 0; $1[i] != NULL; i++)
    rb_ary_push(arr, rb_str_new2($1[i]));
  $result = arr;
};

#elif defined(SWIGPYTHON)

%typemap(in) (register const char *str, register unsigned int len) {
  if (!PyString_Check($input)) {
    PyErr_SetString(PyExc_SyntaxError, "Invalid parameter");
    return NULL;
  }
  $1 = PyString_AsString($input);
  $2 = PyString_Size($input);
};

%typemap(out) char ** {
  int i;
  PyObject *arr = PyList_New(0);
  for (i = 0; $1[i] != NULL; i++)
    PyList_Append(arr, PyString_FromString($1[i]));
  $result = arr;
};


#else
#error "You should define specific translation rules for this language."
#endif

%nodefaultctor SourceFile;
%immutable;
%include "../src/languages.h"
%include "../src/structs.h"
%mutable;

%extend Loc {
  int total() {
    return ohcount_loc_total(self);
  }
}

%extend LocListItem {
  int code() {
    return ohcount_loc_list_code(self);
  }
  int comments() {
    return ohcount_loc_list_comments(self);
  }
  int blanks() {
    return ohcount_loc_list_blanks(self);
  }
  int total() {
    return ohcount_loc_list_total(self);
  }
  int filecount() {
    return ohcount_loc_list_filecount(self);
  }
}

%extend SourceFile {
  void set_diskpath(const char *diskpath) {
    ohcount_sourcefile_set_diskpath(self, diskpath);
  }
  void set_contents(const char *contents) {
    ohcount_sourcefile_set_contents(self, contents);
  }
  char *get_contents() {
    return ohcount_sourcefile_get_contents(self);
  }
  int contents_size() {
    return ohcount_sourcefile_get_contents_size(self);
  }
  const char *get_language() {
    return ohcount_sourcefile_get_language(self);
  }
  void parse() {
    ohcount_sourcefile_parse(self);
  }
  ParsedLanguageList *get_parsed_language_list() {
    return ohcount_sourcefile_get_parsed_language_list(self);
  }
  LicenseList *get_license_list() {
    return ohcount_sourcefile_get_license_list(self);
  }
  LocList *get_loc_list() {
    return ohcount_sourcefile_get_loc_list(self);
  }
  LocDeltaList *_diff(SourceFile *to) {
    return ohcount_sourcefile_diff(self, to);
  }
#if defined(SWIGRUBY)
  void set_filenames(VALUE filenames) {
    int i, length = RARRAY_LEN(filenames);
    char **fnames = calloc(length + 1, sizeof(char *));
    VALUE *iter = RARRAY_PTR(filenames);
    for (i = 0; i < length; i++, iter++)
      fnames[i] = StringValuePtr(*iter);
    self->filenames = fnames;
  }
  SourceFile(const char *filepath, VALUE opt_hash=0) {
    SourceFile *sourcefile = ohcount_sourcefile_new(filepath);
    if (opt_hash) {
      VALUE val;
      val = rb_hash_aref(opt_hash, ID2SYM(rb_intern("contents")));
      if (val && rb_type(val) == T_STRING)
        ohcount_sourcefile_set_contents(sourcefile, StringValuePtr(val));
      val = rb_hash_aref(opt_hash, ID2SYM(rb_intern("file_location")));
      if (val && rb_type(val) == T_STRING)
        ohcount_sourcefile_set_diskpath(sourcefile, StringValuePtr(val));
      val = rb_hash_aref(opt_hash, ID2SYM(rb_intern("filenames")));
      if (val && rb_type(val) == T_ARRAY)
        SourceFile_set_filenames(sourcefile, val);
    }
    return sourcefile;
  }
#elif defined(SWIGPYTHON)
  void set_filenames(PyObject *filenames) {
    int i, length;
    char **fnames;
    if (!PyList_Check(filenames)) {
      PyErr_SetString(PyExc_SyntaxError, "Invalid parameter, expected a list of strings");
      return;
    }
    length = PyList_Size(filenames);
    fnames = calloc(length + 1, sizeof(char *));
    for (i = 0; i < length; i++) {
      PyObject *s = PyList_GetItem(filenames, i);
      if (!PyString_Check(s)) {
        PyErr_SetString(PyExc_SyntaxError, "Invalid parameter, expected a list of strings");
        return;
      }
      fnames[i] = PyString_AsString(s);
    }
    ohcount_sourcefile_set_filenames(self, fnames);
    free(fnames);
  }
  static void py_annotate_callback(const char *language, const char *entity,
                  int start, int end, void *userdata) {
    PyObject *list = (PyObject *) userdata;
    PyObject *dict = PyDict_New();
    PyDict_SetItem(dict, PyString_FromString("language"),
        PyString_FromString(language));
    PyDict_SetItem(dict, PyString_FromString("entity"),
        PyString_FromString(entity));
    PyDict_SetItem(dict, PyString_FromString("start"),
        PyInt_FromLong(start));
    PyDict_SetItem(dict, PyString_FromString("end"),
        PyInt_FromLong(end));
    PyList_Append(list, dict);
  }
  PyObject *annotate() {
    PyObject *list = PyList_New(0);
    ohcount_sourcefile_parse_with_callback(self, SourceFile_py_annotate_callback, list);
    return list;
  }
  PyObject *raw_entities() {
    PyObject *list = PyList_New(0);
    ohcount_sourcefile_parse_entities_with_callback(self, SourceFile_py_annotate_callback, list);
    return list;
  }
  SourceFile(const char *filepath, PyObject *args) {
    SourceFile *sourcefile = ohcount_sourcefile_new(filepath);
    if (args) {
      PyObject *val;
      if (!PyDict_Check(args)) {
        PyErr_SetString(PyExc_SyntaxError, "Invalid argument");
        ohcount_sourcefile_free(sourcefile);
        return NULL;
      }
      val = PyDict_GetItem(args, PyString_FromString("contents"));
      if (val && PyString_Check(val))
        ohcount_sourcefile_set_contents(sourcefile, PyString_AsString(val));
      val = PyDict_GetItem(args, PyString_FromString("file_location"));
      if (val && PyString_Check(val))
        ohcount_sourcefile_set_diskpath(sourcefile, PyString_AsString(val));
      val = PyDict_GetItem(args, PyString_FromString("filenames"));
      if (val && PyString_Check(val))
        SourceFile_set_filenames(sourcefile, val);
    }
    return sourcefile;
  }

#endif
  ~SourceFile() {
    if (self->filenames)
      free(self->filenames);
    ohcount_sourcefile_free(self);
  }
};

%extend SourceFileListItem {
#if defined(SWIGRUBY)

  static VALUE rb_add_directory(VALUE directory, SourceFileList *list) {
    if (directory && rb_type(directory) == T_STRING)
      ohcount_sourcefile_list_add_directory(list, StringValuePtr(directory));
    return Qnil;
  }
  static VALUE rb_add_file(VALUE file, SourceFileList *list) {
    if (file && rb_type(file) == T_STRING)
      ohcount_sourcefile_list_add_file(list, StringValuePtr(file));
    return Qnil;
  }
  SourceFileListItem(VALUE opt_hash=0) {
    SourceFileList *list = ohcount_sourcefile_list_new();
    if (opt_hash) {
      VALUE val;
      val = rb_hash_aref(opt_hash, ID2SYM(rb_intern("paths")));
      if (val && rb_type(val) == T_ARRAY)
        rb_iterate(rb_each, val, SourceFileListItem_rb_add_directory, (VALUE)list);
      val = rb_hash_aref(opt_hash, ID2SYM(rb_intern("files")));
      if (val && rb_type(val) == T_ARRAY)
        rb_iterate(rb_each, val, SourceFileListItem_rb_add_file, (VALUE)list);
    }
    return list;
  }

#elif defined(SWIGPYTHON)

  SourceFileListItem(PyObject *args) {
    SourceFileList *list = ohcount_sourcefile_list_new();
    if (args) {
      PyObject *val;
      if (!PyDict_Check(args)) {
        PyErr_SetString(PyExc_SyntaxError, "Invalid argument");
        ohcount_sourcefile_list_free(list);
        return NULL;
      }
      val = PyDict_GetItem(args, PyString_FromString("paths"));
      if (val && PyList_Check(val)) {
        int i, length = PyList_Size(val);
        for (i = 0; i < length; i++) {
          PyObject *s = PyList_GetItem(val, i);
          if (!PyString_Check(s)) {
            PyErr_SetString(PyExc_SyntaxError, "Invalid 'paths', expected a list of strings");
            ohcount_sourcefile_list_free(list);
            return NULL;
          }
          ohcount_sourcefile_list_add_directory(list, PyString_AsString(s));
        }
      }
      val = PyDict_GetItem(args, PyString_FromString("files"));
      if (val && PyList_Check(val)) {
        int i, length = PyList_Size(val);
        for (i = 0; i < length; i++) {
          PyObject *s = PyList_GetItem(val, i);
          if (!PyString_Check(s)) {
            PyErr_SetString(PyExc_SyntaxError, "Invalid 'files', expected a list of strings");
            ohcount_sourcefile_list_free(list);
            return NULL;
          }
          ohcount_sourcefile_list_add_file(list, PyString_AsString(s));
        }
      }
    }
    return list;
  }

#endif

  ~SourceFileListItem() {
    ohcount_sourcefile_list_free(self);
  }
  void add_file(const char *filepath) {
    ohcount_sourcefile_list_add_file(self, filepath);
  }
  void add_directory(const char *directory) {
    ohcount_sourcefile_list_add_directory(self, directory);
  }
  LocList *analyze_languages() {
    return ohcount_sourcefile_list_analyze_languages(self);
  }
}

int ohcount_is_binary_filename(const char *filename);

struct LanguageMap *ohcount_hash_language_from_name(register const char *str, register unsigned int len);
