# inspired by https://euandre.org/til/2020/08/13/anchor-headers-and-code-lines-in-jekyll.html

Jekyll::Hooks.register :pages, :post_render do |doc|
  if doc.output_ext == ".html"
    doc.output =
      doc.output.gsub(
        /<h([1-6])(.*?)id="([\w-]+)"(.*?)>(.*?)<\/h[1-6]>/,
        '<h\1\2id="\3"\4>\5<a href="#\3" class="headerlink" title="Link to this heading"><emoji>🔗</emoji></a></h\1>'
      )
  end
end
