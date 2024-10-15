# Ec2 public ip to be used in Ansible
output "host_ip" {
  value = aws_instance.solar_system_app.public_ip
}

# doc db cluster connection string to be used in Ansible
output "mongo_uri" {
  value     = "mongodb://${var.db_username}:${var.db_password}@${aws_docdb_cluster.solar_system_db.endpoint}:27017/${var.db_name}?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
  sensitive = true
}

# ec2 user name to be used in Ansible
output "host_user" {
  value = "ubuntu"
}

# ec2 user password to be used in Ansible
output "host_become_pass" {
  value     = var.ec2_root_password
  sensitive = true
}
