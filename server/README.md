# server

Dart sync API for the Notes & Reminders app, built on `shelf`. Runs on the
home Mac and is reached from clients over Tailscale.

## Develop

```
dart pub get
dart run bin/manari_server.dart   # listens on $PORT, default 8080
dart test
```

## Run as a persistent service (launchd)

```
dart compile exe bin/manari_server.dart -o build/manari_server
mkdir -p logs
cp launchd/com.elyhyan.manari-server.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.elyhyan.manari-server.plist
```

This is a per-user `LaunchAgent`: it restarts on crash and on login, but
stops when you log out of the Mac's user session. If this Mac ever stops
staying logged in, switch to a system `LaunchDaemon` in
`/Library/LaunchDaemons` instead (requires `sudo` to install).

Check it's running: `curl http://localhost:8080/health`

Reload after changes:
```
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.elyhyan.manari-server.plist
dart compile exe bin/manari_server.dart -o build/manari_server
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.elyhyan.manari-server.plist
```

Logs: `logs/stdout.log`, `logs/stderr.log`.
