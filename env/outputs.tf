output "db_instance_uri" {
    value = "postgres://root:root@${module.db.db_instance_address}/${var.environment}maindb"
}
