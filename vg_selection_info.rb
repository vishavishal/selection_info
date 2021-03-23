require "sketchup.rb"
require "extensions.rb"


current_folder        = File.join(File.dirname(__FILE__))
VG_SELTOOL_ROOT_PATH 	= File.join(current_folder, 'vg_selection_info')

loader_path           = File.join(VG_SELTOOL_ROOT_PATH, "selection_info_loader.rb")
vg_extension_title    = "VG - Selection Info"

my_plugin_loader              = SketchupExtension.new(vg_extension_title, loader_path)
my_plugin_loader.copyright    = "Copyright 2021 VG"
my_plugin_loader.creator      = "VG"
my_plugin_loader.version      = "1.0.0"
my_plugin_loader.description  = "Info of the Selected entity."

Sketchup.register_extension my_plugin_loader, true