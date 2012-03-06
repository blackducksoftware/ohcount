
void test_forth_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("forth", " \\comment"),
    "comment", "\\comment"
  );
  test_parser_verify_entity(
    test_parser_sourcefile("forth", " (comment)"),
    "comment", "(comment)"
  );
}

void all_forth_tests() {
  test_forth_comment_entities();
}
