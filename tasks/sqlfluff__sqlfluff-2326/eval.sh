#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 38cff664d9505999fb7473a4a7b29ba36aba7883
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 38cff664d9505999fb7473a4a7b29ba36aba7883 test/core/parser/grammar_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/core/parser/grammar_test.py b/test/core/parser/grammar_test.py
--- a/test/core/parser/grammar_test.py
+++ b/test/core/parser/grammar_test.py
@@ -12,6 +12,7 @@
     Indent,
 )
 from sqlfluff.core.parser.context import RootParseContext
+from sqlfluff.core.parser.grammar.anyof import AnySetOf
 from sqlfluff.core.parser.segments import EphemeralSegment, BaseSegment
 from sqlfluff.core.parser.grammar.base import BaseGrammar
 from sqlfluff.core.parser.grammar.noncode import NonCodeMatcher
@@ -678,3 +679,22 @@ def test__parser__grammar_noncode(seg_list, fresh_ansi_dialect):
         m = NonCodeMatcher().match(seg_list[1:], parse_context=ctx)
     # We should match one and only one segment
     assert len(m) == 1
+
+
+def test__parser__grammar_anysetof(generate_test_segments):
+    """Test the AnySetOf grammar."""
+    token_list = ["bar", "  \t ", "foo", "  \t ", "bar"]
+    seg_list = generate_test_segments(token_list)
+
+    bs = StringParser("bar", KeywordSegment)
+    fs = StringParser("foo", KeywordSegment)
+    g = AnySetOf(fs, bs)
+    with RootParseContext(dialect=None) as ctx:
+        # Check directly
+        assert g.match(seg_list, parse_context=ctx).matched_segments == (
+            KeywordSegment("bar", seg_list[0].pos_marker),
+            WhitespaceSegment("  \t ", seg_list[1].pos_marker),
+            KeywordSegment("foo", seg_list[2].pos_marker),
+        )
+        # Check with a bit of whitespace
+        assert not g.match(seg_list[1:], parse_context=ctx)

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/core/parser/grammar_test.py
: '>>>>> End Test Output'
git checkout 38cff664d9505999fb7473a4a7b29ba36aba7883 test/core/parser/grammar_test.py
