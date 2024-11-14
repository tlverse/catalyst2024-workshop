# Installation

These instructions are intended to help with setting up the included [`renv`
virtual environment](https://rstudio.github.io/renv/index.html), which ensures
all course participants are using the same exact set of `R` packages (and
package versions). A few important notes to keep in mind:

* When `R` is started from the top level of this repository, `renv` is
  activated automatically. There is no further action required on your part. If
  `renv` is not installed, it will be installed automatically, assuming that you
  have an active internet connection.
* While `renv` is active, the `R` session will only have access to the packages
  (and their dependencies) that are listed in the `renv.lock` file -- that is,
  you should not expect to have access to any other `R` packages that may be
  installed elsewhere on the computing system in use.
* Upon an initial attempt, `renv` will prompt you to install packages listed in
  the `renv.lock` file, by printing a message like the following:
  ```r
  * Project 'PATH/TO/catalyst2024_workshop' loaded. [renv 0.17.3]
  * The project may be out of sync -- use `renv::status()` for more details.
  > renv::status()
  The following package(s) are recorded in the lockfile, but not installed:
  # A list of packages will appear here
  Use `renv::restore()` to install these packages.
  ```
In any such case, please call `renv::restore()` to install any missing packages.
Note that you do _not_ need to manually install the packages via
`install.packages()`, `remotes::install_github()`, or similar.

For details on how the `renv` system works, the following references may be
helpful:

1. [Collaborating with
    `renv`](https://rstudio.github.io/renv/articles/collaborating.html)
2. [Introduction to `renv`](https://rstudio.github.io/renv/articles/renv.html)

In some rare cases, `R` packages that `renv` automatically tries to install as
part of the `renv::restore()` process may fail due to missing systems-level
dependencies. In such cases, a reference to the missing dependencies and
system-specific instructions their installation involving, e.g., [Ubuntu
Linux's `apt`](http://manpages.ubuntu.com/manpages/bionic/man8/apt.8.html) or
[`homebrew` for macOS](https://brew.sh/), will usually be displayed.
