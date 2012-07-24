SMALocationSearchController
===========================

SMALocationSearchController is a bolier-plate to simplify the process of presenting a view controller, where user can enter, lookup or pick a location name, using Google Map engine.


Dependencies:
-------------
`AFNetworking` (https://github.com/moayes/AFNetworking/) : I recommed using the static library, that I extended upon `AFNetworking` (https://github.com/AFNetworking/AFNetworking/) original library.
It simply wraps `AFNetworking` into a static library so that it can be imported in any project by calling
``` objective-c
#import <AFNetworking/AFNetworking.h>
```
instead of adding individual files.

The following classes are from `iOS-boilerplate` (https://github.com/gimenete/iOS-boilerplate) and are included in the project. There is no need to re-download them again:

### Classes:
* JSONKit.h
* JSONKit.m
* StringHelper.h
* StringHelper.m
* DataHelper.h
* DataHelper.m