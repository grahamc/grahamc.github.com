---
title: RESTful API Requests
layout: code
---
{% highlight php %}
<?php

// Query the foo/bar method, just for example
$parameters = array('foo' => 'bar', 'baz' => 'quux');
$secret = 'myApiSecret';
echo  buildRequest('foo/bar', 'GET', $parameters, 'myApiKey', $secret);

// R: https://api.nationalfield.org/foo/bar?api_key=myApiKey&baz=quux&
//foo=bar&nonce=4d372ea9e8f2d&timestamp=1295462057&signature=
//9e8f631b2730866eef34e54aff0ce227bf821d7e4877efc6a1ca9fb5de7aeead


/**
 * Build the URL for a request to our API
 * @param string $endPoint The endpoint you want to query, ex: users/list
 * @param string $method The method of the request (GET/PUT/etc.)
 * @param array $parameters The parameters you want to pass
 * @param string $apiKey Your API key (provided by NF)
 * @param string $apiSecret Your secret API string for signing requests
 */
function buildRequest($endPoint, $method, $parameters, $apiKey,
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
                    . ':' . $method . ':' . $endPoint;
    $signature = hash_hmac('sha256', $signature_base, $apiSecret);
    $parameters['signature'] = $signature;

    $query = http_build_query($parameters);

    $url = 'https://api.nationalfield.org/' . $endPoint . '?' . $query;

    return $url;
}

// On our side:
// - Check the timestamp. If it is more than 5 minutes ago, its old - 403
// - Check the nonce, if it has been used before - it is invalid - 403
// - Calculate and compare the signatures on our side, inequal? - 403

/**
* Security Concerns This Addresses
*
* 1) Replaying a request (nonce)
* 2) Executing a command at a later point (timestamp)
* 3) Stolen API key (secret)
*/

{% endhighlight %}
