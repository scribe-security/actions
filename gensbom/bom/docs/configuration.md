# Configuration 

Configuration search paths:
- .gensbom.yaml
- .gensbom/gensbom.yaml
- ~/.gensbom.yaml
- <k>/gensbom/gensbom.yaml

For a custom configuration location use `--config` flag with any command.

Configuration format and default values.
```yaml
output-directory: $XDG_CACHE_HOME/gensbom
output-file: ""
scribe:
  auth:
    login-url: https://scribesecurity-production.us.auth0.com
    client-id: '*******'
    client-secret: '*******'
    audience: api.production.scribesecurity.com
    grant_type: client_credentials
    enable: true
  service:
    url: https://api.production.scribesecurity.com
    enable: true
attest:
  config: ""
  name: Gensbom
  default: sigstore
filter-regex:
- .*\.pyc
- .*\.git/.*
filter-purl: []
bom:
  normalizers:
    packagejson:
      enable: true
  formats:
  - cyclonedx-json
  env: []
  context:
    name: ""
    labels: []
    context-type: local
  force: false
  components:
  - metadata
  - layers
  - packages
  - files
  - dep
  attach-regex: []
find:
  format: ""
  all: false
verify:
  context:
    name: ""
    context-type: ""
sign:
  format: attest-cyclonedx-json
  inputformat: cyclonedx-json
  force: false
  context:
    name: ""
log:
  structured: false
  level: ""
  file: ""
dev:
  profile-cpu: false
  profile-mem: false
  backwards: false
```
