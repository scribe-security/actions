# Report action #

### Input arguments
```yaml
  verbose:
    description: 'Increase verbosity (-v = info, -vv = debug)'
    default: 1
  config:
    description: 'Application config file'
  output-directory:
    description: 'Output directory path'
    default: ./scribe/valint
  output-file:
    description: 'Output file path'
  scribe-enable:
    description: 'Enable scribe client'
    default: false
  scribe-client-id:
    description: 'Scribe client id' 
  scribe-client-secret:
    description: 'Scribe access token' 
  scribe-url:
    description: 'Scribe url' 
  scribe-login-url:
    description: 'Scribe auth login url' 
  scribe-audience:
    description: 'Scribe auth audience' 
  context-dir:
    description: 'Context dir' 
  section:
    description: 'Select report sections'
  integrity:
    description: 'Select report integrity'
```

### Output arguments
```yaml
  output-file:
    description: 'Report output file path'
```

### Usage
```YAML
- name: Valint - download report
  id: valint_report
  uses: scribe-security/actions/valint/report@master
  with:
      verbose: 2
      scribe-enable: true
      scribe-client-id: ${{ secrets.client-id }}
      scribe-client-secret: ${{ secrets.client-secret }}
```