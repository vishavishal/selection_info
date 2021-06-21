#----------------------------------------------------------------------------------
#  CopyRight : Vivek Gnanasekaran
#----------------------------------------------------------------------------------

module VG_SITool_V1  

  #Observer for the Selection entity
  class MySelectionObserver < Sketchup::SelectionObserver
    def onSelectionBulkChange(selection)
      puts "onSelectionBulkChange : #{selection.to_a} : #{Sketchup.active_model.selection.to_a}"
      ComponentInfo::selection_update
      #ComponentInfo::get_active_dict_name
      puts "Menu 2: #{SelectionInfoDialog.active_menu_item}"
    end
    def onSelectionCleared(selection)
      puts "onSelectionCleared : #{selection.to_a} : #{Sketchup.active_model.selection.to_a}"
      ComponentInfo::selection_update
    end
  end

end