
void test_json_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("json", " //comment"),
    "json", "", "//comment", 0
  );
}

void test_json_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("json", " //comment"),
    "comment", "//comment"
  );
  test_parser_verify_entity(
    test_parser_sourcefile("json", " /*comment*/"),
    "comment", "/*comment*/"
  );
}

void all_json_tests() {
  test_json_comments();
  test_json_comment_entities();
}
