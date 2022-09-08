---
title: GitHub-actions
author: Mikey Strauss - Scribe
date: June 30, 2022
geometry: margin=2cm
---
# Scribe GitHub actions 🛸
Scribe offers GitHub actions for embedding evidence collecting and integrity verification to your workflows. \
Actions are wrappers to provide CLI tools.
* gensbom - GitHub Action for SBOM Generation (Scribe) 
* Valint - validate supply chain integrity tool
* Fs-tracker - TBD

# 🚀  gensbom actions
Included GitHub Actions uses the [gensbom](https://GitHub.com/scribe-security/gensbom) CLI tool. \
Actions allow one to both collect SBOM evidence for images and directory targets.

Source see [gensbom](https://GitHub.com/scribe-security/gensbom), SBOM generator
Source see [cocosign](https://GitHub.com/scribe-security/cocosign), attestation manager

## Bom action
The action invokes a containerized `gensbom` sub-command `bom`. 
The command allows users to create and upload SBOMs.
- By default, the action will include GitHub-specific context to its SBOMs (GIT_URL, JOB_ID .. etc)
- By default, the action will sign Sigstore keyless flow while using GitHub's own workload auth as an ODIC identity (See example below).
- Generates detailed SBOMs for images and directories (mapped to working dir) targets. 
- Upload SBOMs to scribe service (Not supported yet)
- Save SBOMs by any CI tool (action output includes local stored SBOMs).
- Supported Cached SBOMs/attestations locally
- Supported Cached SBOMs/attestations by Scribe service (TBD).
- Support Private registries (TBD)
- Add custom labels, envs to SBOM and attestations


See details [gensbom - bom action](gensbom/bom/README.md)

## Verify action
The action invokes a containerized `gensbom` sub-command `verify`.
The command allows users to verify an image via a signed attestation (In-toto).
- By default, the action will include GitHub-specific context to its SBOMs (GIT_URL, DOB_ID .. etc)
- By default, the action will verify Sigstore keyless flow (Fulcio CA + Rekor log) while using GitHub (See example below).
- Verify signer identity, for example, GitHub workflow ids.
- Download attestations (signed SBOMs) from Scribe service.
- Verify attestations via OPA/CUE policies (see cocosign documentation).
- Verify the trust of an image (local or remote) (see example below).
- Verify the trust of a local directory (see example below).

See details [gensbom - verify action](gensbom/verify/README.md)

## Tool installer action
You can use the `installer` action to install any scribe tool locally allowing full access to all the CLI options from a terminal interface. \
The command allows users to utilize tools in a non-containerized environment. \

Install the tool locally if you want to:
- Generate/verify evidence (SBOMS) from docker daemon.
- Generate/sign local directories (not mapped to the working dir)
- Generate evidence for a global cache directory
- Use tool functionality not exposed by containerized actions.
Note: Installing gensbom locally is very useful when you want to create an SBOM outside the workflow default workspace directory.

See details [Installer - action](installer/README.md)


# Valint actions 🦀
Included GitHub Actions uses the [valint](https://GitHub.com/scribe-security/valint) CLI tool. \

Valint tool provides a tool to verify the integrity of a supply chain.
The tool allows you to verify and validate the integrity of multiple parts of the supply chain artifacts and flow.

## Report action
Command pulls Scribe reports.
Once a set of evidence is uploaded to the Scribe service a report is generated.
By default, the report is written into the local cache. 

See details [Valint - report action](valint/report/README.md)


## Notice Support
Currently, we only support GitHub Linux workers.
Add condition for multi-OS workflows.
```YAML
- name: gensbom Image generate bom, upload to scribe
  id: gensbom_bom_image
  if: ${{ runner.os == 'Linux' }}
  uses: scribe-security/actions/gensbom/bom@master
  with:
      target: 'mongo-express:1.0.0-alpha.4'
      verbose: 2
```

## .gitignore
Recommended to add output directory value to your .gitignore file.
By default add `**/scribe` to your `.gitignore`.

# Integrations
## Scribe service integration
Scribe provides a set of services to store, verify and manage the supply chain integrity. \
Following are some integration examples.

Scribe integrity flow - upload evidence using `gensbom` and download the integrity report using `valint`. \
You may collect evidence anywhere in your workflows.

<details>
  <summary>  Scribe integrity report - full workflow </summary>

Full workflow example of a workflow, upload evidence using gensbom and download report using Valint.

```YAML
name: example workflow

on: 
  push:
    tags:
      - "*"

jobs:
  scribe-report-test:
    runs-on: ubuntu-latest
    steps:

      - uses: actions/checkout@v2
        with:
          fetch-depth: 0

      - uses: actions/checkout@v3
        with:
          repository: mongo-express/mongo-express
          ref: refs/tags/v1.0.0-alpha.4
          path: mongo-express-scm

      - name: gensbom Scm generate bom, upload to scribe
        id: gensbom_bom_scm
        uses: scribe-security/actions/gensbom/bom@master
        with:
           type: dir
           target: 'mongo-express-scm'
           verbose: 2
           scribe-enable: true
           scribe-client-id: ${{ secrets.client-id }}
           scribe-client-secret: ${{ secrets.client-secret }}

      - name: Build and push remote
        uses: docker/build-push-action@v2
        with:
          context: .
          push: true
          tags: mongo-express:1.0.0-alpha.4

      - name: gensbom Image generate bom, upload to scribe
        id: gensbom_bom_image
        uses: scribe-security/actions/gensbom/bom@master
        with:
           target: 'mongo-express:1.0.0-alpha.4'
           verbose: 2
           scribe-enable: true
           scribe-client-id: ${{ secrets.client-id }}
           scribe-client-secret: ${{ secrets.client-secret }}

      - name: Valint - download report
        id: valint_report
        uses: scribe-security/actions/valint/report@master
        with:
           verbose: 2
           scribe-enable: true
           scribe-client-id: ${{ secrets.client-id }}
           scribe-client-secret: ${{ secrets.client-secret }}

      - uses: actions/upload-artifact@v2
        with:
          name: scribe-reports
          path: |
            ${{ steps.gensbom_bom_scm.outputs.OUTPUT_PATH }}
            ${{ steps.gensbom_bom_image.outputs.OUTPUT_PATH }}
            ${{ steps.valint_report.outputs.OUTPUT_PATH }}
```
</details>


<details>
  <summary>  Scribe integrity report - Multi workflow </summary>

Full workflow example of a workflow, upload evidence using gensbom and download report using valint

```YAML
name: example workflow

on: 
  push:
    tags:
      - "*"

jobs:
  scribe-report-test:
    runs-on: ubuntu-latest
    steps:

      - uses: actions/checkout@v2
        with:
          fetch-depth: 0

      - uses: actions/checkout@v3
        with:
          repository: mongo-express/mongo-express
          ref: refs/tags/v1.0.0-alpha.4
          path: mongo-express-scm

      - name: Build and push remote
        uses: docker/build-push-action@v2
        with:
          context: .
          push: true
          tags: mongo-express:1.0.0-alpha.4

      - name: gensbom Image generate bom, upload to scribe
        id: gensbom_bom_image
        uses: scribe-security/actions/gensbom/bom@master
        with:
           target: 'mongo-express:1.0.0-alpha.4'
           verbose: 2
           scribe-enable: true
           scribe-client-id: ${{ secrets.client-id }}
           scribe-client-secret: ${{ secrets.client-secret }}

      - name: Valint - download report
        id: valint_report
        uses: scribe-security/actions/valint/report@master
        with:
           verbose: 2
           scribe-enable: true
           scribe-client-id: ${{ secrets.client-id }}
           scribe-client-secret: ${{ secrets.client-secret }}

      - uses: actions/upload-artifact@v2
        with:
          name: scribe-reports
          path: |
            ${{ steps.gensbom_bom_scm.outputs.OUTPUT_PATH }}
            ${{ steps.gensbom_bom_image.outputs.OUTPUT_PATH }}
            ${{ steps.valint_report.outputs.OUTPUT_PATH }}
```
</details>

## Valint integration
<details>
  <summary>  Scribe integrity report </summary>

Valint downloading integrity report from scribe service

```YAML
  - name: Valint - download report
    id: valint_report
    uses: scribe-security/actions/valint/report@master
    with:
        verbose: 2
        scribe-enable: true
        scribe-client-id: ${{ inputs.client-id }}
        scribe-client-secret: ${{ inputs.client-secret }}
```
</details>

<details>
  <summary>  Scribe integrity report, select section </summary>

Valint downloading integrity report from scribe service

```YAML
  - name: Valint - download report
    id: valint_report
    uses: scribe-security/actions/valint/report@master
    with:
        verbose: 2
        scribe-enable: true
        scribe-client-id: ${{ inputs.client-id }}
        scribe-client-secret: ${{ inputs.client-secret }}
        section: packages
```
</details>

## gensbom integration
<details>
  <summary>  Public registry image </summary>

Create SBOM from remote `busybox:latest` image, skip if found by the cache.

```YAML
- name: Generate cyclonedx json SBOM
  uses: scribe-security/actions/gensbom/bom@master
  with:
    target: 'busybox:latest'
    format: json
``` 
</details>

<details>
  <summary>  Docker built image </summary>

Create SBOM for image built by local docker `image_name:latest` image, overwrite cache.

```YAML
- name: Generate cyclonedx json SBOM
  uses: scribe-security/actions/gensbom/bom@master
  with:
    type: docker
    target: 'image_name:latest'
    format: json
    force: true
``` 
</details>

<details>
  <summary>  Private registry image </summary>

Custom private registry, skip cache (using `Force`), output verbose (debug level) log output.
```YAML
- name: Generate cyclonedx json SBOM
  uses: scribe-security/actions/gensbom/bom@master
  with:
    target: 'scribesecuriy.jfrog.io/scribe-docker-local/stub_remote:latest'
    verbose: 2
    force: true
```
</details>

<details>
  <summary>  Custom SBOM metadata </summary>

Custom metadata added to SBOM
Data will be included in the signed payload when the output is an attestation.
```YAML
- name: Generate cyclonedx json SBOM - add metadata - labels, envs, name
  id: gensbom_labels
  uses: scribe-security/actions/gensbom/bom@master
  with:
      target: 'busybox:latest'
      verbose: 2
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
  <summary> Save SBOM as artifact </summary>

Using action `output_path` you can access the generated SBOM and store it as an artifact.
```YAML
- name: Generate cyclonedx json SBOM
  id: gensbom_json
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
  <summary> Save SLSA provenance statement as artifact </summary>
Using action `output_path` you can access the generated SBOM and store it as an artifact.

```YAML
- name: Generate SLSA provenance statement
  id: gensbom_slsa_statement
  uses: scribe-security/actions/gensbom/bom@master
  with:
    target: 'busybox:latest'
    format: statement-slsa

- uses: actions/upload-artifact@v2
  with:
    name: scribe-evidence
    path: ${{ steps.gensbom_slsa_statement.outputs.OUTPUT_PATH }}
``` 
</details>

<details>
  <summary> Docker archive image </summary>

Create SBOM from local `docker save ...` output.
```YAML
- name: Build and save local docker archive
  uses: docker/build-push-action@v2
  with:
    context: .
    file: .GitHub/workflows/fixtures/Dockerfile_stub
    tags: scribesecuriy.jfrog.io/scribe-docker-public-local/stub_local:latest
    outputs: type=docker,dest=stub_local.tar

- name: Generate cyclonedx json SBOM
  uses: scribe-security/actions/gensbom/bom@master
  with:
    type: docker-archive
    target: '/GitHub/workspace/stub_local.tar'
``` 
</details>

<details>
  <summary> OCI archive image </summary>

Create SBOM from the local oci archive.

```YAML
- name: Build and save local oci archive
  uses: docker/build-push-action@v2
  with:
    context: .
    file: .GitHub/workflows/fixtures/Dockerfile_stub
    tags: scribesecuriy.jfrog.io/scribe-docker-public-local/stub_local:latest
    outputs: type=docker,dest=stub_oci_local.tar

- name: Generate cyclonedx json SBOM
  uses: scribe-security/actions/gensbom/bom@master
  with:
    type: oci-archive
    target: '/GitHub/workspace/stub_oci_local.tar'
``` 
</details>

<details>
  <summary> Directory target </summary>

Create SBOM from a local directory. \
Note directory must be mapped to working dir for actions to access (containerized action).

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
    target: '/GitHub/workspace/testdir'
``` 
</details>

<details>
  <summary> Attest target (BOM) </summary>

Create and sign SBOM targets, skip if found signed SBOM by the cache. \
Targets: `registry`, `docker-archive`, `oci-archive`, `dir`.
Note: Default attestation config **Required** `id-token` permission access. \
Default attestation config: `sigstore-config` - GitHub workload identity and Sigstore (Fulcio, Rekor).


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
  <summary> Attest target (SLSA) </summary>

Create and sign SBOM targets, skip if found signed SBOM by the cache. \
Targets: `registry`, `docker-archive`, `oci-archive`, `dir`.
Note: Default attestation config **Required** `id-token` permission access. \
Default attestation config: `sigstore-config` - GitHub workload identity and Sigstore (Fulcio, Rekor).

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
        format: attest-slsa
``` 
</details>

<details>
  <summary> Verify target (BOM) </summary>

Verify targets against a signed attestation. \
Note: `docker` in target `type` field (is not accessible because it requires docker daemon (containerized actions) \
Default attestation config: `sigstore-config` - sigstore (Fulcio, Rekor).
gensbom will look for both a bom or slsa attestation to verify against

```YAML
- name: gensbom verify
  uses: scribe-security/actions/gensbom/verify@master
  with:
    target: 'busybox:latest'
``` 

</details>

<details>
  <summary> Verify target (SLSA) </summary>

Verify targets against a signed attestation. \
Note: `docker` in target `type` field (is not accessible because it requires docker daemon (containerized actions) \
Default attestation config: `sigstore-config` - sigstore (Fulcio, Rekor).
gensbom will look for both a bom or slsa attestation to verify against

```YAML
- name: gensbom verify
  uses: scribe-security/actions/gensbom/verify@master
  with:
    target: 'busybox:latest'
    input-format: attest-slsa
``` 

</details>

<details>
  <summary> Attest and verify image (BOM) </summary>

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
           verbose: 2
           format: attest
           force: true

      - name: gensbom verify
        id: gensbom_verify
        uses: scribe-security/actions/gensbom/verify@master
        with:
           target: 'busybox:latest'
           verbose: 2

      - uses: actions/upload-artifact@v2
        with:
          name: gensbom-busybox-test
          path: gensbom_reports
``` 

</details>

<details>
  <summary> Attest and verify image (SLSA) </summary>

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

      - name: gensbom attest slsa
        id: gensbom_attest
        uses: scribe-security/actions/gensbom/bom@master
        with:
           target: 'busybox:latest'
           verbose: 2
           format: attest-slsa
           force: true

      - name: gensbom verify attest slsa
        id: gensbom_verify
        uses: scribe-security/actions/gensbom/verify@master
        with:
           target: 'busybox:latest'
           input-format: attest-slsa
           verbose: 2

      - uses: actions/upload-artifact@v2
        with:
          name: gensbom-busybox-test
          path: gensbom_reports
``` 

</details>

<details>
  <summary> Attest and verify directory </summary>

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
           target: '/GitHub/workspace/'
           verbose: 2
           format: attest
           force: true

      - name: gensbom verify workdir
        id: gensbom_verify_dir
        uses: scribe-security/actions/gensbom/verify@master
        with:
           type: dir
           target: '/GitHub/workspace/'
           verbose: 2
      
      - uses: actions/upload-artifact@v2
        with:
          name: gensbom-workdir-reports
          path: |
            gensbom_reports      
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

<details>
  <summary> Install Valint (tool) </summary>

Install Valint as a tool
```YAML
- name: install gensbom
  uses: scribe-security/actions/gensbom/installer@master
  with:
    tool: valint

- name: valint run
  run: |
    valint --version
    valint report --scribe.client-id $SCRIBE_CLIENT_ID $SCRIBE_CLIENT_SECRET
``` 
</details>



## Integration examples
<details>
  <summary>  Scribe integrity report download </summary>

Download integrity report.

```YAML
    - name: Valint - download integrity report
      id: download_report
      uses: scribe-security/actions/valint/report@master
      with:
          scribe-client-id: ${{ inputs.client-id }}
          scribe-client-secret: ${{ inputs.client-secret }}
``` 
Default output will be set to `scribe/valint/` subdirectory (Use `output-directory` argument to overwrite location).
</details>


<details>
  <summary> Simple download report verbose, custom output path </summary>

Download report for CI run and save the output to a local file.

```YAML
    - name: Valint - download integrity report
      id: download_report
      uses: scribe-security/actions/valint/report@master
      with:
          verbose: 2
          scribe-enable: true
          scribe-client-id: ${{ inputs.client-id }}
          scribe-client-secret: ${{ inputs.client-secret }}
          output-file: "./result_report.json"
``` 
</details>
