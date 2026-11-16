# frozen_string_literal: true

require "cgi"

# Apply the link policy after Markdown and layouts are rendered. Keep comments,
# raw script/style content and escaped code examples intact. No browser JS needed.
module SiteLinkTargets
  TAG_BODY = /(?:[^>"']|"[^"]*"|'[^']*')*/.source.freeze
  TOKENS = Regexp.new("<!--.*?-->|<(script|style)\\b#{TAG_BODY}>.*?</\\1\\s*>|<a\\b#{TAG_BODY}>", Regexp::IGNORECASE | Regexp::MULTILINE)
  ATTRIBUTE = /([^\s=\/>]+)(?:\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+)))?/.freeze

  def self.rewrite(html)
    html.gsub(TOKENS) do |token|
      next token unless token.match?(/\A<a(?:\s|>)/i)
      attributes = {}
      token.sub(/\A<a\b/i, "").sub(/>\z/, "").scan(ATTRIBUTE) do |name, double, single, bare|
        value = double || single || bare
        attributes[name.downcase] = value.nil? ? nil : CGI.unescapeHTML(value)
      end
      next token unless attributes.key?("href")
      # The skip control moves keyboard focus; it must not open another page.
      if attributes.fetch("class", "").to_s.split.include?("skip-link") && attributes["href"] == "#main-content"
        attributes["target"] = "_self"
      else
        attributes["target"] = "_blank"
        relations = attributes.fetch("rel", "").to_s.downcase.split - ["opener"]
        attributes["rel"] = (relations + %w[noopener noreferrer]).uniq.join(" ")
        attributes["title"] = "Opens in a new tab" if attributes.fetch("title", "").to_s.empty?
      end
      rendered = attributes.map { |name, value| value.nil? ? name : %(#{name}="#{CGI.escapeHTML(value)}") }.join(" ")
      "<a #{rendered}>"
    end
  end
end

if defined?(Jekyll::Hooks)
  Jekyll::Hooks.register [:pages, :documents], :post_render do |document|
    next unless document.output_ext == ".html"
    document.output = SiteLinkTargets.rewrite(document.output)
  end
end
