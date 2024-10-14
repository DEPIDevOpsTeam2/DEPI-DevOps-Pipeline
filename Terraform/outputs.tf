# Ec2 public ip to be used in Ansible
output "host_ip" {
  value = aws_instance.solar_system_app.public_ip
}

# doc db cluster connection string to be used in Ansible
output "mongo_uri" {
  value     = "mongodb://${var.db_username}:${var.db_password}@${aws_docdb_cluster.solar_system_db.endpoint}:27017/?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
  sensitive = true
}

# bucket name to be used in Ansible
output "s3_bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

# clutser .pem file key to be used in Ansible
output "s3_mongo_access_key" {
  value = aws_s3_object.my_pem_file.key
}

# .json file key to be used in Ansible
output "s3_mongo_db_key" {
  value = aws_s3_object.my_json_file.key
}

output "host_user" {
  value = "ubuntu"
}

output "host_become_pass" {
  value = var.ec2_root_password
  sensitive = true
}
