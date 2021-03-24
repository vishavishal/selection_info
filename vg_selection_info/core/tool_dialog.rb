module VG_SITool_V1
  
  module SelectionInfoDialog 
    extend self
    attr_reader :dialog

    def open
      @dialog = create_dialog() if @dialog.nil?
      add_callbacks
      @dialog.show
    end

    def close
      @dialog.close unless @dialog.nil?
      @dialog = nil
    end

    def create_dialog
      sel_info_dialog = UI::HtmlDialog.new({:dialog_title=>"VG Selection Info",
        :scrollable=>true,
        :resizable=>true,
        :style=>UI::HtmlDialog::STYLE_DIALOG
      })
      html_file_path = File.join(ROOT_PATH, "web", "component_info.html")
      sel_info_dialog.set_file(html_file_path)
      sel_info_dialog.set_size(1000, 500)
      sel_info_dialog.set_position(0,0)
      sel_info_dialog.center

      sel_info_dialog
    end

    def add_callbacks
      @dialog.add_action_callback("getCompDetails") {|dialog, params|
        #puts "CB : getCompDetails : #{params} : #{Sketchup.active_model.selection[0]}"
      
        resp = ComponentInfo::get_comp_details Sketchup.active_model.selection[0]
        output_json = resp.to_json
      
        html_str    = ComponentInfo::convert_json_to_html output_json
        script_str = "refresh(\"#{html_str}\")";
        @dialog.execute_script(script_str);
      }
      
      @dialog.add_action_callback("getTableData") {|dialog, params|
        #puts "CB : getTableData : #{params}"
        inputs = JSON.parse(params)
        #puts "Inputs :#{inputs}"
        table_html = ComponentInfo::get_table_data inputs
        #puts "Table html : #{table_html}"
        script_str = "refreshDictData(\"#{table_html}\")";
        @dialog.execute_script(script_str);
      }
      
      @dialog.add_action_callback("setActiveMenu"){ |dialog, params|
        inputs = JSON.parse(params)
        puts "Inputs setActiveMenu : #{inputs}"
        $active_menu_item = inputs["attr_name"]
        script_str = "setActiveMenuItem(\"#{$active_menu_item}\")";
        @dialog.execute_script(script_str);
      }    

    end
  end
end