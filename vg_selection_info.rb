require 'sketchup.rb'
require 'extensions.rb'

module VG_SITool_V1
  unless file_loaded?(__FILE__)
    loader_path           = File.join('vg_selection_info', "selection_info_loader.rb")
    vg_extension_title    = "VG - Selection Info"

    my_plugin_loader              = SketchupExtension.new(vg_extension_title, loader_path)
    my_plugin_loader.copyright    = "Copyright 2021 VG"
    my_plugin_loader.creator      = "Vivek Gnanasekaran"
    my_plugin_loader.version      = "1.0.0"
    my_plugin_loader.description  = "Info of the Selected entity."

    Sketchup.register_extension my_plugin_loader, true
    file_loaded(__FILE__)
  end
end