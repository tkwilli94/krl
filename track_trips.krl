ruleset track_trips {
  meta {
    name "Track Trips"
    description <<
A ruleset for Track Trips
>>
    author "Tommy Williams"
    logging on
    shares process_trip
  }

  global {
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
  }

  rule process_trip {
    select when car new_trip
	pre {
	  mileage = event:attr("mileage").defaultsTo("40").klog("our mileage is: ")
	}
    send_directive("trip") with
      trip_length = mileage
	fired {
	} else {
	  raise explicit event "trip_processed"
	    attributes event.attrs()
	}
  }
  
  rule find_long_trips {
    select when explicit trip_processed
	pre {
	  mileage = event:attr("mileage").defaultsTo("40")
	  notnewhigh = mileage.as("Number") < ent:long_trip.defaultsTo(50)
	}
	if notnewhigh then
	  send_directive("short_trip")
	    with mileage = mileage
	fired {
	} else {
	  raise explicit event "found_long_trip"
		attributes event.attrs()
	}
  }
  
  rule found_long_trip {
    select when explicit found_long_trip
	pre {
	  mileage = event:attr("mileage").defaultsTo("40")
	}
	send_directive("long_trip_recorded")
	  with mileage = mileage
        fired {
          ent:long_trip := mileage
        }
  }
}