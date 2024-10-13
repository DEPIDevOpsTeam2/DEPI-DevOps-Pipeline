# Ec2 public ip to be used in Ansible
output "instance_public_ip" {
  value = aws_instance.solar_system_app.public_ip
}

# doc db cluster connection string to be used in Ansible
output "mongodb_connection_string" {
  value     = "mongodb://${var.db_username}:${var.db_password}@${aws_docdb_cluster.solar_system_db.endpoint}:27017/?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
  sensitive = true
}

# clutser .pem file url to be used in Ansible
output "pem_url" {
  value = "s3://${aws_s3_bucket.my_bucket.bucket}.s3.amazonaws.com/${aws_s3_object.my_pem_file.key}"
}

# .json file url to be used in Ansible
output "json_url" {
  value = "s3://${aws_s3_bucket.my_bucket.bucket}.s3.amazonaws.com/${aws_s3_object.my_json_file.key}"
}
