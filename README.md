# changepasswd

A minimal Docker image for changing Active Directory passwords using [impacket](https://github.com/fortra/impacket)'s `changepasswd.py`.

## Why

- No Windows machine or AD-joined host required
- Works from macOS or Linux
- Stripped down to `changepasswd.py` only — no other impacket tools included
- Runs as non-root

## Usage

```bash
docker run -it --rm bcit/changepasswd username@domain
```

Example:

```bash
docker run -it --rm bcit/changepasswd jsmith@ad.example.com
```

You will be prompted for the current and new password interactively.

### Targeting a specific DC

```bash
docker run -it --rm bcit/changepasswd domain/username@dc-ip
```

Example:

```bash
docker run -it --rm bcit/changepasswd ad.example.com/jsmith@10.0.0.1
```

## Shell function

Add to your `.bashrc` or `.zshrc` for convenience:

```bash
ad_passwd() {
  if [[ -z "$1" ]]; then
    echo "Usage: ad_passwd USERNAME@DOMAIN"
    return 1
  fi
  docker run -it --rm bcit/changepasswd "${1}"
}
```

Then just run:

```bash
ad_passwd jsmith@ad.example.com
```

## Building

This image uses a `Rakefile` to generate the `Dockerfile` from `Dockerfile.erb` and `metadata.yaml` before building.

```bash
rake
```

## Image details

| | |
|---|---|
| Base image | `python:3.12-alpine` |
| Impacket version | `0.13.0` |
| Runs as | non-root (`appuser`, `uid 1000`) |
| Included tools | `changepasswd.py` only |
