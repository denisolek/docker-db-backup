docker buildx build --push --tag denisolek/db-backup -o type=image --platform=linux/arm64,linux/amd64 .