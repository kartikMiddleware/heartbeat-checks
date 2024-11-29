## Responsibilities of different services
### App-api
- Create/update/delete checks and return URL containing unique UUID
    - It needs check name, interval, grace time to create heartbeat check from UI.
    - App-api will then create and return a URL containing unique UUID(user can use this url to ping)
- It then save the check details to postgres.
- update/delete check details.
- Sends the message(check details) to pulsar.
- Add events to clickhouse.

#### APIs
```
- CreateCheck  [POST]   /api/v1/heartbeat
- GetCheck     [GET]    /api/v1/heartbeat/:id
- GetAllChecks [GET]    /api/v1/heartbeat
- UpdateCheck  [PUT]    /api/v1/heartbeat/:id
- DeleteCheck  [DELETE] /api/v1/heartbeat/:id
```

```go
// Response for all the api calls
type Response struct {
	Status      bool   `json:"status"`
	Message     string `json:"message"`
	Items       any    `json:"items"`
	PulsarError string `json:"pulsar_error,omitempty"`
}

// HeartbeatRequest type is for create and update check
type HeartbeatRequest struct {
	SlugName       string `json:"slug_name"`
	IntervalSec    *int   `json:"interval_sec"`
	GracePeriodSec int    `json:"grace_period_sec"`
	Description    string `json:"description"`
}

type HeartbeatCheck struct {
	Id int `json:"id"`
	HeartbeatRequest
	UUID               string    `json:"uuid"`
	URL                string    `json:"url"`
	Status             string    `json:"status"`
	LastPing           time.Time `json:"last_ping"`
	AccountId          int       `json:"account_id"`
	AccountUID         string    `json:"account_uid"`
	AccountKey         string    `json:"account_key"`
	ProjectId          int       `json:"project_id"`
	ProjectUID         string    `json:"project_uid"`
	UserId             int       `json:"user_id"`               // who created check
	LastModifyUserId   int       `json:"last_modify_user_id"`   // who modified the check(updated check information)
	LastModifyUserName string    `json:"last_modify_user_name"` // who modified the check(updated check information)
	TotalRecords       int       `json:"total_records"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`
}
```

### Heartbeat-server(public)
- Handle pings from various cron jobs
- Handle rate-limiting
- Validate the request(using exposed apis from App-api)
- Send check details to pulsar

### Heartbeat-service
- Continously running and getting msg from pulsar
- Actual logic of heartbeat monitoring
- Responsible for updating postgres and clickhouse
