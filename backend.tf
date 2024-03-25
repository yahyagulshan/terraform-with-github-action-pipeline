terraform {
  backend "local" {

		path = "./state/terraform.tfstate"
	}
}


terraform {
  backend "s3" {
    bucket = "yahya-backend-234234234234"
    key    = "terraform.tfstate"
    region = "us-east-1"

    # Optional: Encrypt the state file at rest using a KMS key
    # encrypt = true
    # kms_key_id = "arn:aws:kms:your-region:your-account-id:alias/your-kms-alias"
  }
}

