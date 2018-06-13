task :default => :build

task :build => [:pdf]

rb_files = Rake::FileList.new()
rb_files.include("chem_hexagon.rb")

svg_files = Rake::FileList.new("/*.svg")

puts rb_files.ext(".svg")
task :pdf => rb_files.ext(".svg")

rule ".svg" => ".rb" do |file|
  sh "./#{file.source} | sed -e 's/\" height=/mm\" height=/' -e 's/\" viewBox=/mm\" viewBox=/' | xmllint --format - > ./#{file.name}"
  sh "/Applications/Inkscape.app/Contents/Resources/bin/inkscape -z -A $PWD/#{file.name}.pdf $PWD/#{file.name}"
end

