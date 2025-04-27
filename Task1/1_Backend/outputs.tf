output "account_name" {
  value = yandex_iam_service_account.sa_infrastr.name
}
output "account_id" {
  value = yandex_iam_service_account.sa_infrastr.id
}
output "bucket_name" {
  value = yandex_storage_bucket.buck-01.bucket
}
output "access_key" {
  value = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  sensitive = true
}
output "secret_key" {
  value = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  sensitive = true
}