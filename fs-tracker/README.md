# Fs-Tracker Action
This action runs [fs-tracker](https://github.com/scribe-security/fs-tracker) within a job.

It contains two sub-actions:

## start
Action to start running fs-tracker in the background. fs-tracker is started as a privileged docker container, running in detached mode. The action waits for fs-tracker initialization and return only when it is ready.

The action is customizable by input arguments:

- `verbose`
    Set stdout log verbosity.
- `directory`
    Working directory for temporal files and reports.
- `format`
    Report format (`json` or `jsonl`).
- `rules`
    JSON rules (as text, not path to file).
- `processes`
    space separated list of process names/IDs to attach (empty list means all running processes).
- `profile`
    Enable profiling.
- `trace`
    Enable tracing.
- `rusage`
    Enable logging resource usage of processes to stdout.
- `cpu-usage`
    Enable reporting CPU per-core usage so stdout.

## stop
Action to stop a running fs-tracker (created by `start`) and upload reports as artifacts.

Action is customizable by input arguments:

- `directory`
    fs-tracker’s working directory. Should match the argument given to `start`.
- `artifact`
    Name for the report artifact to be uploaded.

## Example
See an example [workflow file](https://github.com/scribe-security/SolarWinds-demo/blob/main/.github/workflows/CleanBuild.yml).
