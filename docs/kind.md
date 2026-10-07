# Local cluster with kind

`make kind-up` creates or verifies the named disposable `superlab` cluster and waits for its nodes. It fails if Docker or cluster creation fails. Every kubectl operation names `--context kind-superlab`, so an unrelated current context is not used.

The quickstart installs no addons. Earlier metrics, ingress, and monitoring bootstrap suggestions are architecture ideas rather than a reproducible verified installation. Select and pin addon versions in a separate exercise before adding them.

`make kind-down` deletes only the explicitly named `superlab` cluster. This operation discards that lab's data.
