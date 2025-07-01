"sudo pip3.11 install ansible hvac",
      "ansible-pull -i localhost, -U https://github.com/pdevops78/expense-ansible getsecrets.yml -e env=${var.env} -e component_name=${var.component} -e project_name=expense",
      "ansible-pull -i localhost, -U https://github.com/pdevops78/expense-ansible expense.yml -e env=${var.env} -e component_name=${var.component} -e @~/secrets.json"