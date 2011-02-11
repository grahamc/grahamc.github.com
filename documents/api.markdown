---
layout: code
title: API Considerations
---


![My Endpoints: Let me show you them'](http://hueniverse.com/wp-content/uploads/2007/12/My-Endpoints-300x267.png)

### Brief REST Introduction
`REST` uses the idea of `resources` and verbs to interact with a dataset. Verbs are strictly HTTP's provided verbs:

- `GET` - Retrieve information about a resource (Does not modify anything)
- `PUT` - Explicitly *update* or *create* a record (Will create the record if it does not exist)
- `POST` - Explicitly *create* a record (Should fail if the record exists already)
- `DELETE` - Delete a record

These HTTP verbs are sent to endpoints which represent the data. For example, to update a Note with the ID of 1, you would: `PUT /note/1`

Because of this, verbs are not appropriate in an endpoint: `GET /note/1/getGraph` would be: `GET /note/1/graph`.

### Caching
> As on the World Wide Web, clients are able to cache responses. Responses must therefore, implicitly or explicitly, define themselves as cacheable or not to prevent clients reusing stale or inappropriate data in response to further requests. Well-managed caching partially or completely eliminates some client–server interactions, further improving scalability and performance.
> - [REST: Constraints on Wikipedia](http://en.wikipedia.org/wiki/REST#Constraints)

Caching can be implemented using the existing HTTP protocol through the following HTTP headers:

- `Last-Modified`
- `If-Modified-Since` (conditional requests)
- `E-Tags`

### View
When developing an API, almost all of the output formatting can be done automatically, with no manual intervention on how the data should be returned.

By using a "Unified View Layer" we could very quickly develop API endpoints by simply returning an array of data from the controller. The layer would automatically take that data and convert it into any of the output formats. 

Through automatic generation of this data we are guaranteed valid results and very few inconsistencies in how one method or another outputs their data. This would also reduce redundant work to implement each output format for each endpoint.

More complicated endpoints would be able to override this behavior and define manual layouts.

#### Output Formats
- `XML`
- `JSON`
- `Text`: The equivalent of a var_dump of the data; for debugging purposes.
- `PList`: Just an idea; iOS can natively process PLists.

### Authentication
API keys will be unique on a per-application basis and non-unique across clients. Because of this there will be a centralized database for storing this information. Client <-> Application permissions will also be stored in this database.

> Maybe an alternative method could be a separate Git repository storing these configurations? Many organizations recommend this for versioned configurations.

#### Security Considerations
- `SSL`: Secure communications to prevent eavesdropping
- `API Key`: A unique string to identify apps
- `API Secret`: A unique string used in validating that the request is valid
- `Timestamp`: To prevent old requests from being replayed (ie: requests 5 min. or older are invalid)
- `Nonce`: A random, unique string which may not be used again; prevents replaying requests
- `Signature`: The `HMAC` hash of the request's specifics to prevent modifying any parameters; signed with the `API Secret`

### 3rd Party Apps (incorporating them into our system)
There are two basic approaches proposed for incorporating 3rd-party applications into our system.

- `FBML`-like syntax 
- Using `iframes`

By using a `FBML` syntax we may be able to regulate style a little bit more rigorously, but we would also need to fashion a templating engine, and javascript would effectively be out of the question.

On the other hand, using `iframes` would retain the inherent security gained when loading 3rd party elements into pages (javascript cookie stealing, etc.) and reduce overhead on parsing this language, and reduce potential bugs in our implementation.

#### Canvases
When an application registers with NationalField it defines which canvases it will use, and what URL to make a request to in order to receive the contents of that canvas.
> For example, the Numbers app may define a sidebar canvas, and then the default starting canvas for the primary site.

### Making A Request
{% highlight php %}
<?php
// Query the foo/bar method, just for example
$parameters = array('foo' => 'bar', 'baz' => 'quux');
$secret = 'myApiSecret';
echo  buildRequest('dccc', 'foo/bar', 'GET', $parameters, 'myApiKey',
$secret);

?>
{% endhighlight %}
> Would result in https://dccc.api.nationalfield.org/foo/bar?
> api_key=myApiKey&baz=quux&foo=bar&nonce=4d372ea9e8f2d
> &timestamp=1295462057&signature=
> 9e8f631b2730866eef34e54aff0ce227bf821d7e4877efc6a1ca9fb5de7aeead

{% highlight php %}
<?php
/**
 * Build the URL for a request to our API
 * @param string $client The client you want to access
 * @param string $endPoint The endpoint you want to query, ex: users/list
 * @param string $method The method of the request (GET/PUT/etc.)
 * @param array $parameters The parameters you want to pass
 * @param string $apiKey Your API key (provided by NF)
 * @param string $apiSecret Your secret API string for signing requests
 */
function buildRequest($client, $endPoint, $method, $parameters, $apiKey,
    $apiSecret) {
    
    // Add the required parameters by the API endpoint
    $parameters['timestamp']    = time();
    $parameters['api_key']      = $apiKey;
    $parameters['nonce']        = uniqid();
    
    // Sort the parameters alphabetically by key
    ksort($parameters);
    
    // Generate the signature using HMAC
    // (hash-based message authentication code)
    $signature_base = http_build_query($parameters)
                    . ':' . $method . ':' . $endPoint . ':' . $client;
    $signature = hash_hmac('sha256', $signature_base, $apiSecret);
    $parameters['signature'] = $signature;
    
    $query = http_build_query($parameters);
    
    $url = 'https://' . $client . 'api.nationalfield.org/'
        . $endPoint . '?' . $query;
    
    return $url;
}
?>
{% endhighlight %}

On our side we would:

- Check the timestamp. If it is more than 5 minutes ago, its old - 403
- Check the nonce, if it has been used before - it is invalid - 403
- Calculate and compare the signatures on our side, non-equal? - 403