# Self-hosted GitHub Actions runner

Self-hosted runners can process GitHub Actions jobs on dedicated servers. In
our case, we have Manager Instance Group on `Google Cloud`. Number of instances
in group controlled by AutoScaler.

All necessary parts are created with `terraform`. To use it we have to do some 
configuration and set variables:

- `GCP_SA_KEY` - contains service account key to access Google Cloud or
  alternatively you can configure `gcloud`
- `TF_VAR_GITHUB_TOKEN` - GitHub token with `public_repo` permission for
  public repositories or `repo` permission for private repositories.
- `TF_API_TOKEN` - token to access app.terraform.io (state storage)

First time you need to prepare your working directory with:

```
terraform init
```

To see what changes in infrastructure are expected:

```
terraform plan 
```

Apply changes:

```
terraform apply
```

In this repository there is no need to run terraform manually and configure
variables. All variables are stored in Secrets. To make changes to the
infrastructure, just create a Pull Request and you can see `plan` check details,
artifacts.
