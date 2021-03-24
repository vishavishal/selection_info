#----------------------------------------------------------------------------------
#  CopyRight : Vivek Gnanasekaran
#  Main module containing the functions for the Component details of the selection
#
#----------------------------------------------------------------------------------

module VG_SITool_V1

  module ComponentInfo
    #Get all the attribute details
    def self.get_attribute_dict_details comp
      result_h = {}
      return {} if comp.nil? || comp.attribute_dictionaries.nil?
      comp.attribute_dictionaries.each {|attr_dict|
        dict_name = attr_dict.name
        result_h[dict_name] = attr_dict.to_h
      }

      result_h["rio_materials"]["image"] = [nil] if result_h["rio_materials"]
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
            "height":     comp_bounds.depth,
            "width":      comp_bounds.width,
            "depth":      comp_bounds.height,
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
      #puts "get_comp_details..#{comp}"
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
      #puts "Comp details : #{comp} : #{comp_details_h}"
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
      SelectionInfoDialog.active_menu_item = item
    end

    def self.get_active_dict_name
      #puts "get_active_dict_name"
      script_str = "getActiveMenu()";
      SelectionInfoDialog.dialog.execute_script(script_str);
      SelectionInfoDialog.active_menu_item
    end

    def self.selection_update comp=nil
      #puts "Selection update : #{SelectionInfoDialog.active_menu_item} : #{Sketchup.active_model.selection.length}"
      
      return unless SelectionInfoDialog.dialog
      if Sketchup.active_model.selection.empty?
        comp = Sketchup.active_model
        comp_details_h = {
          "attr_dicts":   get_attribute_dict_details(comp)
        }
        output_json = comp_details_h.to_json

        html_str    = ComponentInfo::convert_json_to_html output_json

        #puts "Inside ... selupdate"
        active_dict_name = get_active_dict_name
        #$dict_to_be_updated = false

        script_str = "refresh(\"#{html_str}\")";
        SelectionInfoDialog.dialog.execute_script(script_str);
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

        # if $dict_to_be_updated == true
        #   active_dict_name = get_active_dict_name 
        #   $dict_to_be_updated = false
        # end
        script_str = "refresh(\"#{html_str}\")";
        SelectionInfoDialog.dialog.execute_script(script_str);
      end
      #$dict_to_be_updated = true
    end
  end

end

if VG_SITool_V1::TEST_MODE
  time = Time.now
  time_str = "%s:%s" % [time.min, time.sec]
  menu_item = "VG Selection Info #{time_str}"
  UI.menu('Plugins').add_item(menu_item){ VG_SITool_V1::SelectionInfoDialog::open }
else
  UI.menu('Plugins').add_item('VG Selection Info'){ VG_SITool_V1::SelectionInfoDialog::open }
end