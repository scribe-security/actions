---
title: gensbom
author: mikey strauss - Scribe
date: March 1, 2022
geometry: margin=2cm
---
# 🚀 Scribe provided sensor actions
Scribe provides a set of of sensors who collect evidence and verify the supply chain integrity.

# 🚀 valint
---
valint tool provides a tool to verify integrity of a supply chain.

## Report action
Command pulls Scribe reports.
Once a set of evidence are uploaded to Scribe service a report is generated.
By default report is written in to local cache. 

### Input arguments
```yaml
  verbose:
    description: 'Increase verbosity (-v = info, -vv = debug)'
    default: 0
  config:
    description: 'Application config file'
  output-directory:
    description: 'Output directory path'
    default: ./valint_reports
  output-file:
    description: 'Output file path'
  scribe-enable:
    description: 'Enable scribe client'
    default: false
  scribe-clientid:
    description: 'Scribe client id' 
  scribe-clientsecret:
    description: 'Scribe access token' 
  scribe-url:
    description: 'Scribe url' 
  scribe-loginurl:
    description: 'Scribe auth login url' 
  scribe-audience:
    description: 'Scribe auth audience' 
  context-dir:
    description: 'Context dir' 
  section:
    description: 'Select report sections'
  section2:
    description: 'Select report sections2'
  section3:
    description: 'Select report sections3'
  integrity:
    description: 'Select report integrity'
  integrity2:
    description: 'Select report integrity2'
  integrity3:
    description: 'Select report integrity3'
```

### Output arguments
```yaml
  output-file:
    description: 'Report output file path'
```

## Integration examples
<details>
  <summary>  Scribe integrity report download </summary>

Download integrity report.

```YAML
    - name: Valint - download integrity report
      id: download_report
      uses: scribe-security/actions/valint/report@master
      with:
          scribe-clientid: ${{ inputs.clientid }}
          scribe-clientsecret: ${{ inputs.clientsecret }}
``` 
Default output will be set to ~/.cache/valint/ subdirectory (Use `output-directory` argument to overwrite location).
</details>


<details>
  <summary> Simple download report verbose, custom output path </summary>

Download report for CI run, save output to local file.

```YAML
    - name: Valint - download integrity report
      id: download_report
      uses: scribe-security/actions/valint/report@master
      with:
          verbose: 3
          scribe-enable: true
          scribe-clientid: ${{ inputs.clientid }}
          scribe-clientsecret: ${{ inputs.clientsecret }}
          output-file: "./result_report.json"
``` 
</details>


# 🚀  Gensbom actions - GitHub Action for SBOM Generation (Scribe)
---
Included GitHub Actions uses the [gensbom](https://github.com/scribe-security/gensbom) cli tool. \
Actions allow one to both generate manage sign and verify image and directory targets.
* Attestation options are based on the [cocosign](https://github.com/scribe-security/cocosign) FM,
Which allows a wide range of signing and verifing flows including KMS, and Sigstore flows.

## Bom action
The action invokes a containerized `gensbom` sub command `bom`. 
Command allows users to create and upload SBOMs.
- By default action will include github specific context to its SBOMs (GIT_URL, JOB_ID .. etc)
- By default action will sign Sigstore keyless flow while using github own workload auth as a OIDC identity (See example below).
- Generates detailed SBOMs for images and directories (mapped to working dir) targets. 
- Upload SBOMs to scribe service (Not supported yet)
- Save SBOMs by any CI tool (action output includes local stored SBOMs).
- Supported Cached SBOMs/attestations locally
- Supported Cached SBOMs/attestations by Scribe service (TBD).
- Support Private registries (TBD)
- Add custom labels, envs to SBOM and attestations

## Verify action
The action invokes a containerized `gensbom` sub command `verify`.
Command allows users to verify a image via a signed attestation (Intoto).
- By default action will include github specific context to its SBOMs (GIT_URL, DOB_ID .. etc)
- By default action will verify Sigstore keyless flow (Fulcio CA + Rekor log) while using github (See example below).
- Verify signer identity, for example Github workflow ids (2DO Add Input argument).
- Download attestations (signed SBOMs) from scribe service (Not supported yet).
- Verify attestations via OPA/CUE policies (see cocosign documentation).
- Verify trust of a image (local or remote) (see example below).
- Verify trust of a local directory (see example below).

## Gensbom install
Action installs gensbom locally allowing full access to all the CLI options.
Command allows users to utilize gensbom in a non containerized envrionment.
- Generate/verify SBOM from docker daemon images
- Generate/sign local directories (not mapped to the working dir)
- Use a workflow global cache directory
- Use gensbom functionality not exposed by containerized actions.

## Input arguments
### Bom Action input
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
  format2:
    description: 'Sbom formatter, options=[cyclonedx-json cyclonedx-xml attest-cyclonedx-json statement-cyclonedx-json]'
  format3:
    description: 'Sbom formatter, options=[cyclonedx-json cyclonedx-xml attest-cyclonedx-json statement-cyclonedx-json]'
  output-directory:
    description: 'Report output directory'
    default: ./gensbom_reports
  output-file:
    description: 'Output result to file'
  name:
    description: 'Custom/project name'
  label:
    description: 'Custom label'
  label2:
    description: 'Custom label 2'
  label3:
    description: 'Custom label 3'
  env:
    description: 'Custom env'
  env2:
    description: 'Custom env 2'
  env3:
    description: 'Custom env 3'
  filter-regex:
    description: 'Filter out files by regex'
  filter-regex2:
    description: 'Filter out files by regex 2'
    default: .*\.pyc
  filter-regex3:
    description: 'Filter out files by regex 3'
    default: \.git/.*
  collect-regex:
    description: 'Collect files content by regex'
  collect-regex2:
    description: 'Collect files content by regex'
  collect-regex3:
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

### Bom Action output
```yaml
  output-file:
    description: 'Bom output file path'
```


### Verify Action

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
  filter-regex2:
    description: 'Filter out files by regex 2'
    default: .*\.pyc
  filter-regex3:
    description: 'Filter out files by regex 3'
    default: \.git/.*
  attest-config:
    description: 'Attestation config map'
  attest-name:
    description: 'Attestation config name (default "gensbom")'
  attest-default:
    description: 'Attestation default config, options=[sigstore sigstore-github x509]'
    default: sigstore-github
```

### Installer action
Currently action only supports linux debian installation (ubuntu jobs)
Action adds default github gensbom configuration to XDG_CONFIG_HOME/gensbom/ sub dir (to overwrite use `--config` when running gensbom).
```yaml
  version:
    description: 'specific version'
    required: false
```
---

## Integration examples
Full full capabilities and details of the `gensbom` and `cocoaign` please reference related documentations.

### Generate SBOM - cyclonedx
<details>
  <summary>  Remote docker image SBOM </summary>

### Generate from remote image
Create SBOM from remote `busybox:latest` image, skip if found by cache.

```YAML
- name: Generate cyclonedx json SBOM
  uses: scribe-security/actions/gensbom/bom@master
  with:
    target: 'busybox:latest'
    format: json
``` 
### Generate from remote image in custom registry
Custom public registry, skip cache (using `Force`), output verbose (debug level) log output.
```YAML
- name: Generate cyclonedx json SBOM
  uses: scribe-security/actions/gensbom/bom@master
  with:
    target: 'scribesecuriy.jfrog.io/scribe-docker-public-local/stub_remote:latest'
    verbose: 3
    force: true
```

### Custom user metadata
Custom metadata added to sbom
Data will be included in signed payload when output is an attestation.
```YAML
- name: Generate cyclonedx json SBOM - add metadata - labels, envs, name
  id: gensbom_labels
  uses: scribe-security/actions/gensbom/bom@master
  with:
      target: 'busybox:latest'
      verbose: 3
      format: json
      force: true
      name: name_value
      env: test_env
      label: test_label
  env:
    test_env: test_env_value
```
</details>


<details>
  <summary> Upload SBOM artifact </summary>

Upload sbom as CI artifact

```YAML
- name: Generate cyclonedx json SBOM
  uses: scribe-security/actions/gensbom/bom@master
  with:
    target: 'busybox:latest'
    format: json

- uses: actions/upload-artifact@v2
  with:
    name: gensbom-busybox-output-test
    path: ${{ steps.gensbom_json.outputs.OUTPUT_PATH }}
``` 
</details>

<details>
  <summary> Local docker archive </summary>

Create SBOM from local `docker save ...` output.

```YAML
- name: Build and save local docker archive
  uses: docker/build-push-action@v2
  with:
    context: .
    file: .github/workflows/fixtures/Dockerfile_stub
    tags: scribesecuriy.jfrog.io/scribe-docker-public-local/stub_local:latest
    outputs: type=docker,dest=stub_local.tar

- name: Generate cyclonedx json SBOM
  uses: scribe-security/actions/gensbom/bom@master
  with:
    type: docker-archive
    target: '/github/workspace/stub_local.tar'
``` 
</details>

<details>
  <summary> Local OCI archive </summary>

Create SBOM from local oci archive.

```YAML
- name: Build and save local oci archive
  uses: docker/build-push-action@v2
  with:
    context: .
    file: .github/workflows/fixtures/Dockerfile_stub
    tags: scribesecuriy.jfrog.io/scribe-docker-public-local/stub_local:latest
    outputs: type=docker,dest=stub_oci_local.tar

- name: Generate cyclonedx json SBOM
  uses: scribe-security/actions/gensbom/bom@master
  with:
    type: oci-archive
    target: '/github/workspace/stub_oci_local.tar'
``` 
</details>

<details>
  <summary> Local directory </summary>

Create SBOM from local directory. \
Note directory must be mapped to working dir for  actions to access (containerized action).
<!-- 2DO support for local tool action examples -->

```YAML
- name: Create dir
  run: |
    mkdir testdir
    echo "test" > testdir/test.txt

- name: gensbom attest dir
  id: gensbom_attest_dir
  uses: scribe-security/actions/gensbom/bom@master
  with:
    type: dir
    target: '/github/workspace/testdir'
``` 
</details>

### Signing SBOM - attestation
<details>
  <summary> Sign targets </summary>

### Signing targets
Create and sign SBOM targets, skip if found signed SBOM by cache. \
Targets: `registry`, `docker-archive`, `oci-archive`, `dir`.
Note: Default attestation config **Required** `id-token` permission access. \
Note: `docker` in target `type` is not accessible because it requires docker daemon (containerized actions)
Default attestation config: `sigstore-config` - Github workload identity and sigstore (Fulcio, Rekor).

```YAML
job_example:
  runs-on: ubuntu-latest
  permissions:
    id-token: write
  steps:
    - name: gensbom attest
    uses: scribe-security/actions/gensbom/bom@master
    with:
        target: 'busybox:latest'
        format: attest
``` 

</details>

<details>
  <summary> Verify targets </summary>

Verify targets against a signed attestation. \
Note: `docker` in target `type` field (is not accessible because it requires docker daemon (containerized actions) \
Default attestation config: `sigstore-config` - sigstore (Fulcio, Rekor).

```YAML
- name: gensbom verify
  uses: scribe-security/actions/gensbom/verify@master
  with:
    target: 'busybox:latest'
``` 

</details>

<details>
  <summary> Full image signing flow </summary>

Full job example of a image signing and verifying flow.

```YAML
 gensbom-busybox-test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      id-token: write
    steps:

      - uses: actions/checkout@v2
        with:
          fetch-depth: 0

      - name: gensbom attest
        id: gensbom_attest
        uses: scribe-security/actions/gensbom/bom@master
        with:
           target: 'busybox:latest'
           verbose: 3
           format: attest
           force: true

      - name: gensbom verify
        id: gensbom_verify
        uses: scribe-security/actions/gensbom/verify@master
        with:
           target: 'busybox:latest'
           verbose: 3

      - uses: actions/upload-artifact@v2
        with:
          name: gensbom-busybox-test
          path: gensbom_reports
``` 

</details>

<details>
  <summary> Full directory signing flow </summary>

Full job example of a directory signing and verifying flow.

```YAML
  gensbom-dir-test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      id-token: write
    steps:

      - uses: actions/checkout@v2
        with:
          fetch-depth: 0

      - name: gensbom attest workdir
        id: gensbom_attest_dir
        uses: scribe-security/actions/gensbom/bom@master
        with:
           type: dir
           target: '/github/workspace/'
           verbose: 3
           format: attest
           force: true

      - name: gensbom verify workdir
        id: gensbom_verify_dir
        uses: scribe-security/actions/gensbom/verify@master
        with:
           type: dir
           target: '/github/workspace/'
           verbose: 3
      
      - uses: actions/upload-artifact@v2
        with:
          name: gensbom-workdir-reports
          path: |
            gensbom_reports      
``` 

</details>


### General
<details>
  <summary> Upload artifacts (local cache)</summary>

Input field `output-directory` specifics (default `gensbom_reports`) the location of cache output.
You can upload results as workflow artifacts.

```YAML

- uses: actions/upload-artifact@v2
  with:
    name: gensbom-busybox-reports
    path: gensbom_reports
``` 

</details>

<details>
  <summary> Install gensbom (tool) </summary>

Install gensbom as a tool
```YAML
- name: install gensbom
  uses: scribe-security/actions/gensbom/installer@master

- name: gensbom run
  run: |
    gensbom --version
    gensbom bom busybox:latest -vv
``` 

</details>

## Custom configuration
Add a `.gensbom.yaml` file at your repository or pass with `--config` \
for more [gensbom configuration](https://github.com/scribe-security/gensbom) \
You may add a `.cocosign.yaml` file at your repository or pass with `--config` \
for more [Cocosign configuration](https://github.com/scribe-security/cocosign)

