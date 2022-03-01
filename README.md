---
title: Bomber
author: mikey strauss - Scribe
date: March 1, 2022
geometry: margin=2cm
---
# 🚀 GitHub Action for SBOM Generation (Scribe)
Included GitHub Actions uses the [Bomber](https://github.com/scribe-security/bomber) cli tool. \
Actions allow one to both generate manage sign and verify image and directory targets.
* Attestation options are based on the [cocosign](https://github.com/scribe-security/cocosign) FM,
Which allows a wide range of signing and verifing flows including KMS, and Sigstore flows.
By default action will default to .

## Bom action
The action invokes a containerized `bomber` sub command `bom`. 
Command allows users to create and upload SBOMs.
- By default action will include github specific context to its SBOMs (GIT_URL, DOB_ID .. etc)
- By default action will sign Sigstore keyless flow while using github own workload auth as a OIDC identity (See example below).
- Generates detailed SBOMs for images and directories (mapped to working dir) targets. 
- Upload SBOMs to scribe service (Not supported yet)
- Save SBOMs by any CI tool (action output includes local stored SBOMs).
- Supported Cached SBOMs/attestations locally
- Supported Cached SBOMs/attestations by Scribe service (TBD).
- Support Private registries (TBD)

## Verify action
The action invokes a containerized `bomber` sub command `verify`.
Command allows users to verify a image via a signed attestation (Intoto).
- By default action will include github specific context to its SBOMs (GIT_URL, DOB_ID .. etc)
- By default action will verify Sigstore keyless flow (Fulcio CA + Rekor log) while using github (See example below).
- Verify signer identity, for example Github workflow ids (2DO Add Input argument).
- Download attestations (signed SBOMs) from scribe service (Not supported yet).
- Verify attestations via OPA/CUE policies (see cocosign documentation).
- Verify trust of a image (local or remote) (see example below).
- Verify trust of a local directory (see example below).

## Input arguments
### Bom Action
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
    default: ./bomber_reports
  output-file:
    description: 'Output result to file'
  name:
    description: 'Custom/project name'
  force:
    description: 'Force overwrite cache'
    default: false
  attest-config:
    description: 'Attestation config map'
  attest-name:
    description: 'Attestation config name (default "bomber")'
  attest-default:
    description: 'Attestation default config, options=[sigstore sigstore-github x509]'
    default: sigstore-github
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
  output-directory:
    description: 'report output directory'
    default: ./bomber_reports
  output-file:
    description: 'Output result to file'
  name:
    description: 'Custom/project name'
  attest-config:
    description: 'Attestation config map'
  attest-name:
    description: 'Attestation config name (default "bomber")'
  attest-default:
    description: 'Attestation default config, options=[sigstore sigstore-github x509]'
    default: sigstore-github
```
---

## Integration examples
Full full capabilities and details of the `bomber` and `cocoaign` please reference related documentations.

### Generate SBOM - cyclonedx
<details>
  <summary>  Remote docker image SBOM </summary>

### Generate from remote image
Create SBOM from remote `busybox:latest` image, skip if found by cache.

```YAML
- name: Generate cyclonedx json SBOM
  uses: scribe-security/bomber-action/bom@v23
  with:
    target: 'busybox:latest'
    format: json
``` 
### Generate from remote image in custom registry
Custom public registry, skip cache (using `Force`), output verbose (debug level) log output.
```YAML
- name: Generate cyclonedx json SBOM
  uses: scribe-security/bomber-action/bom@v23
  with:
    target: 'scribesecuriy.jfrog.io/scribe-docker-public-local/stub_remote:latest'
    verbose: 3
    force: true
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
  uses: scribe-security/bomber-action/bom@v23
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
  uses: scribe-security/bomber-action/bom@v23
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

- name: Bomber attest dir
  id: bomber_attest_dir
  uses: scribe-security/bomber-action/bom@v23
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
    - name: Bomber attest
    uses: scribe-security/bomber-action/bom@v23
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
- name: Bomber verify
  uses: scribe-security/bomber-action/verify@v23
  with:
    target: 'busybox:latest'
``` 

</details>

<details>
  <summary> Full image signing flow </summary>

Full job example of a image signing and verifying flow.

```YAML
 bomber-busybox-test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      id-token: write
    steps:

      - uses: actions/checkout@v2
        with:
          fetch-depth: 0

      - name: Bomber attest
        id: bomber_attest
        uses: scribe-security/bomber-action/bom@v23
        with:
           target: 'busybox:latest'
           verbose: 3
           format: attest
           force: true

      - name: Bomber verify
        id: bomber_verify
        uses: scribe-security/bomber-action/verify@v23
        with:
           target: 'busybox:latest'
           verbose: 3

      - uses: actions/upload-artifact@v2
        with:
          name: bomber-busybox-test
          path: bomber_reports
``` 

</details>

<details>
  <summary> Full directory signing flow </summary>

Full job example of a directory signing and verifying flow.

```YAML
  bomber-dir-test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      id-token: write
    steps:

      - uses: actions/checkout@v2
        with:
          fetch-depth: 0

      - name: Bomber attest workdir
        id: bomber_attest_dir
        uses: scribe-security/bomber-action/bom@v23
        with:
           type: dir
           target: '/github/workspace/'
           verbose: 3
           format: attest
           force: true

      - name: Bomber verify workdir
        id: bomber_verify_dir
        uses: scribe-security/bomber-action/verify@v23
        with:
           type: dir
           target: '/github/workspace/'
           verbose: 3
      
      - uses: actions/upload-artifact@v2
        with:
          name: bomber-workdir-reports
          path: |
            bomber_reports      
``` 

</details>

### General
<details>
  <summary> Upload artifacts (local cache)</summary>

Input field `output-directory` specifics (default `bomber_reports`) the location of cache output.
You can upload results as workflow artifacts.

```YAML

- uses: actions/upload-artifact@v2
  with:
    name: bomber-busybox-reports
    path: bomber_reports
``` 

</details>

## Custom configuration
Add a `.bomber.yaml` file at your repository or pass with `--config` \
for more [Bomber configuration](https://github.com/scribe-security/bomber) \
You may add a `.cocosign.yaml` file at your repository or pass with `--config` \
for more [Cocosign configuration](https://github.com/scribe-security/cocosign)

