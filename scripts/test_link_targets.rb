# frozen_string_literal: true
require_relative "../_plugins/link_targets"

def check(condition, message)
  abort("FAIL: #{message}") unless condition
end
samples = [
  '<a href="https://example.org/?a=1&amp;b=2">External</a>',
  "<a href='/publications/'>Internal page</a>",
  '<a href=/#publications>Section</a>',
  '<a href="mailto:hello@example.org">Email</a>',
  '<a href="/cv.pdf" target="_self" rel="author opener">CV</a>',
  '<a href="/" title="A > B" data-target="leave-me">Home</a>'
]
samples.each do |source|
  rendered = SiteLinkTargets.rewrite(source)
  check(rendered.include?('target="_blank"'), "new-tab target: #{source}")
  check(rendered.include?("noopener") && rendered.include?("noreferrer"), "safe relations")
  check(!rendered.match?(/rel="[^"]*\bopener\b/), "opener removed")
  check(SiteLinkTargets.rewrite(rendered) == rendered, "idempotent transformation")
end
check(SiteLinkTargets.rewrite(samples.first).include?("a=1&amp;b=2"), "entities preserved")
check(SiteLinkTargets.rewrite(samples.last).include?('data-target="leave-me"'), "data attributes preserved")
skip = SiteLinkTargets.rewrite('<a class="skip-link" href="#main-content">Skip</a>')
check(skip.include?('target="_self"'), "skip control remains on this page")
[
  '<!-- <a href="/">example</a> -->',
  '<script>const text = \'<a href="/">example</a>\';</script>',
  '<style>/* <a href="/">example</a> */</style>',
  '&lt;a href="/"&gt;example&lt;/a&gt;',
  '<a id="bookmark" data-href="not-a-link">Bookmark</a>'
].each { |source| check(SiteLinkTargets.rewrite(source) == source, "non-navigation content unchanged") }
puts "PASS: link rewriting, safe relations, entities, raw text, keyboard skip and idempotence."
