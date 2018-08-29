# Azure Ubuntu Image

#####*PLEASE DO NOT PUT ANYTHING IN HERE THAT DOES NOT BELONG ON EVERY VM!*

This image takes the latest image and:

* Applies all latest patches.

Building Ubuntu
========================

 ```packer build -var-file secrets.json -var-file <DEPCODE>.json ubuntu.json```
 or
  ```packer build -var-file <DEPCODE>.json ubuntu.json```

## Notes:

1. Requires creating and passing in a deployment-specific config file, as images can’t be shared between accounts.

## Appendix:

Provisioning Packer Application Registration

1. Confirm Terraform has created a Packer Resource Group.
2. Build out a new <DEPCODE>.json