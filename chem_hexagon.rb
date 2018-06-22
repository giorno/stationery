#!/usr/bin/ruby

require_relative 'svg/src/style'
require_relative 'svg/src/svg'

require_relative 'style'
require_relative 'tag'

module Io module Creat module Stationery

  # Generates the layout of adjacent hexagons for drawing organic chemistry
  # C-chains and C-rings.
  class ChemHexagon

    public
    def initialize(width_mm, height_mm, border_mm, radius_mm, thickness_mm)
      @width_mm = width_mm # SVG document width
      @height_mm = height_mm # SVG document height
      @border_mm = border_mm # offset of active graphics from the document borders
      @radius_mm = radius_mm # radius of the circe a single hexagon is inscribed in
      @thickness_mm = thickness_mm
      @style = Style::LINE.merge({ :stroke_width => @thickness_mm})

      # SVG document
      @img = Io::Creat::Svg.new({:width => "%d" % @width_mm, :height => "%d" % @height_mm})
    end # initialize

    #
    #  |
    # / \
    private
    def star(x_mm, y_mm)
      # corrections for joining stars
      bdx_mm = @thickness_mm / 4 # horizontal correction of the bottom arms endpoints
      bdy_mm = @thickness_mm / (4 * Math.sqrt(3)) # vertical correction of the bottom arms endpoints
      tdy_mm = (Math.cos(Math::PI / 6) - 1 / (2 * Math.sqrt(3))) * @thickness_mm / 2

      # top arm
      if y_mm > @border_mm and y_mm < @height_mm - @border_mm and y_mm - @radius_mm > @border_mm and y_mm - @radius_mm < @height_mm - @border_mm then
        @img.line(x_mm, y_mm + tdy_mm, x_mm, y_mm - @radius_mm - tdy_mm, @style)
      end
      w_mm = @radius_mm * Math.cos(Math::PI / 6);

      # left arm
      if x_mm - w_mm >= @border_mm then
        @img.line(x_mm + bdx_mm, y_mm - bdy_mm, x_mm - w_mm - bdx_mm, y_mm + @radius_mm * Math.sin(Math::PI / 6) + bdy_mm, @style)
      end

      # right arm
      if x_mm + w_mm <= @width_mm - @border_mm then
        @img.line(x_mm - bdx_mm, y_mm - bdy_mm, x_mm + w_mm + bdx_mm, y_mm + @radius_mm * Math.sin(Math::PI / 6) + bdy_mm, @style)
      end
    end # star

    public
    def render()
      h_mm = @radius_mm * (1 + Math.sin(Math::PI / 6))
      w_mm = 2 * @radius_mm * Math.cos(Math::PI / 6)
      step_mm = w_mm
      y_mm = @border_mm + step_mm / 2 - h_mm / 2
      while y_mm < @height_mm - @border_mm do
        x_mm = @border_mm + step_mm / 2
        while x_mm < @width_mm - @border_mm do
          star(x_mm, y_mm)
          star(x_mm - step_mm / 2, y_mm + h_mm)
          x_mm += step_mm
        end
        star(x_mm - step_mm / 2, y_mm + h_mm)
        y_mm += 2 * h_mm
        x_mm = step_mm / 2
      end

      # branding
      Tag.new(@img, @width_mm / 2, @height_mm - @border_mm + 1, 50, 2.5, 0.2, Style::BRAND + " ORGANIC CHEMISTRY HEXAGONAL GRID", Style::BRANDING)

      output = ''
      @img.write(output)
      return output
    end # render

  end # ChemHexagon

end # ::Stationery
end # ::Creat
end # ::Io

chem_hexagon = Io::Creat::Stationery::ChemHexagon.new(210, 297, 5, 6.4, 0.5)
puts chem_hexagon.render()

