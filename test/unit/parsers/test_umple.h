void test_umple_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("umple", " //comment"),
    "umple", "", "//comment", 0
  );
}

void test_umple_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("umple", " //comment"),
    "comment", "//comment"
  );
  test_parser_verify_entity(
    test_parser_sourcefile("umple", " /*comment*/"),
    "comment", "/*comment*/"
  );
}

void all_umple_tests() {
  test_umple_comments();
  test_umple_comment_entities();
}
