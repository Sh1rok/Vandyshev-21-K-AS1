markdown
# Проект по дисциплине «Технология проектирования автоматизированных систем в защищённом исполнении»

**Тема:** Контейнеризация и оркестрация микросервиса с развёртыванием в облаке Yandex Cloud и Minikube

**Выполнил:** Вандышев Р.Ю.  
**Группа:** 21-К-АС1

---

## 🎯 Цель работы

Разработать веб-сервис на **FastAPI**, упаковать его в **Docker**, загрузить образ в **Docker Hub**, развернуть инфраструктуру как код (**Terraform**) в **Yandex Cloud** на виртуальной машине, а также запустить сервис в локальном **Kubernetes (Minikube)** с использованием манифестов.

---

## 🧰 Используемые технологии

| Технология | Назначение |
|------------|------------|
| Python 3.12 + FastAPI + Uvicorn | Разработка микросервиса |
| Docker | Контейнеризация, хранение образа в Docker Hub |
| Terraform | Развёртывание ВМ в Yandex Cloud |
| Kubernetes (Minikube) + kubectl | Оркестрация контейнеров |
| Git / GitHub | Хранение кода и отчёта |

---

## 📁 Структура репозитория

<img width="452" height="537" alt="image" src="https://github.com/user-attachments/assets/37acbd1b-b6de-4d11-9ca0-97ef0d33ce21" />

> **Важно:** файл `terraform.tfvars` содержит реальные ключи доступа и **не выложен** в публичный репозиторий (добавлен в `.gitignore`).

---

## 🚀 Инструкция по развёртыванию и проверке

### 1. Локальный запуск без Docker (для разработки)

``bash
pip install -r requirements.txt
uvicorn app:app --reload
Сервис будет доступен по адресу: http://localhost:8000

2. Сборка Docker-образа и локальный запуск контейнера
bash
docker build -t seelebz/vandyshev-fastapi-app:latest .
docker run -d -p 8000:8000 --name fastapi-test seelebz/vandyshev-fastapi-app:latest
Проверка:

bash
curl http://localhost:8000
Скриншоты (см. также общий список в конце):

Сборка образа: screenshots/docker-build.png

Запущенные контейнеры: screenshots/04-docker-ps.png

Ответ curl: screenshots/05-curl-localhost.png

3. Публикация образа в Docker Hub
bash
docker push seelebz/vandyshev-fastapi-app:latest
Образ публично доступен: seelebz/vandyshev-fastapi-app
Скриншот страницы репозитория: screenshots/docker-hub-repo.png

4. Развёртывание в Yandex Cloud с помощью Terraform
Требования: аккаунт Yandex Cloud, сервисный аккаунт с ролью editor, авторизованный ключ в JSON, публичный SSH-ключ.

Перейти в папку terraform:

bash
cd terraform
Заполнить terraform.tfvars (пример):

hcl
cloud_id                 = "b1g..."
folder_id                = "b1g..."
service_account_key_file = "key.json"
ssh_public_key           = "ssh-ed25519 AAA... user@host"
docker_image_name        = "seelebz/vandyshev-fastapi-app:latest"
zone                     = "ru-central1-a"
Выполнить планирование и применение:

bash
terraform init
terraform plan
terraform apply -auto-approve
После завершения Terraform выведет публичный IP виртуальной машины:

text
Outputs:
vm_external_ip = "84.201.xxx.xxx"
Проверить работу сервиса в браузере: http://<IP>

Скриншот terraform plan: screenshots/terraform-plan.png

Примечание: В целях экономии гранта виртуальная машина может быть остановлена или уничтожена. Работоспособность подтверждена скриншотом curl с ВМ (прилагается в папке screenshots).

5. Развёртывание в Minikube (локальный Kubernetes)
Предварительные требования: установлены Minikube, kubectl, Docker.

bash
minikube start --driver=docker
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
Проверка подов:

bash
kubectl get pods -n vandyshev-space
Ожидаемый вывод – 2 пода в статусе Running:

text
NAME                                  READY   STATUS    RESTARTS   AGE
fastapi-deployment-54bdbc77b8-6kpfv   1/1     Running   0          45s
fastapi-deployment-54bdbc77b8-vf2jl   1/1     Running   0          45s
Доступ к сервису через port-forward:

bash
kubectl port-forward -n vandyshev-space service/fastapi-service 8888:80
В другом терминале:

bash
curl http://localhost:8888
Скриншоты (см. также общий список в конце):

Поды: screenshots/kubectl-pods.png

Ответ через port-forward: screenshots/minikube-curl.png

6. Обеспечение защищённого исполнения
Микросервис изолирован в Docker-контейнере, используется минимальный базовый образ python:3.12-slim.

В облачной инфраструктуре настроены группы безопасности (открыты только порты 80 и 22).

Для аутентификации в облаке используется сервисный аккаунт с минимальными привилегиями.

В production-сценарии предполагается добавление HTTPS (reverse proxy) и базовой HTTP-аутентификации.

📌 Выводы по проекту
Разработан микросервис на FastAPI, возвращающий JSON-приветствие с именем студента.

Создан Docker-образ, опубликованный в Docker Hub.

Инфраструктура в Yandex Cloud описана декларативно с помощью Terraform; виртуальная машина автоматически поднимает сервис при запуске.

Сервис развёрнут в локальном Kubernetes (Minikube) с использованием манифестов (namespace, deployment, service).

Все этапы автоматизированы, код и отчёт находятся в GitHub.

📸 Список скриншотов
Ниже приведены все скриншоты, сделанные в ходе выполнения проекта. Кликните по любому изображению, чтобы открыть его в полном размере.

Сборка Docker-образа
[https://screenshots/docker-build.png](https://github.com/Sh1rok/Vandyshev-21-K-AS1/blob/main/screenshots/docker-build.png)

Запущенные контейнеры (docker ps)
https://screenshots/04-docker-ps.png

Проверка через curl localhost
https://screenshots/05-curl-localhost.png

Репозиторий на Docker Hub
https://screenshots/docker-hub-repo.png

Планирование Terraform (terraform plan)
https://screenshots/terraform-plan.png

Поды Kubernetes в Minikube
https://screenshots/kubectl-pods.png

Доступ к сервису через port-forward (ответ curl)
https://screenshots/minikube-curl.png

🔗 Ссылки
GitHub репозиторий: Vandyshev-21-K-AS1

Docker Hub образ: seelebz/vandyshev-fastapi-app
