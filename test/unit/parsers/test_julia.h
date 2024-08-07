
void test_julia_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("julia", " #comment"),
    "julia", "", "#comment", 0
  );
}

void test_julia_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("julia", " #comment"),
    "comment", "#comment"
  );
  test_parser_verify_entity(
    test_parser_sourcefile("julia", "#=\ncomment\n=#"),
    "comment", "#=\ncomment\n=#"
  );
}

void all_julia_tests() {
  test_julia_comments();
  test_julia_comment_entities();
}
