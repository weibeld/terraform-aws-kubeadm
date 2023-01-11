# Development notes

## Load module from alternative sources

The following contains instruction for [loading the module](https://developer.hashicorp.com/terraform/language/modules/sources) from other sources than the Terraform Registry, which is especially useful during development for testing unpublished changes.

### GitHub

To load the module from GitHub, use:

```hcl
module "my_cluster" {
  source = "github.com/weibeld/terraform-aws-kubeadm?ref=<ref>
  # ...
}
```

`<ref>` is the desired branch or tag name of the repository.

To force re-downloading the module (e.g. after pushing additional commits to a branch), you can use:

```bash
terraform init --upgrade
```

### Local path

To load the module from the local file system, use:

```hcl
module "my_cluster" {
  source = "<path>/terraform-aws-kubeadm"
  # ...
}

`<path>` is the absolute or relative path to the root directory of this repository.

> Note: if using a relative path, the module code is referenced from its original location rather than being copied into the current directory. This has the advantage that changes to the module code are immediately picked up, without the need to run `terraform init` again.
