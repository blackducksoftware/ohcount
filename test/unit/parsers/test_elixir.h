
void test_elixir_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("elixir", " #comment"),
    "elixir", "", "#comment", 0
  );
}

void test_elixir_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("elixir", " #comment"),
    "comment", "#comment"
  );
  test_parser_verify_entity(
    test_parser_sourcefile("elixir", "@moduledoc \"\"\"\ncomment\n=\"\"\""),
    "comment", "@moduledoc \"\"\"\ncomment\n=\"\"\""
  );
}

void all_elixir_tests() {
  test_elixir_comments();
  test_elixir_comment_entities();
}
