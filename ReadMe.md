```
https://github.com/lavabyte/idx
```
```
bash run.sh
```

# background ssh tmate
```
tmate -S /tmp/tmate.sock new-session -d && tmate -S /tmp/tmate.sock wait tmate-ready && tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}' > tmate && cat tmate
```
