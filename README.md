## Introduction

This repository contains the source for my blog


## Deployment
### My server
I'm serving this on DN42, so I have to specify a separate `base-url`
``` sh
zola build --base-url https://franta.dn42

scp -r public/ molybdenum.infra.franta.us:/var/www
```

### Cloudflare worker
The `build.sh` and `wrangler.toml` files handle deployment to Cloudflare
