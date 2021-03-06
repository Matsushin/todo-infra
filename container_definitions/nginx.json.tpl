{
  "name": "nginx",
  "image": "${aws_account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/nginx:latest",
  "essential": true,
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-region": "ap-northeast-1",
      "awslogs-stream-prefix": "nginx",
      "awslogs-group": "/ecs/nginx-logs"
    }
  },
  "portMappings": [
    {
      "protocol": "tcp",
      "containerPort": 80
    }
  ]
}
