# AWS Web Server Infrastructure with Terraform

This project uses [Terraform](https://www.terraform.io/) to provision a public Ubuntu EC2 web server (with Apache) in AWS. The infrastructure includes a custom VPC, public subnet, internet gateway, route table, security group, Elastic IP, and a network interface.

---

## Features

- **Custom VPC:** Private network space (`10.0.0.0/16`)
- **Public Subnet:** (`10.0.1.0/24` in one Availability Zone)
- **Internet Gateway:** Allows internet access for instances
- **Route Table:** Routes public subnet traffic to the internet
- **Security Group:** Allows inbound HTTP (80), HTTPS (443), SSH (22); all outbound traffic allowed
- **Elastic IP:** Assigns a static public IP
- **EC2 Instance:** Ubuntu server with Apache auto-installed and a sample "Hello, World!" page

---

## Prerequisites

- [Terraform v1.0.0+](https://www.terraform.io/downloads)
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
- An existing EC2 Key Pair in your chosen AWS region (for SSH)
- AWS account with necessary permissions

---

## Usage

1. **Clone this repository:**

    ```bash
    git clone https://github.com/sahana-n-h/Terraform-AWS.git
    ```

2. **(Optional) Edit Variables:**
    - Update the `ami`, `key_name`, or subnet CIDR in `main.tf` if needed.

3. **Initialize Terraform:**

    ```bash
    terraform init
    ```

4. **Preview the plan:**

    ```bash
    terraform plan
    ```

5. **Apply the configuration:**

    ```bash
    terraform apply
    ```

    - Type `yes` to confirm.

6. **After Deployment:**
    - Find the **Elastic IP address** output by Terraform.
    - Open a browser: `http://<YOUR-ELASTIC-IP>` to see the "Hello, World!" page.
    - To SSH (replace `<keypair.pem>` and `<YOUR-ELASTIC-IP>`):

      ```bash
      ssh -i <keypair.pem> ubuntu@<YOUR-ELASTIC-IP>
      ```

---

## Clean Up

To **destroy all resources** and avoid AWS charges:

```bash
terraform destroy
