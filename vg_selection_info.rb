require "sketchup.rb"
require "extensions.rb"


current_folder        = File.join(File.dirname(__FILE__))
core_path 	          = File.join(current_folder, 'vg_selection_info')

#------------ Set temp Paths here -------------------------------------
dev_env = true
if dev_env
  core_path             = 'E:\Extensions\selection_info\vg_selection_info'
end
#----------------------------------------------------------------------

loader_path           = File.join(core_path, "selection_info_loader.rb")
vg_extension_title    = "VG - Selection Info"

my_plugin_loader              = SketchupExtension.new(vg_extension_title, loader_path)
my_plugin_loader.copyright    = "Copyright 2021 VG"
my_plugin_loader.creator      = "Vivek Gnanasekaran"
my_plugin_loader.version      = "1.0.0"
my_plugin_loader.description  = "Info of the Selected entity."

Sketchup.register_extension my_plugin_loader, true