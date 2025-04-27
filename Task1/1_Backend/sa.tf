resource "yandex_iam_service_account" "sa_infrastr" {
  folder_id = var.YaCloud.folder_id
  name      = "builder"
}

resource "yandex_resourcemanager_folder_iam_member" "sa_infrastr-perm0" {
  folder_id = var.YaCloud.folder_id
  role      = "admin" 
  member    = "serviceAccount:${yandex_iam_service_account.sa_infrastr.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa_infrastr-perm1" {
  folder_id = var.YaCloud.folder_id
  role      = "storage.admin" 
  member    = "serviceAccount:${yandex_iam_service_account.sa_infrastr.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa_infrastr-perm2" {
  folder_id = var.YaCloud.folder_id
  role      = "storage.editor" 
  member    = "serviceAccount:${yandex_iam_service_account.sa_infrastr.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa_infrastr.id
}
