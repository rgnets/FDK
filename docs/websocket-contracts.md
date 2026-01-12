# WebSocket Contracts

This document captures the WebSocket contract used by the FDK client. It is
ActionCable-based and targets the `RxgChannel` channel.

## Connection

- **URL**: `wss://<fqdn>/cable` in staging/production, or
  `EnvironmentConfig.websocketBaseUrl` in development.
- **Auth**: supply `Authorization: Bearer <api_key>` header when possible and
  also include `api_key` as a query parameter for compatibility.
- **Channel**: subscribe using identifier `{"channel":"RxgChannel"}`.

## Message Envelope (ActionCable)

```json
{
  "command": "message",
  "identifier": "{\"channel\":\"RxgChannel\"}",
  "data": "{\"action\":\"subscribe_to_resource\",\"resource_type\":\"access_points\"}"
}
```

`data` is a JSON-encoded string containing the resource action payload.

## Resource Subscriptions

Send one `subscribe_to_resource` per resource type:

- `access_points`
- `media_converters`
- `switch_devices`
- `pms_rooms`

## Snapshots

Request a full snapshot for a resource with `resource_action`:

```json
{
  "action": "resource_action",
  "resource_type": "access_points",
  "crud_action": "index",
  "page": 1,
  "page_size": 10000,
  "request_id": "snapshot-access_points-<timestamp>"
}
```

## Resource Actions

- **Get a single item**: `action: "resource_action"`, `crud_action: "show"`,
  `id: <numeric id>`
- **Update**: `action: "update_resource"`, `id: <numeric id>`,
  `params: { ... }`
- **Reboot**: `action: "resource_action"`, `crud_action: "reboot"`,
  `id: <numeric id>`
- **Factory reset**: `action: "resource_action"`, `crud_action: "reset"`,
  `id: <numeric id>`

## Payload Shape

Messages typically include:

- `resource_type` to identify the stream
- `resource_action` (or `action`) for the operation type
- `data` containing the resource payload (fallback to root payload if needed)

The client accepts payloads from either `payload`, `payload.data`, or `raw.data`
depending on server response.

## Images

Device image arrays may appear as `images` or `pictures`. URLs can be absolute
or relative; the client normalizes relative paths using the configured site
base URL.
