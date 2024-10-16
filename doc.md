# Heartbeat monitoring

### Hearbeat check
- User can create check which contains domain and uuid. for example (https://mw.com/80bcb308-f48f-4723-9d88-88f72e7587e1).
- User can set name and tags for the check to filter the checks.
- User will ping this endpoint of the check using cronjob in his/her service.
- All the checks will have period and grace time.
- Period is the interval to ping the check, and if the check do not receive the ping in the period time then it will wait until grace time elapsed.

## Check status
There are 5 types of status of the heartbeat check.
- `new`     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -> when the check is created
- `up`      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -> when it was being pinged successfully (The last "success" signal has arrived on time)
- `late`    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -> The "success" signal is due but has not arrived yet. It is not yet late by more than the check's configured Grace Time
- `down`    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -> the "success" signal has not arrived yet, and grace time has elapsed, alert message via the configured integration will be sent
- `paused`   &nbsp; -> If you manually paused the heartbeat check, status will be set to paused


### Heartbeat check alert
- User can configure the alert notification for his check.
- User can set email or slack to receive the alert notification.
- As soon as the status of the heartbeat check is changed(except 'new'), he will receive the notification

### Pinging the API
- All ping endpoints support:

    - HTTP and HTTPS
    - HTTP 1.0, HTTP 1.1, (and future scope HTTP 2)
    - IPv4 and IPv6
    - HEAD, GET, and POST request methods.
    - Successful responses will have the "200 OK" HTTP response status code and a short "OK" string in the response body.

### UUIDs
- Each Pinging API request needs to identify a check uniquely. It identifies a check by the check's UUID.
- Check's UUID is automatically assigned when the check is created. It is immutable. You cannot replace the automatically assigned UUID with a manually chosen one. When you delete a check, you lose its UUID and cannot get it back.
- You can look up the UUIDs of your checks in web UI.


### Endpoint
| Description                                 | Endpoint                                    |
|---------------------------------------------|---------------------------------------------|
| Success (UUID)                              | https://mw.com/<{{uuid}}>                   |
| Start (UUID)                                | https://mw.com/<{{uuid}}>/start             |
| Failure (UUID)                              | https://mw.com/<{{uuid}}>/fail              |
| Log (UUID)                                  | https://mw.com/<{{uuid}}>/log               |
| Report script's exit status (UUID)          | https://mw.com/<{{uuid}}>/<exit-status>     |

#### Send a "success" Signal Using UUID
```http
HEAD|GET|POST https://mw.com/<{{uuid}}>
```
Signals that the job has been completed successfully (or a continuously running process is still running and healthy).

identifies the check by the UUID value included in the URL.

Response Codes
200 OK
The request was understood and added to processing queue.
404 (not found)
Could not find a check with the specified UUID.
429 (rate limited)
Rate limit exceeded, request was ignored. Please do not ping a single check more than 5 times per minute.
400 invalid url format
The URL does not match the expected format.
Example
```
GET /5bf66975-d4c7-4bf5-bcc8-b8d8a82ea278 HTTP/1.0
Host: mw.com
HTTP/1.1 200 OK
Server: nginx
Date: Wed, 29 Jan 2020 09:58:23 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 2
Connection: close
Access-Control-Allow-Origin: *
Ping-Body-Limit: 100000

OK
```

#### Send a "start" Signal Using UUID
```http
HEAD|GET|POST https://mw.com/<{{uuid}}>/start
```
Sends a "job has started!" message to middleware.io. Sending a "start" signal is optional, but it enables a few extra features:

We will measure and display job execution times.<br>
We will detect if the job runs longer than its configured grace time<br>
We identifies the check by the UUID value included in the URL.<br>

Response Codes
200 OK
The request was understood and added to processing queue.
404 (not found)
Could not find a check with the specified UUID.
429 (rate limited)
Rate limit exceeded, request was ignored. Please do not ping a single check more than 5 times per minute.
400 invalid url format
The URL does not match the expected format.
Example

```
GET /5bf66975-d4c7-4bf5-bcc8-b8d8a82ea278/start HTTP/1.0
Host: mw.com
HTTP/1.1 200 OK
Server: nginx
Date: Wed, 29 Jan 2020 09:58:23 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 2
Connection: close
Access-Control-Allow-Origin: *
Ping-Body-Limit: 100000

OK
```

#### Send a "failure" Signal Using UUID
```http
HEAD|GET|POST https://mw.com/<{{uuid}}>/fail
```
Signals that the job has failed. Actively signaling a failure minimizes the delay from your monitored service failing to you receiving an alert.

We identifies the check by the UUID value included in the URL.

Response Codes
200 OK
The success signal was recorded.
404 (not found)
Could not find a check with the specified UUID.
429 (rate limited)
Rate limit exceeded, request was ignored. Please do not ping a single check more than 5 times per minute.
400 invalid url format
The URL does not match the expected format.
Example

```
GET /5bf66975-d4c7-4bf5-bcc8-b8d8a82ea278/fail HTTP/1.0
Host: mw.com
HTTP/1.1 200 OK
Server: nginx
Date: Wed, 29 Jan 2020 09:58:23 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 2
Connection: close
Access-Control-Allow-Origin: *
Ping-Body-Limit: 100000

OK
```

#### Report Script's Exit Status (Using UUID)
```
HEAD|GET|POST https://mw.com/<{{uuid}}>/<exit-status>
````
Sends a success or failure signal depending on the exit status included in the URL. The exit status is a 0-255 integer. We interprets 0 as a success and all other values as a failure.

We identifies the check by the UUID value included in the URL.

Response Codes
200 OK
The request was understood and added to the processing queue.
404 (not found)
Could not find a check with the specified UUID.
429 (rate limited)
Rate limit exceeded, request was ignored. Please do not ping a single check more than 5 times per minute.
400 invalid url format
The URL does not match the expected format.
Example

```
GET /5bf66975-d4c7-4bf5-bcc8-b8d8a82ea278/1 HTTP/1.0
Host: mw.com
HTTP/1.1 200 OK
Server: nginx
Date: Wed, 29 Jan 2020 09:58:23 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 2
Connection: close
Access-Control-Allow-Origin: *
Ping-Body-Limit: 100000

OK
```