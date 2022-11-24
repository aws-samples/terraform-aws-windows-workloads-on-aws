# Create S3 bucket for web server files and upload local files

##CORRUPT##
  bucket_prefix = format("%s%s%s%s", var.customer_code, "sss", var.environment_code, "websrv")
  force_destroy = true

  tags = {
    name         = format("%s%s%s%s", var.customer_code, "sss", var.environment_code, "websrv"),
    resourcetype = "storage"
    codeblock    = "codeblock03"
  }
}

resource "aws_s3_bucket_public_access_block" "websrv" {
  bucket                  = aws_s3_bucket.websrv.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "websrv" {
  for_each = fileset("./existing_webserverfiles/", "**")
  bucket   = aws_s3_bucket.websrv.id
  key      = "webserverfiles/${each.value}"
  source   = "./existing_webserverfiles/${each.value}"
  etag     = filemd5("./existing_webserverfiles/${each.value}")
}

# Load Balancer S3 bucket policy https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html
data "aws_iam_policy_document" "websrv" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::652711504416:root",
                     "arn:aws:iam::156460612806:root",
                     "arn:aws:iam::127311923021:root",
                     "arn:aws:iam::033677994240:root",
                     "arn:aws:iam::027434742980:root",
                     "arn:aws:iam::797873946194:root"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.websrv.arn,
      "${aws_s3_bucket.websrv.arn}/albaccesslogs/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "websrv" {
  bucket = aws_s3_bucket.websrv.id
  policy = data.aws_iam_policy_document.websrv.json
}
