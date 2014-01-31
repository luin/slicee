require 'psd'
require 'fileutils'
require 'optparse'

options = {}
file = ARGV.pop
OptionParser.new do |opts|
  opts.banner = "Usage: slicee.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-g", "--only-groups", "Only export groups") do |v|
    options[:only_groups] = v
  end

  opts.on("-l", "--only-layers", "Only export layers") do |v|
    options[:only_layers] = v
  end

  opts.on_tail("--version", "Show version") do
    puts ::Version.join('.')
    exit
  end
end.parse!

FileUtils.mkdir_p("output")


psd = PSD.new(file)
psd.parse!

unless options[:only_layers]
  psd.tree.descendant_groups.each do |group|
    if group.name =~ /\.png/
      if options[:verbose]
        p "Processing group: #{group.name}"
      end
      group.to_png.crop!(group.left,
                         group.top,
                         group.width,
                         group.height).save "output/#{group.name}"
    end
  end
end

unless options[:only_groups]
  psd.tree.descendant_layers.each do |layer|
    if layer.name =~ /\.png/
      if options[:verbose]
        p "Processing layer: #{layer.name}"
      end
      layer.save_as_png "output/#{layer.name}"
    end
  end
end
