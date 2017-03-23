ruleset trip_store {
  meta {
    name "Trip Storage"
	provides trips, long_trips, short_trips
	shares trips, long_trips, short_trips
    description <<
A ruleset for Trip Storing
>>
    author "Tommy Williams"
    logging on
    shares trips, hello, long_trips, short_trips
  }

  global {
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
    trips = function() {
      otter = ent:all_trips;
      otter
    }
	long_trips = function() {
	  trips = ent:long_trips;
	  trips
	}
	short_trips = function() {
		shorties = ent:all_trips.filter(function(x){ent:long_trips.index(x) == -1});
		shorties
	}
  }

  rule collect_trips {
    select when explicit trip_processed
	pre {
      mileage = event:attr("mileage").isnull() => "20" | event:attr("mileage")
      timestamp = time:now()
	  timestamp = timestamp.substr(0,19)
      myentry = ("Time: " + timestamp + "| Miles: " + mileage)
	}
	fired {
  	  ent:all_trips := ent:all_trips.append([myentry]);
	  ent:all_trips.klog("all_trips entries: ")
	}
  }
  
  rule collect_long_trips {
    select when explicit found_long_trip
	pre {
      mileage = event:attr("mileage").isnull() => "20" | event:attr("mileage")
	  timestamp = time:now()
	  timestamp = timestamp.substr(0,19)
	  myentry = ("Time: " + timestamp + "| Miles: " + mileage)

	}
    fired {
 	  ent:long_trips := ent:long_trips.append([myentry]);
	  ent:long_trips.klog("long_trips entries: ")
	}
  }
  
  rule clear_trips {
    select when car trip_reset
    fired {
      ent:long_trips := [];
      ent:all_trips := []
    }
  }
}