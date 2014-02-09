## Downloader

Simple app that downloads stuff from a ftp, matches on directory names and checks if it is complete before starting download

### Example config file

Create a file called config.yaml, that looks something like this

```yaml
host:
 dns: some_ftp_server
 port: 21
 username: luser
 pass: ohhai
dirs:
 -
  path: /tv
  save_to: /my/mega/tv/archive
  want:
   - Falcon Crest
   - Dallas
   - Rederiet
```

### Running

Either run ``rake download`` to invoke downloading once or just ``rake`` to start the downloader in scheudler mode that will do a download check every hour.
