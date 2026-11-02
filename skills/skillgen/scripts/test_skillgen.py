#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["beautifulsoup4>=4.12", "markdownify>=0.13"]
# ///
"""Self-check for skillgen's extraction and retention logic. Run: ./test_skillgen.py"""

import importlib.util
from pathlib import Path

spec = importlib.util.spec_from_file_location("skillgen", Path(__file__).parent / "skillgen.py")
sg = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sg)


def test_container_picked_by_volume_not_order():
    """Regression: the real AeroSpace docs have a decorative `.content` div of
    ~18 words and an `#content` div holding the document. `.content` sorts
    earlier in _MAIN, so first-match-wins threw the whole page away."""
    html = """<html><body>
      <div class="content">Edit this page on GitHub</div>
      <div id="content">%s</div>
    </body></html>""" % ("word " * 500)
    md, body_words = sg.extract_html(html)
    assert sg.words(md) > 400, f"picked the decoy container: got {sg.words(md)} words"
    assert body_words > 400, body_words


def test_body_fallback_when_no_container_matches():
    html = "<html><body><div class='x'>%s</div></body></html>" % ("word " * 200)
    md, body_words = sg.extract_html(html)
    assert sg.words(md) > 150, sg.words(md)
    assert body_words > 150, body_words


def test_chrome_is_stripped():
    html = """<html><body>
      <nav>{}</nav><main>{}</main><footer>{}</footer>
    </body></html>""".format("navword " * 300, "realword " * 300, "footword " * 300)
    md, _ = sg.extract_html(html)
    assert "navword" not in md and "footword" not in md, "nav/footer survived"
    assert "realword" in md


def test_retention_flags_lossy_and_empty():
    r = sg.Retention()
    r.add("good", 1000, 990)
    assert r.report(floor=0.90) is True

    r = sg.Retention()
    r.add("lossy", 1000, 40)  # the skill-seekers failure: 96% dropped
    assert r.report(floor=0.90) is False

    r = sg.Retention()
    r.add("empty", 1000, 10)
    assert r.report(floor=0.0) is False, "MIN_WORDS_PER_DOC must fire regardless of floor"


def test_empty_source_does_not_divide_by_zero():
    r = sg.Retention()
    r.add("missing", 0, 0)
    assert r.report(floor=0.90) is False  # 0 words is still EMPTY


def test_slug():
    assert sg.slug("AeroSpace/Guide v2!") == "aerospace-guide-v2"
    assert sg.slug("zshall") == "zshall"


if __name__ == "__main__":
    tests = [v for k, v in sorted(globals().items()) if k.startswith("test_")]
    for t in tests:
        t()
        print(f"  ok {t.__name__}")
    print(f"\n{len(tests)} passed")
