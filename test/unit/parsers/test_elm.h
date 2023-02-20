
void test_elm_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("elm", " --comment"),
    "elm", "", "--comment", 0
  );
}

void test_elm_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("elm", " --comment"),
    "comment", "--comment"
  );
  test_parser_verify_entity(
    test_parser_sourcefile("elm", " {-comment-}"),
    "comment", "{-comment-}"
  );
}

void all_elm_tests() {
  test_elm_comments();
  test_elm_comment_entities();
}
