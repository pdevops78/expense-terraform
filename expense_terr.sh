env=$1
action=$2
# here z is an empty in shell
if [ -z "$env" ]; then
  echo "env is missing"
  exit 1
fi
if [ -z "$action" ]; then
 echo "action is missing"
 exit 1
fi
rm -rf .terraform/terraform.tfstate
terraform init -backend-config=env-$env/state.tfvars
terraform $action -var-file=env-$env/main.tfvars
