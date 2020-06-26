# ecs-wait-for-task
Simple script for monitoring and waiting for success of Amazon Elastic Container Service Task run

#### What it does
- It waits for task to finish
- Printing task logs
- Exiting with same exit code as container in task run

## Requirements
- jq
- aws
- ecs-cli

## Usage

```bash
ecs-wait-for-task --cluster "my-cluster" --task "arn:aws:ecs:eu-central-1:310753720731:task/8fbc18ee-6f44-42f8-ba33-b319e4fc1949"
```

---

### Thank you!

Heavily inspired by https://github.com/silinternational/ecs-deploy

### Sponsored by 
<a href="https://carvago.com" target="_blank">
    <img alt="Carvago.com" src="https://carvago.com/static/images/logo.svg" height="60">
</a>
