#!/usr/bin/ruby

require_relative 'svg/src/style'
require_relative 'svg/src/svg'

module Io module Creat module Stationery

  # Generates the layout of adjacent hexagons for drawing organic chemistry
  # C-chains and C-rings.
  class ChemHexagon

    public
    def initialize(width_mm, height_mm, radius_mm, thickness_mm)
      @width_mm = width_mm # SVG document width
      @height_mm = height_mm # SVG document height
      @radius_mm = radius_mm # radius of the circe a single hexagon is inscribed in
      @thickness_mm = thickness_mm
      @style = { :stroke_width => @thickness_mm, :stroke => "black", :fill => "none" }

      # SVG document
      @img = Io::Creat::Svg.new({:width => "%d" % @width_mm, :height => "%d" % @height_mm})
    end # initialize

    #
    #  |
    # / \
    private
    def star(x_mm, y_mm)
      @img.line(x_mm, y_mm, x_mm, y_mm - @radius_mm, @style)
      @img.line(x_mm, y_mm, x_mm - @radius_mm * Math.cos(Math::PI / 6), y_mm + @radius_mm * Math.sin(Math::PI / 6), @style)
      @img.line(x_mm, y_mm, x_mm + @radius_mm * Math.cos(Math::PI / 6), y_mm + @radius_mm * Math.sin(Math::PI / 6), @style)
    end # star

    public
    def render()
      h_mm = @radius_mm * (1 + Math.sin(Math::PI / 6))
      step_mm = 2 * @radius_mm * Math.cos(Math::PI / 6)
      $stderr.puts step_mm
      x_mm = step_mm / 2
      y_mm = step_mm / 2
      while y_mm < @height_mm do
        while x_mm < @width_mm do
          star(x_mm, y_mm)
          star(x_mm - step_mm / 2, y_mm + h_mm)
          x_mm += step_mm
        end
        y_mm += 2 * h_mm
        x_mm = step_mm / 2
      end
      output = ''
      @img.write(output)
      return output
    end # render

  end # ChemHexagon

end # ::Stationery
end # ::Creat
end # ::Io

chem_hexagon = Io::Creat::Stationery::ChemHexagon.new(210, 297, 6.3, 0.1)
puts chem_hexagon.render()

