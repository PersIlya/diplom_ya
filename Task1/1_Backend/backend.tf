resource "random_string" "id_bucket" {
  length  = 7
  special = false
  min_numeric     = 3
  upper     = false
}
# resource "random_string" "id_object" {
#   length  = 7
#   special = false
#   upper   = false
# }

resource "yandex_storage_bucket" "buck-01" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "b-${random_string.id_bucket.id}"
}
