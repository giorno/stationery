
module Io module Creat module Stationery

  module Style

    LINE = { :stroke_width => 0.1, :stroke => "black", :fill => "none" }
    BRANDING_FRAME = LINE.merge({ :fill => "black" })
    BRANDING_TEXT = { :fill => "white", :"font-size" => 2.4, :"font-family" => "Iosevka" }

    BRANDING = { :frame => BRANDING_FRAME, :text => BRANDING_TEXT }

    BRAND = "CREAT.IO"

  end # ::Style

end # ::Stationery
end # ::Creat
end # ::Io

