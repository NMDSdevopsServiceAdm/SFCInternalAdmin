# Internal Admin - development environment

# to run
1. `terrafrom init` - installs modules
2. `terrafrom apply` - reads configuration, assesses change and runs changes

# to remove
1. `terraform destory`

# dependencies
Expects to read access key and secret from the local shared configuration file [$HOME/%HOME%]/.aws/credentials, but with a specific profile name of "dev-terraform".

Example `~/.aws/credentials` file (actual key and secret obfuscated of course):

```
[dev-terraform]
aws_access_key_id = AKIA...26SBKIRQ
aws_secret_access_key = Q/tv+..BASE64...8xmWLbF2s
```

# modules
* (local) vpc
* (local) keystonejs
* (local) nodebeats
* (local) strapi