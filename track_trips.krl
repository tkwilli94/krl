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
      mileage = event:attr("mileage").isnull() => "20" | event:attr("mileage")
      a = ent:longest_trip.klog("longest:" )
      b = ent:longest_trip.klog("Looooongest:")
	}
    send_directive("trip") with
      trip_length = mileage
	fired {
      ent:longest_trip := 0 if ent:longest_trip.isnull();
	  raise explicit event "trip_processed"
	    attributes event:attrs()
	}
  }
  
  rule trip_processed {
    select when explicit trip_processed
    pre {
	  mileage = event:attr("mileage").isnull() => "20" | event:attr("mileage")
      notnewbest = (mileage.as("Number").klog("mileage: ") <= ent:longest_trip.klog("long: "))
	}
    if notnewbest then
      send_directive("trip") with
        trip_length = mileage
    fired {

    } else {
      raise explicit event "found_long_trip"
	    attributes event:attrs()
    }
  }
  
  rule found_long_trip {
    select when explicit found_long_trip
	pre {
	  mileage = event:attr("mileage").isnull() => "20" | event:attr("mileage")
	}
    fired {
      ent:longest_trip := mileage.as("Number");
      ent:longest_trip.klog("New Best Mileage: ")
    }
  }
  
  rule clear_trips {
    select when car trip_reset
    fired {
	  ent:longest_trip := 0;
	  ent:longest_trip.klog("Longest Trip Reset To: ")
    }
  }
}