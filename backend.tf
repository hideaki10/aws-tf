terraform {
  backend "s3" {
    bucket = "terraform-remote-state-demo-20250418-tokyo"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
    use_lockfile = true
  }
}