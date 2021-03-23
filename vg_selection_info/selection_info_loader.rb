#----------------------------------------------------------------------------------
#  CopyRight : Vivek Gnanasekaran
#  Main module containing the functions for the Component details of the selection
#
#----------------------------------------------------------------------------------

module ComponentInfo
  #Get all the attribute details
  def self.get_attribute_dict_details comp
    result_h = {}
    return {} if comp.nil? || comp.attribute_dictionaries.nil?
    comp.attribute_dictionaries.each {|attr_dict|
      dict_name = attr_dict.name
      result_h[dict_name] = attr_dict.to_h
    }
    result_h
  end

  #Get the component dimensions
  def self.get_component_info comp
    result_h = {}
    return {} unless comp
    case comp
    when Sketchup::ComponentInstance, Sketchup::Group
      comp_bounds   = comp.definition.bounds
      comp_trans    = comp.transformation

      result_h = {"comp_details": {
          "name":       comp.definition.name,
          "height":     comp_bounds.height,
          "width":      comp_bounds.width,
          "depth":      comp_bounds.depth,
          "origin":     comp_trans.origin,
          "layer":      comp.layer.name,
        }

      }
    when Sketchup::Face
      result_h = {"comp_details": {
        "Layer":      comp.layer.name,
        "Area":       comp.area,
        "Edges":      comp.edges.length,
        "Vertices":   comp.vertices.length,
      }
    }
    else
    end
    result_h
  end

  def self.get_comp_details comp=nil
    seln = Sketchup.active_model.selection
    if comp
      comp_details_h = {
        "comp_info":    get_component_info(comp),
        "attr_dicts":   get_attribute_dict_details(comp)
      }
    elsif seln.length > 0
      comp = seln[0]
      comp_details_h = {
        "comp_info":    get_component_info(comp),
        "attr_dicts":   get_attribute_dict_details(comp)
      }
    else
      comp = Sketchup.active_model
      comp_details_h = {
        "attr_dicts":   get_attribute_dict_details(comp)
      }
      #output_json = comp_details_h
    end
    comp_details_h
  end

  def self.get_side_bar_str input
    html_str = ""
    input.keys.each {|main_key|
      input[main_key].keys.each {|json_key|
        # side_str = "<li class='side_menu_item' name='#{json_key}'>"
        side_str = "<a href='#' class='side-menu-item' id='#{json_key}' name='#{json_key}'>#{json_key}</a></li>"
        html_str += side_str
      }
    }
    html_str
  end

  def self.get_table_data inputs
    #puts "get_table_data : #{inputs}"
    if Sketchup.active_model.selection.length == 0
      comp = Sketchup.active_model
      comp_details_h = {
        "attr_dicts":   get_attribute_dict_details(comp)
      }
      output_json = comp_details_h
    else
      output_json = ComponentInfo::get_comp_details Sketchup.active_model.selection[0]
    end

    table_html = "<table style='position: absolute; width: 100%;'><tr style='background:#f94b4bfa;color:white;'><th style='width:30%;'>Key</th><th>Value</th></tr>"

    table_name = inputs["attr_name"]
    #puts "output_json : #{output_json}"
    output_json.keys.each{|out_key|
      #puts "out_key : #{out_key} : #{table_name} : #{output_json[out_key]}"
      dict = output_json[out_key][table_name] || output_json[out_key][table_name.to_sym]
      if dict
        #puts "Dict present"
        dict.each_pair{|k, v|
          table_html += "<tr><td>#{k}</td><td>#{v}</td></tr>"
        }
        break
      end
    }
    table_html += "</table>"
    return table_html
  end

  def self.convert_json_to_html json_input

    #puts "json_input : #{json_input}"
    return "" if json_input.empty?
    input = JSON.parse(json_input)

    side_bar_str = get_side_bar_str input

    html_str = side_bar_str
    return html_str
  end

  def self.set_active_dict_name item
    $active_menu_item = item
  end

  def self.get_active_dict_name
    #puts "get_active_dict_name"
    script_str = "getActiveMenu()";
    $compDialog.execute_script(script_str);
    $active_menu_item
  end

  def self.selection_update comp=nil
    #puts "Selection update : #{comp} : #{Sketchup.active_model.selection.length}"
    if Sketchup.active_model.selection.empty?
      comp = Sketchup.active_model
      comp_details_h = {
        "attr_dicts":   get_attribute_dict_details(comp)
      }
      output_json = comp_details_h.to_json

      html_str    = ComponentInfo::convert_json_to_html output_json

      #puts "Inside ... selupdate"
      active_dict_name = get_active_dict_name
      script_str = "refresh(\"#{html_str}\")";
      $compDialog.execute_script(script_str);
    else
      if comp.nil?
        seln = Sketchup.active_model.selection
        comp = seln.length > 0 ? seln[seln.length-1] : Sketchup.active_model
      end
      #puts "Comp : #{comp}"

      if comp.is_a?(Sketchup::Model)
        comp_details_h = {
          "attr_dicts":   get_attribute_dict_details(comp)
        }
        output_json = comp_details_h.to_json
      else

        resp = ComponentInfo::get_comp_details comp
        output_json = resp.to_json
      end
      #puts "Selection update : output_json : #{output_json}"
      html_str    = ComponentInfo::convert_json_to_html output_json

      #active_dict_name = get_active_dict_name
      script_str = "refresh(\"#{html_str}\")";
      $compDialog.execute_script(script_str);
    end
  end
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

# Attach the observer.
if $selection_observer.nil?
  $selection_observer = MySelectionObserver.new
  Sketchup.active_model.selection.add_observer($selection_observer)
end

module SelectionInfoDialog
  extend self
  def create_dialog
    $compDialog = UI::HtmlDialog.new({:dialog_title=>"VG Selection Info",
      :scrollable=>true,
      :resizable=>true,
      :style=>UI::HtmlDialog::STYLE_DIALOG
    })
    html_file_path = File.join(VG_SELTOOL_ROOT_PATH, "web", "component_info.html")
    $compDialog.set_file(html_file_path)
    $compDialog.set_size(1000, 500)
    $compDialog.set_position(0,0)
    $compDialog.center
    $compDialog.show
    
    $compDialog.add_action_callback("getCompDetails") {|dialog, params|
      #puts "CB : getCompDetails : #{params} : #{Sketchup.active_model.selection[0]}"
    
      resp = ComponentInfo::get_comp_details Sketchup.active_model.selection[0]
      output_json = resp.to_json
    
      html_str    = ComponentInfo::convert_json_to_html output_json
      script_str = "refresh(\"#{html_str}\")";
      $compDialog.execute_script(script_str);
    }
    
    $compDialog.add_action_callback("getTableData") {|dialog, params|
      #puts "CB : getTableData : #{params}"
      inputs = JSON.parse(params)
      table_html = ComponentInfo::get_table_data inputs
      script_str = "refreshDictData(\"#{table_html}\")";
      $compDialog.execute_script(script_str);
    }
    
    $compDialog.add_action_callback("setActiveMenu"){ |dialog, params|
      inputs = JSON.parse(params)
      #puts "Inputs setActiveMenu : #{inputs}"
      $active_menu_item = inputs["attr_name"]
      script_str = "setActiveMenuItem(\"#{$active_menu_item}\")";
      $compDialog.execute_script(script_str);
    }    
  end
end

UI.menu('Plugins').add_item('VG Selection Info'){ SelectionInfoDialog::create_dialog }