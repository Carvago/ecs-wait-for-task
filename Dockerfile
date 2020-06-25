FROM alpine:3.8

# Install packges needed
RUN apk --no-cache add ca-certificates curl bash jq py2-pip && \
    pip install awscli

COPY ecs-wait-for-task.sh /usr/local/bin/ecs-wait-for-task
RUN chmod +x /usr/local/bin/ecs-wait-for-task

ENTRYPOINT ["ecs-wait-for-task"]
