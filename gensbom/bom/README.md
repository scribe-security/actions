---
title: Bom
---


# Bom action

### Input arguments
```yaml
  type:
    description: 'Target source type options=[docker,docker-archive, oci-archive, dir, registry]'
    default: registry
  target:
    description: 'Target object name format=[<image:tag>, <dir_path>]'
    required: true
  verbose:
    description: 'Increase verbosity (-v = info, -vv = debug)'
    default: 0
  config:
    description: 'Application config file'
  format:
    description: 'Sbom formatter, options=[cyclonedx-json cyclonedx-xml attest-cyclonedx-json statement-cyclonedx-json]'
    default: cyclonedxjson
  output-directory:
    description: 'Report output directory'
    default: ./scribe/gensbom
  output-file:
    description: 'Output result to file'
  name:
    description: 'Custom/project name'
  label:
    description: 'Custom label'
  env:
    description: 'Custom env'
  filter-regex:
    description: 'Filter out files by regex'
    default: .*\.pyc,\.git/.*
  collect-regex:
    description: 'Collect files content by regex'
  force:
    description: 'Force overwrite cache'
    default: false
  attest-config:
    description: 'Attestation config map'
  attest-name:
    description: 'Attestation config name (default "gensbom")'
  attest-default:
    description: 'Attestation default config, options=[sigstore sigstore-github x509]'
    default: sigstore-github
  scribe-enable:
    description: 'Enable scribe client'
    default: false
  scribe-clientid:
    description: 'Scribe client id' 
  scribe-clientsecret:
    description: 'Scribe access token' 
  scribe-url:
    description: 'Scribe url' 
  context-dir:
    description: 'Context dir' 
```

### Output arguments
```yaml
  output-file:
    description: 'Bom output file path'
```

### Usage
```
- name: Generate cyclonedx json SBOM
  uses: scribe-security/actions/gensbom/bom@master
  with:
    target: 'busybox:latest'
    verbose: 2
```

## Configuration
Use default configuration path `.gensbom.yaml`, or
provide custom path using `config` input argument.

See detail [documentation - config](docs/configuration.md)

You may add a `.cocosign.yaml` file at your repository or pass with `--config` \
for more [Cocosign configuration](https://github.com/scribe-security/cocosign)


## Attestations 
Attestations sboms allow you to sign and verify your sbom targets. \
Attestations allow you to connect PKI based identities to your evidence and policy management. 

Use default configuration path `.cocosign.yaml`, or
provide custom path using `attest-config` input argument.

See details [documentation - attestation](docs/attestations.md) \
Source see [cocosign](https://github.com/scribe-security/cocosign), attestation manager
