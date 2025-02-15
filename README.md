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
![image](https://github.com/user-attachments/assets/b90f1daf-8ed9-4815-8ec6-84368712f171)

2. Для подготовки ```backend``` для Terraform выбрал рекомендуемый вариант S3 bucket:
- для начала подготовил [bucket.tf](https://github.com/Makarov-Denis/makarovdi_diplom/blob/main/terraform/bucket/bucket.tf) для создания сервисного аккаунта по управлению bucket и созданию хранилища для backend, нужные данные для доступа к bucket выносятся в файл ```secret.backend.tfvars``` для инициализации основного terraform:

<details>
<summary>terraform apply</summary>

```bash
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
</details>

![image](https://github.com/user-attachments/assets/2c29f3f4-2f7b-4f0b-afec-a04a27d17fa5)

- инициализируем основной terraform, используя данные из ```secret.backend.tfvars``` для доступа к bucket:
[provider.tf](https://github.com/Makarov-Denis/makarovdi_diplom/blob/main/terraform/provider.tf)

backend:

![image](https://github.com/user-attachments/assets/adb66d46-37c9-4b5a-bf41-2ae4e2e64e7a)

- создал VPC с подсетями в разных зонах доступности:

![image](https://github.com/user-attachments/assets/90981274-f262-4960-aaf2-e28e34f7a35e)

- выполнение команды ```terraform destroy``` и ```terraform apply``` без дополнительных ручных действий:
<details>
<summary>terraform apply --auto-approve</summary>

```bash
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
  "node-0" = "89.169.132.91"
  "node-1" = "158.160.5.148"
  "node-2" = "158.160.159.48"
}
internal_ip_address_nodes = {
  "node-0" = "10.10.1.31"
  "node-1" = "10.10.2.5"
  "node-2" = "10.10.3.32"
}

```
</details>

- При длительной неактивности Yandex отключает виртуальные машины, при повторном включении происходит смена публичных адресов, что разрушит кластер k8s, который мы будем разворачивать на следующем этапе. Поэтому, на текущем этапе, имеет смысл дополнительно произвести небольшие манипуляции для стабилизации кластера, а именно - зарезервировать полученные адреса к Yandex Cloud:

---

### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

### Решение

Выбран вариант создания кластера k8s, используя Kubespray:

- Скачаем репозиторий, используя команду ```git clone https://github.com/kubernetes-sigs/kubespray```
- Переходим в директорию ```kubespray``` и запускаем установку зависимости ```pip3.11 install -r requirements.txt```
- Создаем директорию ```inventory/mycluster```, копированием образца: ```cp -rfp inventory/sample inventory/mycluster```
- Используя адреса хостов, полученные на прошлом этапе, создадим файл ```hosts.yaml```

- Правим полученный файл под нужды текущей задачи kubespray/inventory/mycluster/hosts.yaml
```bash
all:
  hosts:
    node1:
      ansible_host: 89.169.132.91
      ip: 10.10.1.31
    node2:
      ansible_host: 158.160.5.148
      ip: 10.10.2.5
    node3:
      ansible_host: 158.160.159.48
      ip: 10.10.3.32
  children:
    kube_control_plane:
      hosts:
        node1:
    kube_node:
      hosts:
        node2:
        node3:
    etcd:
      hosts:
        node1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```
- Для доступа к кластеру извне нужно добавить параметр supplementary_addresses_in_ssl_keys: [89.169.132.91] в файл inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml, что является ip мастер ноды.
- И далее запускаем установку Kubernetes командой:
```bash
ansible-playbook -i inventory/mycluster/hosts.yaml -u ubuntu --become --become-user=root cluster.yml
```

```bash

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
- Копируем ~/.kube/config с мастер ноды командой:
```bash
admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom/kubespray$ mkdir -p ~/.kube && ssh ubuntu@89.169.132.91 "sudo cat /root/.kube/config" >> ~/.kube/config
The authenticity of host '89.169.132.91 (89.169.132.91)' can't be established.
ECDSA key fingerprint is SHA256:VxkWCGH1BDzv80B5QKOnwPqi6ZWFgWTWI/Kl+7QhE9o.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '89.169.132.91' (ECDSA) to the list of known hosts.
```
- Заменяем ip на внешний ip мастер ноды: https://89.169.132.91:6443
- Кластер создан, доступно подключение через интернет:

```bash
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
---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

### Решение

Использовать будем рекомендуемый вариант.

Создаём каталог app и подкаталоги conf и content:
```bash
mkdir -p ~/test_app/{conf,content} && cd ~/test_app/
```

- В каталоге test_app создаем [Dockerfile](https://github.com/Makarov-Denis/test_myapp/blob/main/Dockerfile):
```yaml
FROM nginx:latest

# Configuration
COPY conf /etc/nginx
# Content
COPY content /usr/share/nginx/html

#Health Check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost/ || exit 1

EXPOSE 80
```
- Также создаём файл ~/test_app/conf/nginx.conf с конфигурацией 
```yaml
user nginx;
worker_processes 1;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
    multi_accept on;
}

http {
    server {
        listen   80;

        location / {
            gzip off;
            root /usr/share/nginx/html/;
            index index.html;
        }
    }
    keepalive_timeout  60;
}
```
- Cоздаём статическую страницу нашего приложения 
```html
<!DOCTYPE html>
<html lang="ru">

<head>
    <meta charset="utf-8" name="viewport" content="width=device-width, initial-scale=1" />
    <title>Diploma of Makarov Denis</title>
</head>

<body>
    <h2 style="margin-top: 150px; text-align: center;">Student Netology</h2>
</body>

</html>
```
- Создаем образ:

<details>
<summary>docker build -t dimakarov/nginx-static-app .</summary>

```bash
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
```
</details>

- Для проверки соберем и запустим контейнер, проверим доступ к приложению:

admden@admden-VirtualBox:~/test_app$ docker image ls
REPOSITORY                   TAG       IMAGE ID       CREATED          SIZE
dimakarov/nginx-static-app   latest    adf47357141c   32 minutes ago   188MB

admden@admden-VirtualBox:~/test_app$ docker ps
CONTAINER ID   IMAGE                               COMMAND                  CREATED         STATUS                   PORTS                               NAMES
d6c6d644c8d3   dimakarov/nginx-static-app:latest   "/docker-entrypoint.…"   4 minutes ago   Up 4 minutes (healthy)   0.0.0.0:80->80/tcp, :::80->80/tcp   app

![image](https://github.com/user-attachments/assets/863af74a-4dff-476c-86cb-b6a227d645c2)
- Образ успешно собран и приложение отвечает, отправим его в DockerHub:
  
```bash
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
![image](https://github.com/user-attachments/assets/2c8c12cf-0279-4e8d-841c-35cd94745dab)

```bash
docker pull dimakarov/nginx-static-app
```

- Для размещения приложения выбран GitHub:

https://github.com/Makarov-Denis/test_myapp.git

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.
  
### Решение

1. Для деплоя prometheus, grafana, alertmanager выбран вариант работы с helm charts

- Создадим namespace ```monitoring```:
```bash 
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
- Подключим репозиторий с promutheus:
```bash
admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories
admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈

```
- Задеплоим систему мониторинга:
```bash
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
- Проверим состояние мониторинга:
```bash
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
- Для подключения к мониторингу доступа извне требуется настроить сервисы prometheus и grafana, сменить тип сервиса и добавить внешний порт:
![image](https://github.com/user-attachments/assets/ffc77e29-f38d-4eef-9a72-b020f53379f7)

![image](https://github.com/user-attachments/assets/919bc25b-bc5d-4c40-a6fd-f5ccb07acc47)

- Доступ к prometheus http://89.169.132.91:30100
![prometheus](https://github.com/user-attachments/assets/a37b4800-6dba-4163-86df-012e3a634f29)
- Доступ к grafana http://158.160.44.112:30200
- Логин:```admin``` Пароль:```prom-operator```
![grafana](https://github.com/user-attachments/assets/8721ae98-821d-45a0-8b17-92e464ac2d82)

2. Деплой приложения

- Для деплоя приложения сначала создадим манифест [deployment.yaml](https://github.com/Makarov-Denis/test_myapp/blob/main/deploy/deployment.yaml).  Был выбран ```DaemonSet```, т.к. на текущий момент достаточно получения по 1 поду, но на каждой worker ноде:
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: myapp
  namespace: monitoring
  labels:
    app: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: dimakarov/nginx-static-app:latest
      restartPolicy: Always

---

apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  namespace: monitoring
spec:
  selector:
    app: myapp
  type: NodePort
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080  
   
```
- Развернем приложение:
![image](https://github.com/user-attachments/assets/3c968b40-457a-403a-a3ef-80108c1c4e7a)
- Проверим доступ до приложения http://89.169.132.91:30080
![image](https://github.com/user-attachments/assets/fac26b7c-f92f-4b69-a66a-4f772e59e7b6)

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.


### Решение

Для автоматической сборки docker image и деплоя приложения при изменении кода будет использоваться ```Github Actions```

- Для работы CI-CD в ```Github Actions``` требуются учетные данные:
- Создадим в Dockerhub секретный токен
- Добавим в ```Github Actions``` секреты для работы с DockerHub и кластером Kubernetes

```bash
KUBE_CONFIG_DATA #дополнительно закодируем base64
admden@admden-VirtualBox:~/terraform-yandex-oblako/makarovdi_diplom cat ~/.kube/config | base64
...
bFdRVlJGSUV0RldTMHRMUzB0Q2c9PQo=

DOCKERHUB_TOKEN

DOCKERHUB_USERNAME
```
- Далее настроим Workflow для автоматической сборки и деплоя приложения:
<details>
<summary>Workflow</summary>

```yml
name: CI/CD Pipeline for nginx-static-app

on:
  push:
    branches:
      - main
    tags:
      - 'v*'

env:
  IMAGE_TAG: dimakarov/nginx-static-app
  RELEASE_NAME: myapp
  NAMESPACE: monitoring

jobs:
  build-and-push:
    name: Build Docker image
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Extract version from tag or commit message
        run: |
          echo "GITHUB_REF: ${GITHUB_REF}"
          if [[ "${GITHUB_REF}" == refs/tags/* ]]; then
            VERSION=${GITHUB_REF#refs/tags/}
          else
            VERSION=$(git log -1 --pretty=format:%B | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' || echo "")
          fi
          if [[ -z "$VERSION" ]]; then
            echo "No version found in the commit message or tag"
            exit 1
          fi
          VERSION=${VERSION//[[:space:]]/}  # Remove any spaces
          echo "Using version: $VERSION"
          echo "VERSION=${VERSION}" >> $GITHUB_ENV

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ env.IMAGE_TAG }}:${{ env.VERSION }}

  deploy:
    needs: build-and-push
    name: Deploy to Kubernetes
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/heads/main') || startsWith(github.ref, 'refs/tags/v')
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: List files in the working directory
        run: |
          ls -la

      - name: Set up Kubernetes
        uses: azure/setup-kubectl@v3
        with:
          version: 'v1.21.0'

      - name: Extract version from tag or commit message
        run: |
          echo "GITHUB_REF: ${GITHUB_REF}"
          if [[ "${GITHUB_REF}" == refs/tags/* ]]; then
            VERSION=${GITHUB_REF#refs/tags/}
          else
            VERSION=$(git log -1 --pretty=format:%B | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' || echo "")
          fi
          if [[ -z "$VERSION" ]]; then
            echo "No version found in the commit message or tag"
            exit 1
          fi
          VERSION=${VERSION//[[:space:]]/}  # Remove any spaces
          echo "Using version: $VERSION"
          echo "VERSION=${VERSION}" >> $GITHUB_ENV

      - name: Replace image tag in deployment.yaml
        run: |
          if [ ! -f ./deploy/deployment.yaml ]; then
            echo "deployment.yaml not found in the current directory"
            exit 1
          fi
          sed -i "s|image: dimakarov/nginx-static-app:.*|image: ${{ env.IMAGE_TAG }}:${{ env.VERSION }}|" ./deploy/deployment.yaml

      - name: Create kubeconfig
        run: |
          mkdir -p $HOME/.kube/

      - name: Authenticate to Kubernetes cluster
        env:
          KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
        run: |
          echo "${KUBE_CONFIG_DATA}" | base64 --decode > ${HOME}/.kube/config
          kubectl config view
          kubectl get nodes

      - name: Apply Kubernetes manifests
        run: |
          kubectl apply -f ./deploy/deployment.yaml
          kubectl get daemonsets -n monitoring
          kubectl get pods -n monitoring
          kubectl describe daemonset myapp -n monitoring
          kubectl describe service myapp-service -n monitoring
```

</details>

https://github.com/Makarov-Denis/test_myapp/actions

![githubactions](https://github.com/user-attachments/assets/03a068b4-ec7e-4eac-a579-aec0895c0054)

- Добавим тэг для приложения и отправим коммит с изменениями:
  
![actions1](https://github.com/user-attachments/assets/d40806e7-fbff-40a5-becb-1be032b2e80d)

![actions2](https://github.com/user-attachments/assets/3bd6577a-816a-4682-b49c-2397f261bbcd)

![actions 3](https://github.com/user-attachments/assets/a319ae06-6f1f-4251-979b-a753b8a1acb4)

![actions 4](https://github.com/user-attachments/assets/19e89f12-8226-4cbe-a7bc-6507dcc624e0)

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)













