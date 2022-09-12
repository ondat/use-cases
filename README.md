# Ondat Use Cases

- [Ondat Use Cases](#ondat-use-cases)
  - [Overview](#overview)
  - [Use Cases](#use-cases)
    - [Linux-IO (LIO) Init Container](#linux-io-lio-init-container)
    - [FIO Container](#fio-container)
    - [Scripts](#scripts)
    - [Custom Ondat Storage Classes](#custom-ondat-storage-classes)
  - [Contributing](#contributing)
  - [License](#license)
  - [Code of Conduct](#code-of-conduct)
  - [Security](#security)

## Overview

This project repository aims to provide examples, tests, scripts and manifests on how to use and validate Ondat with stateful applications on Kubernetes & OpenShift clusters.

## Use Cases

### Linux-IO (LIO) Init Container

- This is documentation on how to deploy a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) to install [Linux-IO (LIO)](https://en.wikipedia.org/wiki/LIO_%28SCSI_target%29) related kernel modules on older releases such as [Ubuntu 18.04 LTS (Bionic Beaver)](https://wiki.ubuntu.com/BionicBeaver/ReleaseNotes)

### FIO Container
 
 - This is a documentation on how to deploy a [Kubernetes Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/)  which will run the `volbench` test script - which is a wrapper around the [Flexible I/O (FIO) CLI utility](https://fio.readthedocs.io/en/latest/fio_doc.html) for performance testing.

### Scripts

- This scripts directory contains useful scripts for automating [Day-2 operations](https://docs.ondat.io/docs/operations/) when managing Ondat. 

### Custom Ondat Storage Classes

- This directory contains examples of custom Ondat [Storage Classes](https://docs.ondat.io/docs/operations/storageclasses/)  that leverage Ondat feature labels.

## Contributing

-   Contribution guidelines for this project can be found in the  [Contributing](./CONTRIBUTING.md)  document.

## License

-   Licensed under the  [Apache License, Version 2.0](./LICENSE).

## Code of Conduct

-  For more information on the project's CoC, review the [Code of Conduct](./CODE_OF_CONDUCT.md) document.

## Security 

- For more information on the project's security policy and how to report potential security issues, review the [Security](./SECURITY.md) document.