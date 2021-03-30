#----------------------------------------------------------------------------------
#  CopyRight : Vivek Gnanasekaran
#----------------------------------------------------------------------------------
require_relative 'core/observers.rb' #For loading observer 

module VG_SITool_V1

  #--------------- Constants       ----------------------------------------------
  
  # To avoid direct __FILE__ usage bug
  file = __FILE__.dup
  file.force_encoding('UTF-8') if file.respond_to?(:force_encoding)
  ROOT_PATH       = File.dirname(file) unless defined?(ROOT_PATH)

  FILE_TYPE_STR   = "/*.rb"
  TEST_MODE       = false
  #------------------------------------------------------------------------------
  

  module Starters
    extend self

    #Function to load all the ruby files in specified directories
    def load_ruby_files
      ruby_directories = ['core']
      ruby_directories.each do |dir_name|
        dir_path = File.join(ROOT_PATH, dir_name)
        files_to_be_loaded = Dir[dir_path+FILE_TYPE_STR]
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
    end
    #----------------------------------------------------------------------------------------

  end
end

#Load all ruby files
VG_SITool_V1::Starters::start_extension