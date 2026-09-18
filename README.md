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
  docker run -it --rm bcit/changepasswd -protocol kpasswd "${1}"
}
```

Then just run:

```bash
ad_passwd jsmith@ad.example.com
```

### Windows Server 2025 compatibility

Password changes against Windows Server 2025 may fail unless `-protocol kpasswd` is used, sometimes with the misleading error:

```text
Target user is not allowed to change their own password
```

To use the Kerberos password-change protocol directly:

```bash
docker run -it --rm bcit/changepasswd -protocol kpasswd username@domain
```

The `ad_passwd` helper explicitly uses the Kerberos `kpasswd` protocol for compatibility with Windows Server 2025. It also works with earlier Active Directory domain controllers and requires TCP or UDP port 464 between the client and domain controller.

If port 464 is unavailable, omit `-protocol kpasswd` to use the container's default protocol. This fallback may fail against Windows Server 2025.

## Building

This image uses a `Rakefile` to generate the `Dockerfile` from `Dockerfile.erb` and `metadata.yaml` before building.

```bash
rake
```

To build and publish a multi-platform image for AMD64 and ARM64 using Docker Buildx:

```bash
rake multiarch
```

This pushes all tags and registries configured in `metadata.yaml`. Set `PLATFORMS` to override the default platforms.

## Image details

| | |
|---|---|
| Base image | `python:3.14-alpine` |
| Impacket version | `0.13.1` |
| Runs as | non-root (`appuser`, `uid 1000`) |
| Included tools | `changepasswd.py` only |
