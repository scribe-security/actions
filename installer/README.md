# Installer actions 🍕
Installer action allows you to install tools locally and use them directly.

### Input arguments
```yaml
    version:
    description: 'specific version'
    required: false
  tool:
    description: 'tool'
    required: false
    default: 'gensbom'
```

## Supported tools
* valint
* gensbom

## Linux support
* Debian based - (arm64, amd64), https://scribesecuriy.jfrog.io/artifactory/scribe-debian-local.

### Usage
```
- name: Gensbom verify
  id: gensbom_verify
  uses: scribe-security/actions/gensbom/verify@master
  with:
      tool: 'valint'
```

