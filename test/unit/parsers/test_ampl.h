
void test_ampl_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("ampl", " #comment"),
    "ampl", "", "#comment", 0
  );
}

void test_ampl_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("ampl", " #comment"),
    "comment", "#comment"
  );
}

void all_ampl_tests() {
  test_ampl_comments();
  test_ampl_comment_entities();
}
