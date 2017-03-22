ruleset trip_store {
  meta {
    name "Trip Storage"
    description <<
A ruleset for Trip Storing
>>
    author "Tommy Williams"
    logging on
    shares collect_trips
  }

  global {
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
  }

  rule collect_trips {
    select when explicit trip_processed
	pre {
      mileage = event:attr("mileage").isnull() => "20" | event:attr("mileage")
	}
	fired {
  	  ent:all_trips := ent:all_trips.put([timestamp], mileage);
	  ent:all_trips.keys().klog("all_trips: ");
	  ent:all_trips.values().klog("all_trips: ")
	}
  }
  
  rule collect_long_trips {
    select when explicit found_long_trip
	pre {
      mileage = event:attr("mileage").isnull() => "20" | event:attr("mileage")
	}
    fired {
  	  ent:long_trips := ent:long_trips.put([timestamp], mileage);
	  ent:long_trips.keys().klog("long_trips: ");
	  ent:long_trips.values().klog("long_trips: ")
	}
  }
  
  rule clear_trips {
    select when car trip_reset
    fired {
      ent:long_trips := {};
      ent:all_trips := {};
	  ent:longest_trip := 0
    }
  }
}