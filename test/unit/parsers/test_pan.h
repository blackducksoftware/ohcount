
void test_pan_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("pan", " #comment"),
    "pan", "", "#comment", 0
  );
}

void test_pan_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("pan", " #comment"),
    "comment", "#comment"
  );
}

void all_pan_tests() {
  test_pan_comments();
  test_pan_comment_entities();
}
