Moves Bridge for iOS
====================

The intent of this project is to use the API provided by moves to easily extract data for use with external tools.

To run the project just init the submodules, pull them and run the project in XCode::

    git submodule init
    git submodule update
    cat >MovesBridge/client-secret.h <<EOF
    #define kOauthClientId @"your-client-id"
    #define kOauthClientSecret @"your-secret"
    #define kOauthRedirectUri @"moves-bridge%3A%2F%2Fauthorization-completed"
    EOF
    open MovesBridge.xcodeproj

Then just install the app in the phone and do the authentication. You should now get a message stating the HTTP endpoint
you can make queries to::

    maharj:~ $ curl http://x.y.z.w:8080/api/v1/user/profile
    {"userId":some-user-id,"profile":{"firstDate":"some-date"}}
    
See the Moves API documentation for more details.

Screenshot
----------

.. image:: http://play.taiste.fi/stuf/moves-bridge.jpg


3rd party libs
--------------

This project uses the following third party libraries:

    * AFNetworking_
    * Mongoose_

.. _AFNetworking: http://github.com/AFNetworking/AFNetworking
.. _Mongoose: http://github.com/valenok/mongoose/

Licence 
------- 
 
Licenced under MIT:: 
 
    Copyright (C) 2013 by Mikko Harju 
 
    Permission is hereby granted, free of charge, to any person obtaining a copy 
    of this software and associated documentation files (the "Software"), to deal 
    in the Software without restriction, including without limitation the rights 
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
    copies of the Software, and to permit persons to whom the Software is 
    furnished to do so, subject to the following conditions: 
 
    The above copyright notice and this permission notice shall be included in 
    all copies or substantial portions of the Software. 
 
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
    THE SOFTWARE. 
