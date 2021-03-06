{
  "name": "${container_name}",
  "image": "${aws_account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/backend:latest",
  "essential": true,
  "secrets": [
    {
      "name": "API_SERVER_DATABASE_HOST",
      "valueFrom": "/todo/db/host"
    },
    {
      "name": "API_SERVER_DATABASE_USER",
      "valueFrom": "/todo/db/username"
    },
    {
      "name": "API_SERVER_DATABASE_PASSWORD",
      "valueFrom": "/todo/db/password"
    },
    {
      "name": "SECRET_KEY_BASE",
      "valueFrom": "/todo/rails/secret_key"
    },
    {
      "name": "RAILS_ENV",
      "valueFrom": "/todo/rails_env"
    }
  ],
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-region": "ap-northeast-1",
      "awslogs-stream-prefix": "${stream_prefix}",
      "awslogs-group": "${aws_log_group}"
    }
  },
  "portMappings": [
    {
      "protocol": "tcp",
      "containerPort": 3000
    }
  ]
}
