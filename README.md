# SFCInternalAdmin
Internal Admin application deployment scripts - terraform (AWS)

# Environments
This repo follows terraform best practice for short lived branches and multiple environments.

Each environment (dev | prod) is a separate directory under `environments`.

Navigate first to the environment you want to deploy.

Then run:
1. `terrafrom init`
2. `terraform apply`

To remove the environment:
3. `terraform destory`

# terraform
The scripts in the repo are based on terraform v0.12.3.

# dependencies
## AWS
Expects to read access key and secret from the local shared configuration file [$HOME/%HOME%]/.aws/credentials, but with a specific profile name of "dev-terraform".

Example `~/.aws/credentials` file (actual key and secret obfuscated of course):

```
[dev-terraform]
aws_access_key_id = AKIA...26SBKIRQ
aws_secret_access_key = Q/tv+..BASE64...8xmWLbF2s

[prod-terraform]
aws_access_key_id = AKIA...26SBKIRQ
aws_secret_access_key = Q/tv+..BASE64...8xmWLbF2s
```