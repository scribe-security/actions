---
title: Github-actions
author: mikey strauss - Scribe
date: June 30, 2022
geometry: margin=2cm
---
# Scribe github actions 🛸
Scribe offers Github actions for embedding evidence collecting and integrity verification to your workflows. \
Actions are are wrappers to provided CLI tools.
* Gensbom - gitHub Action for SBOM Generation (Scribe) 
* Valint - validate supply chain integrity tool
* Fs-tracker - TBD

# 🚀  Gensbom actions
Included GitHub Actions uses the [gensbom](https://github.com/scribe-security/bomber) cli tool. \
Actions allow one to both collect sbom evidence for images and directory targets.

Source see [gensbom](https://github.com/scribe-security/bomber), Sbom generator
Source see [cocosign](https://github.com/scribe-security/cocosign), attestation manager

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


See details [Gensbom - bom action](gensbom/bom/README.md)

## Verify action
The action invokes a containerized `gensbom` sub command `verify`.
Command allows users to verify a image via a signed attestation (In-toto).
- By default action will include github specific context to its SBOMs (GIT_URL, DOB_ID .. etc)
- By default action will verify Sigstore keyless flow (Fulcio CA + Rekor log) while using github (See example below).
- Verify signer identity, for example Github workflow ids.
- Download attestations (signed SBOMs) from scribe service.
- Verify attestations via OPA/CUE policies (see cocosign documentation).
- Verify trust of a image (local or remote) (see example below).
- Verify trust of a local directory (see example below).

See details [Gensbom - verify action](gensbom/verify/README.md)

## Tool installer action
You can use the `installer` action to install any scribe tool locally allowing full access to all the CLI options from a terminal interface. \
Command allows users to utilize tool in a non containerized environment. \

Install tool locally locally if you want to:
- Generate/verify evidence (SBOMS) from docker daemon.
- Generate/sign local directories (not mapped to the working dir)
- Generate evidencefor a global cache directory
- Use tool functionality not exposed by containerized actions.
Note: Installing gensbom locally is very useful when you want to create an sbom out side the workflow default workspace directory.

See details [Installer - action](installer/README.md)


# Valint actions 🦀
Included GitHub Actions uses the [valint](https://github.com/scribe-security/valint) cli tool. \

Valint tool provides a tool to verify integrity of a supply chain.
Tool allows you to verify and validate the integrity multiple parts of the supply chain artifacts and flow.

## Report action
Command pulls Scribe reports.
Once a set of evidence are uploaded to Scribe service a report is generated.
By default report is written in to local cache. 

See details [Valint - report action](valint/report/README.md)


## Notice Support
Currently we only support Github linux workers.
Add condition for multi OS workflows.
```YAML
- name: Gensbom Image generate bom, upload to scribe
  id: gensbom_bom_image
  if: ${{ runner.os == 'Linux' }}
  uses: scribe-security/actions/gensbom/bom@master
  with:
      target: 'mongo-express:1.0.0-alpha.4'
      verbose: 2
```

## .gitignore
Recommended to add output directory value to your .gitignore file.
By default add `**/scribe` to your gitignore.

# Integrations
## Scribe service integration
Scribe provides a set of services to store,verify and manage the supply chain integrity.
Following are some integration examples.

Scribe integrity flow - upload evidence using `gensbom` and download the integrity report using `valint`.
You may collect evidence anywhere in your workflows.

<details>
  <summary>  Scribe integrity report - full workflow </summary>

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

      - name: Gensbom Scm generate bom, upload to scribe
        id: gensbom_bom_scm
        uses: scribe-security/actions/gensbom/bom@master
        with:
           type: dir
           target: 'mongo-express-scm'
           verbose: 2
           scribe-enable: true
           scribe-clientid: ${{ secrets.clientid }}
           scribe-clientsecret: ${{ secrets.clientsecret }}

      - name: Build and push remote
        uses: docker/build-push-action@v2
        with:
          context: .
          push: true
          tags: mongo-express:1.0.0-alpha.4

      - name: Gensbom Image generate bom, upload to scribe
        id: gensbom_bom_image
        uses: scribe-security/actions/gensbom/bom@master
        with:
           target: 'mongo-express:1.0.0-alpha.4'
           verbose: 2
           scribe-enable: true
           scribe-clientid: ${{ secrets.clientid }}
           scribe-clientsecret: ${{ secrets.clientsecret }}

      - name: Valint - download report
        id: valint_report
        uses: scribe-security/actions/valint/report@master
        with:
           verbose: 2
           scribe-enable: true
           scribe-clientid: ${{ secrets.clientid }}
           scribe-clientsecret: ${{ secrets.clientsecret }}

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

      - name: Gensbom Image generate bom, upload to scribe
        id: gensbom_bom_image
        uses: scribe-security/actions/gensbom/bom@master
        with:
           target: 'mongo-express:1.0.0-alpha.4'
           verbose: 2
           scribe-enable: true
           scribe-clientid: ${{ secrets.clientid }}
           scribe-clientsecret: ${{ secrets.clientsecret }}

      - name: Valint - download report
        id: valint_report
        uses: scribe-security/actions/valint/report@master
        with:
           verbose: 2
           scribe-enable: true
           scribe-clientid: ${{ secrets.clientid }}
           scribe-clientsecret: ${{ secrets.clientsecret }}

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
        scribe-clientid: ${{ inputs.clientid }}
        scribe-clientsecret: ${{ inputs.clientsecret }}
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
        scribe-clientid: ${{ inputs.clientid }}
        scribe-clientsecret: ${{ inputs.clientsecret }}
        section: packages
```
</details>

## Gensbom integration
<details>
  <summary>  Public registry image </summary>

Create SBOM from remote `busybox:latest` image, skip if found by cache.

```YAML
- name: Generate cyclonedx json SBOM
  uses: scribe-security/actions/gensbom/bom@master
  with:
    target: 'busybox:latest'
    format: json
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
    verbose: 3
    force: true
```
</details>

<details>
  <summary>  Custom SBOM metadata </summary>

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
  <summary> Save SBOM as artifact </summary>

Using action `output_path` you can access the generated SBOM and store it as an artifact.
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
  <summary> Docker archive image </summary>

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
  <summary> OCI archive image </summary>

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
  <summary> Directory target </summary>

Create SBOM from local directory. \
Note directory must be mapped to working dir for  actions to access (containerized action).

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

<details>
  <summary> Attest target </summary>

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
  <summary> Verify target </summary>

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
  <summary> Attest and verify image </summary>

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
  <summary> Install valint (tool) </summary>

Install valint as a tool
```YAML
- name: install gensbom
  uses: scribe-security/actions/gensbom/installer@master
  with:
    tool: valint

- name: valint run
  run: |
    valint --version
    valint report --scribe.clientid $SCRIBE_CLIENT_ID $SCRIBE_CLIENT_SECRET
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
