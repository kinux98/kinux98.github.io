# frozen_string_literal: true

require "cgi"
require "uri"

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
      href = attributes["href"].to_s.strip
      begin
        uri = URI.parse(href)
        same_site = (uri.host.nil? || uri.host.downcase == "kinux98.github.io") &&
                    (uri.scheme.nil? || %w[http https].include?(uri.scheme.downcase))
        path = uri.path.to_s.downcase
        html_navigation = path.empty? || path.end_with?("/", ".html", ".htm") ||
                          !File.basename(path).include?(".")
        internal_navigation = same_site && html_navigation
      rescue URI::InvalidURIError
        internal_navigation = false
      end

      if internal_navigation
        # Same-site navigation (including section anchors) must reuse the tab.
        attributes["target"] = "_self"
        attributes.delete("title") if attributes["title"] == "Opens in a new tab"
        relations = attributes.fetch("rel", "").to_s.downcase.split - %w[noopener noreferrer opener]
        relations.empty? ? attributes.delete("rel") : attributes["rel"] = relations.join(" ")
      else
        # External destinations and documents such as PDFs open separately.
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
