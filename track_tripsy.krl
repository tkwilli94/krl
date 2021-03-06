ruleset track_tripsy {
  meta {
    name "Track Tripsy"
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
    select when echo message
	pre {
	  mileage = event:attr("mileage").klog("our mileage is: ")
	}
    send_directive("trip") with
      trip_length = mileage
  }
}