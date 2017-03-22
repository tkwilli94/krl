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
    long_trip = "20"
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
      long_trip = mileage if (mileage.as("Number") > long_trip.as("Number"));
      long_trip.klog("New Best Mileage: ")
    }
  }
}