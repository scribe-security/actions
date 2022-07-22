# Installer actions 🍕
Installer action allows you to install tools locally and use them directly.

### Input arguments
```yaml
  tools:
    description: 'Select scribe tools <tool:version>'
    required: false
    default: 'gensbom,valint'
```

## Supported tools
* valint
* gensbom

## OS - Arch support
* Linux - arm64, amd64.

### Usage
```
- name: Scribe tool install
  id: scribe_install
  uses: scribe-security/actions/installer@master
```

