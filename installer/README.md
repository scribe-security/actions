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
    default: 'bomber'
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

