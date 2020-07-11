[![Build Status](https://www.travis-ci.org/e-fever/backpressure.svg?branch=master)](https://www.travis-ci.org/e-fever/backpressure)
[![Build status](https://ci.appveyor.com/api/projects/status/knt6r7gra9dm0oui?svg=true)](https://ci.appveyor.com/project/benlau/backpressure)

Backpressure
============

Backpressure happens on a stream of data where you are not fast enough to process. 
This library is designed to provide a few mechanism to handle it.

Installation
============

    qpm install net.efever.backpressure
    
    
API
===

```
import Backpressure 1.0
```


**Backpressure.oneInTime(owner, duration, callback)**

It will create a wrapper function of the callback. Whatever you have invoked the wrapper function, it will execute the callback immediately. Then it will be blocked within duration period. It could prevent to process the same event twice within the duration period.

Example:
```

Item {
  id : item
  property var processClick : Backpressure.oneInTime(item, 500, function(value) { 
    /* Callback */ 
  });

  MouseArea {
    onClicked: {
       processClick(value);
    }
  }

}
```

If the owner is destroyed, the callback will no longer be able to access.

**Backpressure.debounce(owner, duration, callback)**

If will create a wrapper function of the callback. Whatever you have invoked the wrapper function, it won't execute the callback until the duration period finished. If user invoked the wrapper function again within the period, then the previous call will be dropped, and the timer is restarted.

It will guarantee only the last function call and parameter will be passed to the callback.

Reference: [ReactiveX - Debounce operator](http://reactivex.io/documentation/operators/debounce.html)

**Backpressure.promisedOneInTime(owner, callback)**

This function is similar to oneInTime that will create a wrapper of the callback. But it does not take a timeout value as an argument of the construction function.

Instead, it will convert the return from the callback to a promise object. Then blocks successively calls until the promise is resolved/rejected.

The wrapper function returns a promise represents the result of the callback. If that is blocked, it will simply a rejected promise.

You must install QuickPromise in order to use this funciton.

Example
```

var timeout = Backpressure.promisedOneInTime(anyItem, function(delay) {
    return Q.promise(function(fulfill, reject) {
        Q.setTimeout(function() {
            fulfill();
        }, delay);
    });
});

var promise1 = timeout(1000); // Pending
var promise2 = timeout(1000); // Rejected

```
