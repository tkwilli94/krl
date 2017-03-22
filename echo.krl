ruleset echo {
  meta {
    name "Echo Hello"
    description <<
A first ruleset for the Quickstart
>>
    author "Tommy Williams"
    logging on
    shares hello, message, __testing
  }

  global {
    __testing = { "queries": [ { "name": "hello", "args": [ "obj" ] },{ "name": "__testing" } ],"events": [ { "domain": "echo", "type": "hello", "attrs": [ "name" ] } ] }
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
  }

  rule hello {
    select when echo hello
	pre {
	  name = event:attr("name").klog("our passed in name: ")
	}
    send_directive("say") with
      something = "Hello World"
  }
  
  rule message {
    select when echo message
	pre {
	  input = event:attr("input").klog("our passed in input: ")
	}
	send_directive("say") with
	  something = input
  }
}