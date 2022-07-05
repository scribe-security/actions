# Installer actions 🍕
Installer action allows you to install tools locally and use them directly.

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
  inputformat:
    description: 'Sbom input formatter, options=[attest-cyclonedx-json] (default "attest-cyclonedx-json")'
    default: attest-cyclonedx-json
  output-directory:
    description: 'report output directory'
    default: ./gensbom_reports
  output-file:
    description: 'Output result to file'
  filter-regex:
    description: 'Filter out files by regex'
    default: .*\.pyc,\.git/.*
  attest-config:
    description: 'Attestation config map'
  attest-name:
    description: 'Attestation config name (default "gensbom")'
  attest-default:
    description: 'Attestation default config, options=[sigstore sigstore-github x509]'
    default: sigstore-github
```

## Supported tools
* valint
* bomber

## Linux support
* Debian based - (arm64, amd64), https://scribesecuriy.jfrog.io/artifactory/scribe-debian-local.

### Usage
```
- name: Bomber verify
  id: bomber_verify
  uses: scribe-security/actions/gensbom/verify@master
  with:
      tool: 'valint'
```

