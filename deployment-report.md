# Отчет по развертыванию приложения в Kubernetes

## Введение

Этот отчет описывает процесс сборки Docker-образа веб-приложения калькулятора на Python с использованием Flask, применения Kubernetes-манифестов и проверки работоспособности с использованием kubectl и Docker Desktop.

## Предварительные требования

- Установленный Docker Desktop с включенным Kubernetes
- Установленный kubectl
- Клонированный репозиторий с проектом

## Шаг 1: Сборка Docker-образа

1. Перейдите в корневую директорию проекта:

2. Соберите Docker-образ с тегом `my-calculator:v1`:
    ```
    docker build -t my-calculator:v1 .
    ```

    Этот шаг использует Dockerfile, который:
    - Базируется на образе `python:3.11-slim`
    - Копирует все файлы проекта в контейнер
    - Устанавливает зависимости из `requirements.txt` (включая Flask)
    - Запускает веб-приложение командой `python src/main.py`

## Шаг 2: Применение Kubernetes-манифестов

1. Убедитесь, что Kubernetes включен в Docker Desktop (Settings > Kubernetes > Enable Kubernetes)

2. Примените все манифесты из директории `k8s-manifests/`:
    ```
    kubectl apply -f k8s-manifests/
    ```
    или сначала примените манифесты `namespace.yaml` и `configmap.yaml`, а затем `deployment.yaml` и `service.yaml`.

    Это создаст следующие ресурсы:
    - Namespace `lab5`
    - ConfigMap `calc-config` с переменными окружения (APP_PORT=5000, APP_DEBUG=true, GREETING_MSG)
    - Secret `calc-secrets` с API-ключом
    - Deployment `main-deployment` с 2 репликами подов
    - Service `main-service` типа ClusterIP, экспонирующий порт 5000

## Шаг 3: Проверка работоспособности

1. Проверьте статус подов:
    ```
    kubectl get pods -n lab5
    ```
    Ожидаемый результат: 2 пода в состоянии Running

2. Проверьте статус развертывания:
    ```
    kubectl get deployment -n lab5
    ```

3. Проверьте сервис:
    ```
    kubectl get service -n lab5
    ```

4. Просмотрите логи одного из подов:
    ```
    kubectl logs -n lab5 <pod-name>
    ```

5. Для доступа к приложению используйте port-forwarding:
    ```
    kubectl port-forward -n lab5 svc/main-service 8080:5000
    ```
    Затем откройте http://localhost:8080 в браузере для тестирования калькулятора.

## Заключение

После выполнения этих шагов веб-приложение калькулятора должно быть успешно развернуто в Kubernetes кластере Docker Desktop. Deployment создает 2 реплики, сервис обеспечивает доступ к приложению внутри кластера, а ConfigMap и Secret предоставляют необходимые конфигурационные данные. Приложение использует Flask для веб-интерфейса и считывает конфигурацию из переменных окружения.