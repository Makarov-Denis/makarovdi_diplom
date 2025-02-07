# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

### Решение

1. Создал новый workspace и сервисный аккаунт в нем
(![image](https://github.com/user-attachments/assets/b90f1daf-8ed9-4815-8ec6-84368712f171)

2. Для подготовки ```backend``` для Terraform выбрал рекомендуемый вариант S3 bucket:
- для начала подготовил [bucket.tf](https://github.com/Makarov-Denis/makarovdi_diplom/blob/main/terraform/bucket/bucket.tf) для создания сервисного аккаунта по управлению bucket и созданию хранилища для backend, нужные данные для доступа к bucket выносятся в файл ```secret.backend.tfvars``` для инициализации основного terraform:

<details>
<summary>terraform apply</summary>

```
admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom/terraform/bucket$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # local_file.backendConf will be created
  + resource "local_file" "backendConf" {
      + content              = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../secret.backend.tfvars"
      + id                   = (known after apply)
    }

  # yandex_iam_service_account.sa-diplom will be created
  + resource "yandex_iam_service_account" "sa-diplom" {
      + created_at = (known after apply)
      + folder_id  = (known after apply)
      + id         = (known after apply)
      + name       = "sa-diplom"
    }

  # yandex_iam_service_account_static_access_key.sa-static-key will be created
  + resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
      + access_key                   = (known after apply)
      + created_at                   = (known after apply)
      + description                  = "static access key"
      + encrypted_secret_key         = (known after apply)
      + id                           = (known after apply)
      + key_fingerprint              = (known after apply)
      + output_to_lockbox_version_id = (known after apply)
      + secret_key                   = (sensitive value)
      + service_account_id           = (known after apply)
    }

  # yandex_resourcemanager_folder_iam_member.diplom-editor will be created
  + resource "yandex_resourcemanager_folder_iam_member" "diplom-editor" {
      + folder_id = "b1gusa0rlmql2290uftn"
      + id        = (known after apply)
      + member    = (known after apply)
      + role      = "editor"
    }

  # yandex_storage_bucket.makarov-bucket will be created
  + resource "yandex_storage_bucket" "makarov-bucket" {
      + access_key            = (known after apply)
      + acl                   = "private"
      + bucket                = "makarov-bucket"
      + bucket_domain_name    = (known after apply)
      + default_storage_class = (known after apply)
      + folder_id             = (known after apply)
      + force_destroy         = true
      + id                    = (known after apply)
      + secret_key            = (sensitive value)
      + website_domain        = (known after apply)
      + website_endpoint      = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_iam_service_account.sa-diplom: Creating...
yandex_iam_service_account.sa-diplom: Creation complete after 3s [id=ajeono65pupbr6ehpnf5]
yandex_iam_service_account_static_access_key.sa-static-key: Creating...
yandex_resourcemanager_folder_iam_member.diplom-editor: Creating...
yandex_iam_service_account_static_access_key.sa-static-key: Creation complete after 1s [id=ajeb5fi04sbkkce9efaq]
yandex_resourcemanager_folder_iam_member.diplom-editor: Creation complete after 2s [id=b1gusa0rlmql2290uftn/editor/serviceAccount:ajeono65pupbr6ehpnf5]
yandex_storage_bucket.makarov-bucket: Creating...
yandex_storage_bucket.makarov-bucket: Creation complete after 5s [id=makarov-bucket]
local_file.backendConf: Creating...
local_file.backendConf: Creation complete after 0s [id=2c17e76de116f7d6c227d6eaca4186dd7120a8af]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

```

```

admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom/terraform$ terraform apply --auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.k8s-cluster[0] will be created
  + resource "yandex_compute_instance" "k8s-cluster" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hardware_generation       = (known after apply)
      + hostname                  = "node-0"
      + id                        = (known after apply)
      + labels                    = {
          + "index" = "0"
        }
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+Un49iURjEWYb6tLytVstJT5/xZ9iTOGvo8QwLcU8a admden@admden-VirtualBox
            EOT
        }
      + name                      = "node-0"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v2"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8l04iucc4vsh00rkb1"
              + name        = (known after apply)
              + size        = 30
              + snapshot_id = (known after apply)
              + type        = "network-ssd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.k8s-cluster[1] will be created
  + resource "yandex_compute_instance" "k8s-cluster" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hardware_generation       = (known after apply)
      + hostname                  = "node-1"
      + id                        = (known after apply)
      + labels                    = {
          + "index" = "1"
        }
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+Un49iURjEWYb6tLytVstJT5/xZ9iTOGvo8QwLcU8a admden@admden-VirtualBox
            EOT
        }
      + name                      = "node-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v2"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-b"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8l04iucc4vsh00rkb1"
              + name        = (known after apply)
              + size        = 30
              + snapshot_id = (known after apply)
              + type        = "network-ssd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.k8s-cluster[2] will be created
  + resource "yandex_compute_instance" "k8s-cluster" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hardware_generation       = (known after apply)
      + hostname                  = "node-2"
      + id                        = (known after apply)
      + labels                    = {
          + "index" = "2"
        }
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+Un49iURjEWYb6tLytVstJT5/xZ9iTOGvo8QwLcU8a admden@admden-VirtualBox
            EOT
        }
      + name                      = "node-2"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v2"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-d"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8l04iucc4vsh00rkb1"
              + name        = (known after apply)
              + size        = 30
              + snapshot_id = (known after apply)
              + type        = "network-ssd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_vpc_network.app-net will be created
  + resource "yandex_vpc_network" "app-net" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "app-net"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.app-subnet-zones[0] will be created
  + resource "yandex_vpc_subnet" "app-subnet-zones" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-ru-central1-a"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.1.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.app-subnet-zones[1] will be created
  + resource "yandex_vpc_subnet" "app-subnet-zones" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-ru-central1-b"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.2.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.app-subnet-zones[2] will be created
  + resource "yandex_vpc_subnet" "app-subnet-zones" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-ru-central1-d"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.3.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-d"
    }

Plan: 7 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_nodes = {
      + node-0 = (known after apply)
      + node-1 = (known after apply)
      + node-2 = (known after apply)
    }
  + internal_ip_address_nodes = {
      + node-0 = (known after apply)
      + node-1 = (known after apply)
      + node-2 = (known after apply)
    }
yandex_vpc_network.app-net: Creating...
yandex_vpc_network.app-net: Creation complete after 2s [id=enpd8f6b4lkg4q8cha8b]
yandex_vpc_subnet.app-subnet-zones[2]: Creating...
yandex_vpc_subnet.app-subnet-zones[0]: Creating...
yandex_vpc_subnet.app-subnet-zones[1]: Creating...
yandex_vpc_subnet.app-subnet-zones[2]: Creation complete after 1s [id=fl80dnc9suftd1l46jli]
yandex_vpc_subnet.app-subnet-zones[0]: Creation complete after 1s [id=e9b6ndap2loucusqtn83]
yandex_vpc_subnet.app-subnet-zones[1]: Creation complete after 1s [id=e2llogngq9kto8s1dio7]
yandex_compute_instance.k8s-cluster[0]: Creating...
yandex_compute_instance.k8s-cluster[1]: Creating...
yandex_compute_instance.k8s-cluster[2]: Creating...
yandex_compute_instance.k8s-cluster[1]: Still creating... [10s elapsed]
yandex_compute_instance.k8s-cluster[0]: Still creating... [10s elapsed]
yandex_compute_instance.k8s-cluster[2]: Still creating... [10s elapsed]
yandex_compute_instance.k8s-cluster[1]: Still creating... [20s elapsed]
yandex_compute_instance.k8s-cluster[0]: Still creating... [20s elapsed]
yandex_compute_instance.k8s-cluster[2]: Still creating... [20s elapsed]
yandex_compute_instance.k8s-cluster[0]: Still creating... [30s elapsed]
yandex_compute_instance.k8s-cluster[2]: Still creating... [30s elapsed]
yandex_compute_instance.k8s-cluster[1]: Still creating... [30s elapsed]
yandex_compute_instance.k8s-cluster[1]: Still creating... [40s elapsed]
yandex_compute_instance.k8s-cluster[2]: Still creating... [40s elapsed]
yandex_compute_instance.k8s-cluster[0]: Still creating... [40s elapsed]
yandex_compute_instance.k8s-cluster[0]: Creation complete after 45s [id=fhmdj01pfp956likdh1b]
yandex_compute_instance.k8s-cluster[1]: Creation complete after 50s [id=epd818kdq5iaahlaclba]
yandex_compute_instance.k8s-cluster[2]: Still creating... [50s elapsed]
yandex_compute_instance.k8s-cluster[2]: Still creating... [1m0s elapsed]
yandex_compute_instance.k8s-cluster[2]: Creation complete after 1m3s [id=fv4shdo818cfmo024nla]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_nodes = {
  "node-0" = "89.169.157.113"
  "node-1" = "84.201.167.118"
  "node-2" = "158.160.158.22"
}
internal_ip_address_nodes = {
  "node-0" = "10.10.1.10"
  "node-1" = "10.10.2.25"
  "node-2" = "10.10.3.26"
}

```

```

PLAY RECAP *****************************************************************************************************
node1                      : ok=656  changed=126  unreachable=0    failed=0    skipped=1068 rescued=0    ignored=6   
node2                      : ok=449  changed=71   unreachable=0    failed=0    skipped=679  rescued=0    ignored=1   
node3                      : ok=449  changed=71   unreachable=0    failed=0    skipped=677  rescued=0    ignored=1   

Четверг 30 января 2025  23:21:10 +0300 (0:00:00.084)       0:28:14.567 ******** 
=============================================================================== 
download : Download_file | Download item -------------------------------------------------------------- 137.11s
download : Download_file | Download item -------------------------------------------------------------- 135.78s
container-engine/containerd : Download_file | Download item -------------------------------------------- 59.14s
download : Download_container | Download image if required --------------------------------------------- 49.32s
download : Download_file | Download item --------------------------------------------------------------- 42.26s
download : Download_container | Download image if required --------------------------------------------- 32.91s
download : Download_file | Download item --------------------------------------------------------------- 29.71s
download : Download_file | Download item --------------------------------------------------------------- 29.02s
download : Download_container | Download image if required --------------------------------------------- 28.35s
download : Download_container | Download image if required --------------------------------------------- 27.34s
container-engine/nerdctl : Download_file | Download item ----------------------------------------------- 25.40s
container-engine/crictl : Download_file | Download item ------------------------------------------------ 23.18s
network_plugin/calico : Calico | Copy calicoctl binary from download dir ------------------------------- 20.08s
kubernetes/node : Install | Copy kubelet binary from download dir -------------------------------------- 15.56s
etcd : Check certs | Register ca and etcd admin/member certs on etcd hosts ----------------------------- 15.26s
kubernetes/node : Modprobe Kernel Module for IPVS ------------------------------------------------------ 15.13s
network_plugin/calico : Calico | Create calico manifests ----------------------------------------------- 14.54s
download : Download_container | Download image if required --------------------------------------------- 13.96s
kubernetes/kubeadm : Kubeadm | reload systemd ---------------------------------------------------------- 13.37s
download : Download_container | Download image if required --------------------------------------------- 13.18s
```

```
admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom/kubespray$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-69d8557557-lj7pw   1/1     Running   0          60m
kube-system   calico-node-dt87d                          1/1     Running   0          61m
kube-system   calico-node-vd57z                          1/1     Running   0          61m
kube-system   calico-node-zqmpg                          1/1     Running   0          61m
kube-system   coredns-5c54f84c97-fsvmt                   1/1     Running   0          59m
kube-system   coredns-5c54f84c97-ftmwb                   1/1     Running   0          60m
kube-system   dns-autoscaler-76ddddbbc-szmhq             1/1     Running   0          59m
kube-system   kube-apiserver-node1                       1/1     Running   1          64m
kube-system   kube-controller-manager-node1              1/1     Running   2          64m
kube-system   kube-proxy-hqr4j                           1/1     Running   0          62m
kube-system   kube-proxy-t2hgv                           1/1     Running   0          62m
kube-system   kube-proxy-vd6sx                           1/1     Running   0          62m
kube-system   kube-scheduler-node1                       1/1     Running   1          64m
kube-system   nginx-proxy-node2                          1/1     Running   0          63m
kube-system   nginx-proxy-node3                          1/1     Running   0          63m
kube-system   nodelocaldns-btl5j                         1/1     Running   0          59m
kube-system   nodelocaldns-qczb7                         1/1     Running   0          59m
kube-system   nodelocaldns-zvshx                         1/1     Running   0          59m

admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom/kubespray$ kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
node1   Ready    control-plane   64m   v1.32.0
node2   Ready    <none>          63m   v1.32.0
node3   Ready    <none>          63m   v1.32.0
```

```
admden@admden-VirtualBox:~/test_app$ docker build -t dimakarov/nginx-static-app .
[+] Building 0.3s (8/8) FINISHED                                                                      docker:default
 => [internal] load build definition from Dockerfile                                                            0.1s
 => => transferring dockerfile: 259B                                                                            0.0s
 => [internal] load metadata for docker.io/library/nginx:latest                                                 0.0s
 => [internal] load .dockerignore                                                                               0.0s
 => => transferring context: 2B                                                                                 0.0s
 => [1/3] FROM docker.io/library/nginx:latest                                                                   0.0s
 => [internal] load build context                                                                               0.0s
 => => transferring context: 126B                                                                               0.0s
 => CACHED [2/3] COPY conf /etc/nginx                                                                           0.0s
 => CACHED [3/3] COPY content /usr/share/nginx/html                                                             0.0s
 => exporting to image                                                                                          0.0s
 => => exporting layers                                                                                         0.0s
 => => writing image sha256:adf47357141c4c94d7e94fb887814e74f3789db7754187df6ad3019d4b6cdd21                    0.0s
 => => naming to docker.io/dimakarov/nginx-static-app                                                           0.0s

 admden@admden-VirtualBox:~/test_app$ docker image ls
REPOSITORY                   TAG       IMAGE ID       CREATED          SIZE
dimakarov/nginx-static-app   latest    adf47357141c   32 minutes ago   188MB

admden@admden-VirtualBox:~/test_app$ docker ps
CONTAINER ID   IMAGE                               COMMAND                  CREATED         STATUS                   PORTS                               NAMES
d6c6d644c8d3   dimakarov/nginx-static-app:latest   "/docker-entrypoint.…"   4 minutes ago   Up 4 minutes (healthy)   0.0.0.0:80->80/tcp, :::80->80/tcp   app

```

```
admden@admden-VirtualBox:~/test_app$ docker push dimakarov/nginx-static-app:latest
The push refers to repository [docker.io/dimakarov/nginx-static-app]
22d592f259bd: Pushed 
24c2ba26a69f: Pushed 
11de3d47036d: Pushed 
16907864a2d0: Pushed 
2bdf51597158: Pushed 
0fc6bb94eec5: Pushed 
eda13eb24d4c: Pushed 
67796e30ff04: Pushed 
8e2ab394fabf: Pushed 
latest: digest: sha256:d3f9240ad024f0bdc9b800f2e2388b705030a62a41bbbea02cd3b0a8a86eaffc size: 2192

```

```
admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom$ kubectl create namespace monitoring
namespace/monitoring created
admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom$ kubectl get ns
NAME              STATUS   AGE
default           Active   4h43m
kube-node-lease   Active   4h43m
kube-public       Active   4h43m
kube-system       Active   4h43m
monitoring        Active   2m14s

```

```

admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories
admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈

```

```
admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" already exists with the same configuration, skipping
admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈

admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom$ helm install stable prometheus-community/kube-prometheus-stack --namespace=monitoring
NAME: stable
LAST DEPLOYED: Fri Jan 31 04:38:51 2025
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=stable"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

```
```
admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom/test_myapp$ kubectl get all -n monitoring 
NAME                                                         READY   STATUS    RESTARTS   AGE
pod/alertmanager-stable-kube-prometheus-sta-alertmanager-0   2/2     Running   0          3h33m
pod/myapp-8xrdb                                              1/1     Running   0          82s
pod/myapp-sb4zz                                              1/1     Running   0          82s
pod/prometheus-stable-kube-prometheus-sta-prometheus-0       2/2     Running   0          3h33m
pod/stable-grafana-6fbcd7ccb7-jbd69                          3/3     Running   0          3h33m
pod/stable-kube-prometheus-sta-operator-55cd967c67-dpcwg     1/1     Running   0          3h33m
pod/stable-kube-state-metrics-84d77f7b7c-gqdbt               1/1     Running   0          3h33m
pod/stable-prometheus-node-exporter-c5kkb                    0/1     Pending   0          3h33m
pod/stable-prometheus-node-exporter-qb9hw                    0/1     Pending   0          3h33m
pod/stable-prometheus-node-exporter-xrphp                    0/1     Pending   0          3h33m

NAME                                              TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
service/alertmanager-operated                     ClusterIP      None            <none>        9093/TCP,9094/TCP,9094/UDP      3h33m
service/myapp-service                             NodePort       10.233.24.69    <none>        80:30080/TCP                    83s
service/prometheus-operated                       ClusterIP      None            <none>        9090/TCP                        3h33m
service/stable-grafana                            LoadBalancer   10.233.55.81    <pending>     80:30200/TCP                    3h33m
service/stable-kube-prometheus-sta-alertmanager   ClusterIP      10.233.25.165   <none>        9093/TCP,8080/TCP               3h33m
service/stable-kube-prometheus-sta-operator       ClusterIP      10.233.63.22    <none>        443/TCP                         3h33m
service/stable-kube-prometheus-sta-prometheus     LoadBalancer   10.233.8.172    <pending>     9090:30100/TCP,8080:32095/TCP   3h33m
service/stable-kube-state-metrics                 ClusterIP      10.233.57.178   <none>        8080/TCP                        3h33m
service/stable-prometheus-node-exporter           ClusterIP      10.233.40.17    <none>        9100/TCP                        3h33m

NAME                                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/myapp                             2         2         2       2            2           <none>                   83s
daemonset.apps/stable-prometheus-node-exporter   3         3         0       3            0           kubernetes.io/os=linux   3h33m

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stable-grafana                        1/1     1            1           3h33m
deployment.apps/stable-kube-prometheus-sta-operator   1/1     1            1           3h33m
deployment.apps/stable-kube-state-metrics             1/1     1            1           3h33m

NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/stable-grafana-6fbcd7ccb7                        1         1         1       3h33m
replicaset.apps/stable-kube-prometheus-sta-operator-55cd967c67   1         1         1       3h33m
replicaset.apps/stable-kube-state-metrics-84d77f7b7c             1         1         1       3h33m

NAME                                                                    READY   AGE
statefulset.apps/alertmanager-stable-kube-prometheus-sta-alertmanager   1/1     3h33m
statefulset.apps/prometheus-stable-kube-prometheus-sta-prometheus       1/1     3h33m
```



