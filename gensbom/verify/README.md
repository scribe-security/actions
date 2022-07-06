---
title: Verify
---

# Verify action

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

### Usage
```
- name: Bomber verify
  id: bomber_verify
  uses: scribe-security/actions/installer@master
  with:
      target: 'busybox:latest'
      verbose: 2
```
