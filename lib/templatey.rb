module Templatey
  def h(text)
    CGI.escapeHTML(text.to_s)
  end
end
