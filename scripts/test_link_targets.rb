# frozen_string_literal: true
require_relative "../_plugins/link_targets"

def check(condition, message)
  abort("FAIL: #{message}") unless condition
end

same_tab = [
  '<a href="/">Home</a>',
  '<a href="/#about">About</a>',
  '<a href="#publications">Section</a>',
  '<a href="/publications/">Publications</a>',
  '<a href="/news/">News</a>',
  '<a href="https://kinux98.github.io/#experience">Same-origin absolute</a>',
  '<a href="/news/item.html">Local HTML</a>',
  '<a href="/experience/exp1/">Experience</a>',
  '<a href="/" title="Opens in a new tab" rel="noopener noreferrer">Home</a>',
  '<a class="skip-link" href="#main-content">Skip</a>'
]
new_tab = [
  '<a href="https://example.org/?a=1&amp;b=2">External</a>',
  '<a href="https://scholar.google.com/citations?user=x">Scholar</a>',
  '<a href="/assets/pdf/Donghyeon_Kwon_CV.pdf">CV PDF</a>',
  '<a href="mailto:hello@example.org">Email</a>',
  '<a href="//example.org/page">External protocol-relative</a>',
  '<a href="https://kinux98.github.io/assets/pdf/paper.pdf">Same-site PDF</a>',
  '<a href="/cv.pdf" target="_self" rel="author opener">Document</a>',
  '<a href="/" data-target="unchanged" target="_blank">Home</a>'.sub('href="/"', 'href="https://example.org/"')
]

same_tab.each do |source|
  rendered = SiteLinkTargets.rewrite(source)
  check(rendered.include?('target="_self"'), "same-tab link: #{source}")
  check(!rendered.include?('title="Opens in a new tab"'), "obsolete tooltip: #{source}")
  check(SiteLinkTargets.rewrite(rendered) == rendered, "idempotent same-tab: #{source}")
end

new_tab.each do |source|
  rendered = SiteLinkTargets.rewrite(source)
  check(rendered.include?('target="_blank"'), "new-tab link: #{source}")
  check(rendered.include?("noopener") && rendered.include?("noreferrer"), "safe relations")
  check(!rendered.match?(/rel="[^"]*\bopener\b/), "opener removed")
  check(SiteLinkTargets.rewrite(rendered) == rendered, "idempotent new-tab: #{source}")
end

check(SiteLinkTargets.rewrite(new_tab.first).include?("a=1&amp;b=2"), "entities preserved")
check(SiteLinkTargets.rewrite(new_tab.last).include?('data-target="unchanged"'), "data attributes preserved")
[
  '<!-- <a href="/">example</a> -->',
  '<script>const text = \'<a href="/">example</a>\';</script>',
  '<style>/* <a href="/">example</a> */</style>',
  '&lt;a href="/"&gt;example&lt;/a&gt;',
  '<a id="bookmark" data-href="not-a-link">Bookmark</a>'
].each { |source| check(SiteLinkTargets.rewrite(source) == source, "non-navigation unchanged") }

puts "PASS: same-site navigation in current tab, external/documents in new tab; safe link attrs and idempotence."
