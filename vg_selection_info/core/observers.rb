#----------------------------------------------------------------------------------
#  CopyRight : Vivek Gnanasekaran
#----------------------------------------------------------------------------------

module VG_SITool_V1  

  #Observer for the Selection entity
  class MySelectionObserver < Sketchup::SelectionObserver
    def onSelectionBulkChange(selection)
      ComponentInfo::selection_update
    end
    def onSelectionAdded(selection, entity)
      ComponentInfo::selection_update
    end
    def onSelectionCleared(selection)
      #puts "onSelectionCleared : #{selection.to_a} : #{Sketchup.active_model.selection.to_a}"
      onSelectionBulkChange(selection)
    end
  end

end