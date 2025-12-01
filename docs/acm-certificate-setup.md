# ACM Certificate Setup Guide for FreeDNS

## Step-by-Step: Create and Validate ACM Certificate

### Step 1: Create ACM Certificate in AWS Console

1. **Go to AWS Certificate Manager**
   - Navigate to: AWS Console → Certificate Manager
   - Make sure you're in **ap-south-1** region (Mumbai)

2. **Request Certificate**
   - Click "Request a certificate"
   - Choose "Request a public certificate"
   - Click "Next"

3. **Add Domain Names**
   - Add both domains:
     - `wordpress.<your-domain>` (e.g., `wordpress.aws-cloudzenia.mooo.com`)
     - `microservice.<your-domain>` (e.g., `microservice.aws-cloudzenia.mooo.com`)
   - Click "Next"

4. **Choose Validation Method**
   - Select **DNS validation** (recommended)
   - Click "Request"

### Step 2: Get DNS Validation Records

1. **Copy Validation Records**
   - AWS will show CNAME records needed for validation
   - Example format:
     ```
     Name: _abc123.wordpress.aws-cloudzenia.mooo.com
     Value: _xyz789.acm-validations.aws.
     ```

2. **Note Down All Records**
   - You'll get 2 CNAME records (one for each domain)
   - Copy both Name and Value fields

### Step 3: Add DNS Records to FreeDNS

1. **Login to FreeDNS**
   - Go to [freedns.afraid.org](https://freedns.afraid.org)
   - Login to your account

2. **Add CNAME Records**
   - Go to "Subdomains" section
   - Click "Add" or "Add Subdomain"
   - For each validation record:
     - **Type**: Select "CNAME"
     - **Subdomain**: Enter just the subdomain part (e.g., `_abc123.wordpress`)
     - **Target**: Enter the full value from AWS (e.g., `_xyz789.acm-validations.aws.`)
     - **TTL**: Leave as default or set to 300
     - Click "Create"

3. **Repeat for Second Domain**
   - Add the second CNAME record for microservice domain

### Step 4: Wait for Validation

1. **Wait 5-10 Minutes**
   - AWS needs time to validate the DNS records
   - Go back to Certificate Manager in AWS Console

2. **Check Certificate Status**
   - Status should change from "Pending validation" to "Issued"
   - This can take 5-30 minutes

### Step 5: Get Certificate ARN

1. **Copy Certificate ARN**
   - Once status is "Issued", click on the certificate
   - Copy the ARN (starts with `arn:aws:acm:ap-south-1:...`)

2. **Add to Terraform**
   - Open `terraform/terraform.tfvars`
   - Add the certificate ARN:
     ```hcl
     ecs_certificate_arn = "arn:aws:acm:ap-south-1:123456789012:certificate/abc123..."
     ```

### Step 6: Update Terraform

1. **Run Terraform Apply**
   ```bash
   cd terraform
   terraform apply
   ```
   - This will create the HTTPS listener and routing rules

## Quick Reference

### FreeDNS CNAME Record Format

**For ACM Validation:**
- **Type**: CNAME
- **Subdomain**: `_abc123.wordpress` (from AWS)
- **Target**: `_xyz789.acm-validations.aws.` (from AWS, include the trailing dot)

### Example

If AWS shows:
- Name: `_a1b2c3d4.wordpress.aws-cloudzenia.mooo.com`
- Value: `_x9y8z7w6.acm-validations.aws.`

In FreeDNS, create:
- **Type**: CNAME
- **Subdomain**: `_a1b2c3d4.wordpress`
- **Target**: `_x9y8z7w6.acm-validations.aws.`

## Troubleshooting

### Certificate Not Validating?
- Wait 10-15 minutes (DNS propagation takes time)
- Double-check CNAME record names (include underscore prefix)
- Ensure target value ends with a dot (`.`)
- Verify records in FreeDNS are correct

### Can't Create HTTPS Listener?
- Make sure certificate status is "Issued" (not "Pending")
- Verify certificate is in the same region as ALB (ap-south-1)
- Check certificate ARN is correct in terraform.tfvars

## Next Steps

After certificate is validated and added to terraform.tfvars:
1. Run `terraform apply` to create HTTPS listener
2. Test endpoints: `https://wordpress.<your-domain>` and `https://microservice.<your-domain>`
3. Verify HTTP redirects to HTTPS

