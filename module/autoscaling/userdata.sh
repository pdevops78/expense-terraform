sudo pip3.11 install ansible hvac
ansible-pull -i localhost, -U https://github.com/pdevops78/expense-ansible getsecrets.yml -e env=${env} -e component_name=${component} -e project_name=expense &>>/tmp/ansible.log
ansible-pull -i localhost, -U https://github.com/pdevops78/expense-ansible expense.yml -e env=${env} -e component_name=${component} -e @~/secrets.json &>>/tmp/ansible.log