
void test_coq_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("coq", " (* comment *)"),
    "coq", "", "(* comment *)", 0
  );
}

void test_coq_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("coq", " (*comment*)"),
    "comment", "(*comment*)"
  );
}

void all_coq_tests() {
  test_coq_comments();
  test_coq_comment_entities();
}
