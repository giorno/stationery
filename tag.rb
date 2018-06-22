
require_relative 'svg/src/svg'

module Io module Creat module Stationery

  # Generates tag with branding information.
  class Tag

    def initialize(img, x_mm, y_mm, w_mm, h_mm, r_mm, text, style)
      @img = img # SVG document to draw on
      @x_mm = x_mm
      @y_mm = y_mm
      @w_mm = w_mm
      @h_mm = h_mm
      @r_mm = r_mm
      @text = text
      @style = style # { :line =>, :text }
      render
    end # initialize

    def render
      fs_mm = @h_mm

      @img.rectangle(@x_mm - @w_mm / 2, @y_mm - @h_mm, @w_mm, @h_mm, @r_mm, @style[:line])
      @img._text(@x_mm, @y_mm - 0.15 * fs_mm, @text, @style[:text].merge({:"text-anchor" => "middle"}))
    end # render

  end # Tag

end # ::Stationery
end # ::Creat
end # ::Io
