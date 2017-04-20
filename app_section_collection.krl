ruleset manage_fleet {
  meta {
    name "Manage Fleet of Vehicles"
    description <<
A ruleset for Managing a fleet of vehicles
>>
    author "Tommy Williams"
    logging on
    shares create_vehicle, __testing, nextId, showChildren, initialize_fleet, vehicles, unneeded_vehicle
    use module io.picolabs.pico alias wrangler
  }

  global {
    __testing = { "queries": [ { "name": "nextId" },
                               { "name": "showChildren"},
                               { "name": "vehicles"} ],
                  "events":  [ { "domain": "car", "type": "new_vehicle" },
                               { "domain": "car", "type": "initialize" },
                               { "domain": "car", "type": "unneeded_vehicle",
                                 "attrs": [ "vehicle_id" ] } 
                             ]
                }
    nextId = function() {
      ent:nextId
    }
	
    showChildren = function() {
      wrangler:children()
    }

    nameFromID = function(vehicle_id) {
	  "Vehicle " + vehicle_id + " pico"
	}
	
    childFromID = function(vehicle_id) {
      ent:vehicles{vehicle_id}
    }
	
	vehicles = function() {
	  ent:vehicles.defaultsTo({})
	}
  }

  rule create_vehicle {
    select when car new_vehicle
    pre {
      vehicle_id = ent:nextId.defaultsTo(0)
    }
    fired {
      ent:nextId := ent:nextId.defaultsTo(0) + 1;
      raise pico event "new_child_request"
        attributes { "dname": nameFromID(vehicle_id),
                     "color": "#FF69B4",
                     "vehicle_id": vehicle_id}
    }
  }
  
  
  rule delete_vehicle {
    select when car unneeded_vehicle
    pre {
      vehicle_id = event:attrs("vehicle_id")
	  exists = ent:vehicles >< vehicle_id
	  eci = meta:eci
	  child_to_delete = childFromID(vehicle_id)
    }
	if exists then
	  send_directive("vehicle_deleted")
	    with vehicle_id = vehicle_id
    fired {
	  raise pico event "delete_child_request"
        attributes child_to_delete;
      ent:vehicles{[vehicle_id]} := null
	}
  }
  
    rule pico_child_initialized {
    select when pico child_initialized
    pre {
      the_vehicle = event:attr("new_child")
      vehicle_id = event:attr("rs_attrs"){"vehicle_id"}
    }
    if vehicle_id.klog("found section_id")
    then
      event:send(
        { "eci": the_vehicle.eci, "eid": "install-ruleset",
          "domain": "pico", "type": "new_ruleset",
          "attrs": { "rid": "Subscriptions", "vehicle_id": vehicle_id }
        })
      event:send(
        { "eci": the_vehicle.eci, "eid": "install-ruleset",
          "domain": "pico", "type": "new_ruleset",
          "attrs": { "rid": "trip_store", "vehicle_id": vehicle_id }
        })
      event:send(
        { "eci": the_vehicle.eci, "eid": "install-ruleset",
          "domain": "pico", "type": "new_ruleset",
          "attrs": { "rid": "track_trips", "vehicle_id": vehicle_id }
        })
    fired {
      ent:vehicles := ent:vehicles.defaultsTo({});
      ent:vehicles{[vehicle_id]} := the_vehicle
    }
  }
  

  rule initialize_fleet {
    select when car initialize
    fired {
      ent:nextId := 1;
	  ent:vehicles := {}
    }
  }
}