terraform {
  backend "s3" {
    bucket         = "terraform-state-store-2026-05"
    key            = "prod/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
  }
}


# 1. Create the S3 Bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket = "new-devops-project-store-2026-05" 

  tags = {
    Environment = "Production"
    Project     = "Static-Web-Automation"
  }
}

# 2. Configure the bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "site_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# 3. Disable "Block Public Access" settings
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Apply the Bucket Policy
resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  # This policy allows anyone to read objects in this bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public]
}

# 5. Upload your index.html file
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "index.html" 
  content_type = "text/html"
}

# 6. Output the Website URL so you can find it easily
output "website_url" {
  value = aws_s3_bucket_website_configuration.site_config.website_endpoint
}

