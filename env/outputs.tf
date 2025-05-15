output "db_instance_uri" {
    value = "postgres://root:rootpass@${module.db.db_instance_address}/${var.environment}maindb"
}
