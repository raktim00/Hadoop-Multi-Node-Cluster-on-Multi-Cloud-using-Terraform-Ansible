provider "aws" {
  profile = "default"
  region = "ap-south-1"
}

provider "azurerm" {
  features {}
}

provider "google" {
   project     = "exampleproject"
   region      = "asia-south1"
}