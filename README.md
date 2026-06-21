Проект по дисциплине «Технология проектирования автоматизированных систем в защищённом исполнении»

Тема: Контейнеризация и оркестрация микросервиса с развёртыванием в облаке Yandex Cloud и Minikube

Выполнил: Вандышев Р.Ю.
Группа: 21-К-АС1 
Цель работы:
Разработать веб-сервис на **FastAPI**, упаковать его в **Docker**, загрузить образ в **Docker Hub**, развернуть инфраструктуру как код (**Terraform**) в **Yandex Cloud** на виртуальной машине, а также запустить сервис в локальном **Kubernetes (Minikube)** с использованием манифестов.

Используемые технологии
- **Python 3.12 + FastAPI + Uvicorn**
- **Docker** (контейнеризация, образ в Docker Hub)
- **Terraform** (развёртывание ВМ в Yandex Cloud)
- **Kubernetes (Minikube)** + **kubectl**
- **Git / GitHub** (хранение кода и отчёта)

Структура репозитория

Vandyshev-21-K-AS1/
├── app.py # код микросервиса
├── requirements.txt # зависимости Python
├── Dockerfile # инструкция сборки образа
├── terraform/ # конфигурация Yandex Cloud
│ ├── main.tf
│ ├── variables.tf
│ ├── terraform.tfvars (не публикуется – в .gitignore)
│ └── cloud-init.yaml
├── k8s/ # манифесты Kubernetes
│ ├── namespace.yaml
│ ├── deployment.yaml
│ └── service.yaml
├── screenshots/ # скриншоты выполнения
└── README.md # этот файл
> *Примечание:* файл `terraform.tfvars` содержит реальные ключи доступа и не был выложен в публичный репозиторий.
Инструкция по развёртыванию и проверке
1.  Локальный запуск без Docker (для разработки)
```bash
pip install -r requirements.txt
uvicorn app:app –reload
Сервис будет доступен по адресу: http://localhost:8000
Чтобы все заработало корректно надо было ввести команду:
docker run -d -p 8000:8000 --name fastapi-test seelebz/vandyshev-fastapi-app:latest
После чего при вводе docker ps показал контейнер. Сервис стал доступен

2.  Сборка Docker-образа и локальный запуск контейнера
docker build -t seelebz/vandyshev-fastapi-app:latest .
docker run -d -p 8000:8000 --name fastapi-test seelebz/vandyshev-fastapi-app:latest
Проверка:
curl http://localhost:8000
Скриншот:  docker-build.png
Скриншот:  04-docker-ps.png
Скриншот:  05-curl-localhost.png

3.  Публикация образа в Docker Hub

docker push seelebz/vandyshev-fastapi-app:latest
Скриншот страницы репозитория:  docker-hub-repo.png
Образ публично доступен: seelebz/vandyshev-fastapi-app
4.  Развертывание в Yandex Cloud с помощью Terraform
Требования: аккаунт Yandex Cloud, сервисный аккаунт с ролью editor, авторизованный ключ в JSON, публичный SSH-ключ.
1)  Перейти в папку terraform: cd terraform
2)  Заполнить terraform.tfvars (пример):

cloud_id                 = "b1g..."
folder_id                = "b1g..."
service_account_key_file = "key.json"
ssh_public_key           = "ssh-ed25519 AAA... user@host"
docker_image_name        = "seelebz/vandyshev-fastapi-app:latest"
zone                     = "ru-central1-a"
3)  Выполнить планирование и применение:

terraform init
terraform plan
terraform apply -auto-approve
4)  После завершения Terraform выведет публичный IP виртуальной машины:

Outputs:
vm_external_ip = "84.201.xxx.xxx"
5)  Проверить работу сервиса в браузере: http://<ip>
Скриншот terraform plan:  terraform-plan.png
Примечание: В целях экономии гранта виртуальная машина может быть остановлена или уничтожена. Работоспособность подтверждена скриншотом curl с ВМ (прилагается в папке screenshots).
5.  Развертывание в Minikube (локальный Kubernetes)
Предварительные требования: установлены Minikube, kubectl, Docker.
minikube start --driver=docker
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
Проверка подов: 
kubectl get pods -n vandyshev-space
Ожидаемый вывод – 2 пода в статусе Running
NAME                                  READY   STATUS    RESTARTS   AGE
fastapi-deployment-54bdbc77b8-6kpfv   1/1     Running   0          45s
fastapi-deployment-54bdbc77b8-vf2jl   1/1     Running   0          45s
Доступ к сервису через port-forward
kubectl port-forward -n vandyshev-space service/fastapi-service 8888:80
В другом терминале:
curl http://localhost:8888
Скриншот подов:  kubectl-pods.png
Скриншот ответа через port-forward:  minikube-curl.png
6.  Обеспечение защищенного исполнения
Микросервис изолирован в Docker-контейнере, используется минимальный базовый образ python:3.12-slim.
В облачной инфраструктуре настроены группы безопасности (только открытые порты 80 и 22).
Для аутентификации в облаке используется сервисный аккаунт с минимальными привилегиями.
В production-сценарии предполагается добавление HTTPS (reverse proxy) и базовой HTTP-аутентификации.
Выводы по сделанному проекту:
1)  Разработан микросервис на FastAPI, возвращающий JSON-приветствие с именем студента.
2)  Создан Docker-образ, опубликованный в Docker Hub.
3)  Инфраструктура в Yandex Cloud описана декларативно с помощью Terraform; виртуальная машина автоматически поднимает сервис при запуске.
4)  Сервис развёрнут в локальном Kubernetes (Minikube) с использованием манифестов (namespace, deployment, service).
5)  Все этапы автоматизированы, код и отчёт находятся в GitHub.
Ссылки:
GitHub репозиторий: Vandyshev-21-K-AS1
Docker Hub образ: seelebz/vandyshev-fastapi-app

