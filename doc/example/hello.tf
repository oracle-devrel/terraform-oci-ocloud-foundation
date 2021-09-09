// run the file with
// terraform apply -auto-approve

# Declare a variable
variable "salute" {
  type    = string
  default = "Hello World"
}

# Output the content of the variable
output "greeting" { value = var.salute }