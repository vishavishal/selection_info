module SILoader
  module Lib
    #Root path
    RP = File.join(File.dirname(__FILE__))
    FILE_TYPE_STR = "/*.rb"
    TEST_MODE = false
  end
  
  class MySelectionObserver < Sketchup::SelectionObserver
    def onSelectionBulkChange(selection)
      #puts "onSelectionBulkChange: #{selection}"
      ComponentInfo::selection_update
    end
    def onSelectionAdded(selection, entity)
      #puts "onSelectionAdded: #{entity}"
      ComponentInfo::selection_update
    end
    def onSelectionRemoved(selection, entity)
      #puts "onSelectionRemoved: #{entity}"
    end
    def onSelectionCleared(selection)
      #puts "----------------------------------------------------------------"
      #puts "onSelectionCleared : #{selection.to_a} : #{Sketchup.active_model.selection.to_a}"
      if Sketchup.active_model.selection.length == 0
        #ComponentInfo::selection_update
        onSelectionBulkChange(selection)
      end
      #puts "----------------------------------------------------------------"
    end
  end

  module Starters
    extend self

    #Function to load all the ruby files in specified directories
    def load_ruby_files
      ruby_directories = ['core']
      ruby_directories.each do |dir_name|
        dir_path = File.join(SILoader::Lib::RP, dir_name)
        files_to_be_loaded = Dir[dir_path+SILoader::Lib::FILE_TYPE_STR]
        files_to_be_loaded.each { |file_name| 
          Sketchup.load File.join(file_name) 
        }
      end
    end

    # -----------------------------------------------------------------
    # Attach observers here
    # Attached observers
    # 1. Selection
    # -----------------------------------------------------------------
    def attach_observers
     # Attach the observer.
      observers = ObjectSpace.each_object(MySelectionObserver)
      if observers.count == 0
        selection_observer = MySelectionObserver.new
        Sketchup.active_model.selection.add_observer(selection_observer)
      end
    end

    #----------------------------------------------------------------------------------------
    # The main function to start the extension 
    # Keep it at end
    def start_extension
      # Load ruby files
      load_ruby_files

      # Attach observers
      attach_observers

      #Create dialog
      SelectionInfoDialog::create_dialog
      SelectionInfoDialog::add_callbacks
    end
    #----------------------------------------------------------------------------------------

  end

end

#Load all ruby files
SILoader::Starters::start_extension