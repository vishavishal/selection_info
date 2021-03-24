#---------------------------------------------------------------------------
# Get the internal component and all entities within an entity
#---------------------------------------------------------------------------
module EntityInternalDetails
  extend self
  @@inner_entities_h={}
  
  def recurse_internal_entities_old input_ent
    case input_ent
    when Sketchup::ComponentInstance
      comp_name = input_ent.definition.name || "Comp_%s" % [input_ent.persistent_id.to_s]

      @@inner_entities_h[comp_name]=input_ent.definition.entities.to_a
      input_ent.definition.entities.each{|ent| recurse_internal_entities ent}
    when Sketchup::Group
      group_name = input_ent.name.empty? ? "Group_%s" % [input_ent.persistent_id.to_s] : input_ent.name

      @@inner_entities_h[group_name]=input_ent.entities.to_a
      input_ent.entities.each{|ent| recurse_internal_entities ent}
    when Sketchup::Face 
      face_name = "Face_%s" % [input_ent.persistent_id.to_s]
      @@inner_entities_h[face_name] = input_ent.edges
    end
  end

  def recurse_internal_entities input_ent, input_obj
    case input_ent
    when Sketchup::ComponentInstance
      comp_name = input_ent.definition.name || "Comp_%s" % [input_ent.persistent_id.to_s]
      input_obj[comp_name] = {}
      parent_obj = input_obj[comp_name]
      input_ent.definition.entities.each{|ent| recurse_internal_entities ent, parent_obj}
    when Sketchup::Group
      group_name = input_ent.name.empty? ? "Group_%s" % [input_ent.persistent_id.to_s] : input_ent.name
      input_obj[group_name] = {}
      parent_obj = input_obj[group_name]
      input_ent.entities.each{|ent| recurse_internal_entities ent, parent_obj}
    when Sketchup::Face 
      face_name = "Face_%s" % [input_ent.persistent_id.to_s]
      input_obj[face_name] = input_ent.edges.map{|e| e.persistent_id}
    end
  end

  def get_entities input_comp
    return {} if input_comp.nil? || input_comp.deleted?
    @@inner_entities_h[input_comp.definition.name]={}
    
    result_h = {}
    recurse_internal_entities input_comp, result_h
    result_h
  end
end