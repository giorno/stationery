#!/usr/bin/ruby

require 'date'
require 'json'

require_relative 'svg/src/style'
require_relative 'svg/src/svg'

module Io module Creat module Stationery

  # Generates a vertical timeline of events.
  class Timeline
    COLORS = ['#e53935', '#5C6BC0', '#26A69A', '#689F38', '#F57F17', '#A1887F', '#78909C']

    public
    def initialize(width_mm, height_mm, thickness_mm, events, inverted = false, compact = false)
      @width_mm = width_mm # SVG document width
      @height_mm = height_mm # SVG document height
      @thickness_mm = thickness_mm
      @events = events
      @inverted = inverted
      @compact = compact # whether to reduce long vertical whitespace
      @dim = {
        :radius_mm => 5.0,
      }
      @color_idx = 0 # index in COLOR
    end # initialize

    def render
      @fh_mm = @dim[:radius_mm] # title font height
      clear = 6.0 # number of blank lines reserved for clear space
      @border_mm = 2.0 * @dim[:radius_mm]

      # pre-processing
      last_ts = 0
      last = nil
      @density_1sec = 0
      #artificial = @inverted ? {} : {'99' => { :date => Date.today.strftime("%Y-%m-%d"), :title => '' } }
      artificial = {'99' => { "date" => Date.today.strftime("%Y-%m-%d"), :title => '' } }
      @events.merge(artificial).each_pair do |label, event|
        ts = Date.parse(event["date"]).to_time.to_f
        # forward to the first one
        if last_ts == 0 then
          last_ts = ts
          last = event
          next
        end
        event_count = (last.include? "list") ? last["list"].length : 0
        if @inverted then
          event_count = (event.include? "list") ? event["list"].length : 0
        end
        event_count += clear
        # dansiest content calculation -> density of events per time unit
        if event_count / (ts - last_ts) > @density_1sec then
          @density_1sec = event_count / (ts - last_ts)
        end
        last_ts = ts
        last = event
      end # @events
      #@density_1sec /= 2
      
      # calculate the document height
      @height_mm = 2 * @border_mm
      last_ts = 0
      trailing_mm = 0
      @events.merge(artificial).each_pair do |label, event|
        ts = Date.parse(event["date"]).to_time.to_f
        # forward to the first one
        if last_ts == 0 then
          last_ts = ts
          next
        end
        #ny_mm = @density_1sec * @rh_mm * (ts - last_ts)
        ny_mm = height(((event.include? "list") ? event["list"].length : 0) , (ts - last_ts))
        @height_mm += ny_mm
        last_ts = ts
        if @inverted
          trailing_mm = -ny_mm + @border_mm
        end
      end

      # create SVG document
      @img = Io::Creat::Svg.new({:width => "%d" % @width_mm, :height => "%d" % @height_mm})
      mult = @inverted ? -1 : 1
      ny_mm = yy_mm = -trailing_mm # relative vertical coordinate
      last_ts = 0
      last_label = ''
      last = nil
      x_mm = @border_mm + @dim[:radius_mm]
      @events.merge(artificial).each_pair do |label, event|
        ts = Date.parse(event["date"]).to_time.to_f
        y_mm = (@inverted ? @height_mm : 0) + mult * (@border_mm + yy_mm + @dim[:radius_mm])
        # forward to the first one
        if last_ts == 0 then
          last_ts = ts
          last = event
          last_label = label
          if @inverted then
              @img.pline x_mm, y_mm, x_mm, @height_mm - @border_mm, { :stroke_width => @thickness_mm }, "1, 1"
          end
          next
        end
        ny_mm = height((((last != nil) and last.include? "list") ? last["list"].length : 0) , (ts - last_ts))
        if @inverted then
          ny_mm = height(((event.include? "list") ? event["list"].length : 0) , (ts - last_ts))
        end
        if not @inverted or label != '99' then
          @img.pline x_mm, y_mm, x_mm, y_mm + mult * ny_mm, { :stroke_width => @thickness_mm }, "1, 1"
        end

        milestone x_mm, y_mm, last_label, (last.include? "minor") ? last["minor"] : false
        @img.text x_mm + @dim[:radius_mm] / 2 + @fh_mm, y_mm + @fh_mm / 1.8, {:"font-family" => "Oswald", :fill => "black", :"font-size" => @fh_mm} { raw last["title"] }
        @img.text x_mm + @dim[:radius_mm] / 2 + @fh_mm, y_mm - @fh_mm / 1.5, {:"font-family" => "Roboto", :fill => "black", :"font-size" => @fh_mm / 2} { raw Date.parse(last["date"]).strftime("%-d %b, %Y") }
        if last.include? "list" then
          ry_mm = y_mm + 3.7 * @fh_mm / 2.1
          last["list"].each do |item|
            @img.text x_mm + @dim[:radius_mm] / 2 + @fh_mm, ry_mm, {:"font-family" => "Roboto", :fill => "black", :"font-size" => @fh_mm / 2} { raw item }
            ry_mm += @fh_mm / 1.6
          end # last[:list]
        end
        yy_mm += ny_mm
        last_ts = ts
        last = event
        last_label = label
      end # @events
      output = ''
      @img.write(output)
      return output
    end # render

    def milestone(x_mm, y_mm, label, minor = false)
      radius_mm = @dim[:radius_mm] * (minor ? 0.5 : 0.75)
      fh_mm = radius_mm * 0.75
      @img.circle x_mm, y_mm, radius_mm, {:fill => color(label), :stroke => 'none' }
      @img.text x_mm, y_mm + fh_mm / 2.2 , {:"font-family" => "Oswald", :fill => "#ffffff", :"font-size" => fh_mm, :"text-anchor" => "middle"} { raw label }
    end # milestone

    def color(label)
      @color_idx += 1
      return COLORS[@color_idx % COLORS.length]
    end # color

    def height(length, delta_sec)
      ny_mm = @density_1sec * @fh_mm * delta_sec / 1.6
      # avoid too big gaps
      if @compact then
        ny_mm = [ny_mm, 2 * (length + 6) * @fh_mm / 1.6].min
      end
      return ny_mm
    end # height

  end # Timeline

end # ::Stationery
end # ::Creat
end # ::Io

if ARGV.length < 1 then
  $stderr.puts "Provide a JSON file with data!"
  exit
end 

handle = open ARGV[0]
plain = handle.read
handle.close

timeline = Io::Creat::Stationery::Timeline.new(100, 297, 0.3, JSON.parse(plain), true, true)
puts timeline.render()

