FROM alpine:3.8

# Install packges needed
RUN apk --no-cache add ca-certificates curl bash jq py2-pip && \
    pip install awscli && \
    curl -o /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest

RUN chmod +x /usr/local/bin/ecs-cli

COPY ecs-wait-for-task.sh /usr/local/bin/ecs-wait-for-task
RUN chmod +x /usr/local/bin/ecs-wait-for-task

ENTRYPOINT ["sh", "/usr/local/bin/ecs-wait-for-task"]
