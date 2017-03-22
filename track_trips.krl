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
	  mileage = event:attr("mileage").klog("our mileage is: ")
	}
    send_directive("trip") with
      trip_length = mileage
	fired {
	  raise explicit event "trip_processed"
	    attributes event:attrs()
	}
  }
  
    rule trip_processed {
    select when explicit trip_processed
	pre {
	  mileage = event:attr("mileage").klog("our mileage is: ")
	  newbest = mileage.as("Number") > ent:long_trip
	}
    send_directive("trip") with
      trip_length = mileage
    fired {
	  ent:long_trip := 20 if ent:long_trip.isnull();
      ent:long_trip := mileage.as("Number") if (mileage.as("Number") > ent:long_trip);
      ent:long_trip.klog("New Best Mileage: ")
    }
  }
}