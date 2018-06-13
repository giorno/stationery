#!/usr/bin/ruby

require_relative 'svg/src/style'
require_relative 'svg/src/svg'

module Io module Creat module Stationery

  # Orthogonal mesh of 8mm x 8mm squares.
  class Grid

    public
    def initialize(width_mm, height_mm, border_mm, step_mm, thickness_mm)
      @width_mm = width_mm # SVG document width
      @height_mm = height_mm # SVG document height
      @border_mm = border_mm # offset of active graphics from the document borders
      @step_mm = step_mm # cell size
      @thickness_mm = thickness_mm
      @style = { :stroke_width => @thickness_mm, :stroke => "black", :fill => "none" }

      # SVG document
      @img = Io::Creat::Svg.new({:width => "%d" % @width_mm, :height => "%d" % @height_mm})
    end # initialize

    public
    def render()
      x_mm = @border_mm
      y_mm = @border_mm + @step_mm * ( ( @height_mm - 2 * @border_mm ) / @step_mm ).round
      
      while x_mm <= @width_mm - @border_mm do
        @img.line(x_mm, @border_mm - @thickness_mm / 2, x_mm, y_mm + @thickness_mm / 2, @style)
        x_mm += @step_mm
      end
      y_mm = @border_mm
      while y_mm <= @height_mm - @border_mm do
        @img.line(@border_mm - @thickness_mm / 2, y_mm, @width_mm - @border_mm + @thickness_mm / 2, y_mm, @style)
        y_mm += @step_mm
      end
      output = ''
      @img.write(output)
      return output
    end # render

  end # Grid

end # ::Stationery
end # ::Creat
end # ::Io

grid = Io::Creat::Stationery::Grid.new(210, 297, 5, 8, 0.7)
puts grid.render()

