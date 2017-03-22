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
	  mileage = event:attr("mileage").defaultsTo("200").klog("our mileage is: ")
	}
    send_directive("trip") with
      trip_length = mileage
  }
}