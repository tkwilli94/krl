ruleset app_section_collection {
  meta {
    name "Trip Storage"
    provides section_needed
    description <<
    A ruleset for app section collection
    >>
    author "Tommy Williams"
    logging on
    shares section_needed
  }
  
  rule section_needed {
    select when section needed
    pre {
      section_id = event:attr("section_id")
      exists = ent:sections >< section_id
      eci = meta:eci
    }
    if exists then
      send_directive("section_ready")
        with section_id = section_id
    fired {
    } else {
      ent:sections := ent:sections.defaultsTo([]).union([section_id]);
      raise pico event "new_child_request"
        attributes { "dname": nameFromID(section_id), "color": "#FF69B4" }
    }
  }
}