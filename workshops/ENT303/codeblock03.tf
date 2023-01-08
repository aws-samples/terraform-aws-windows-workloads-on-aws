# Create S3 bucket for web server files and upload local files

##CORRUPT##
  bucket_prefix = format("%s%s%s%s", var.CustomerCode, "sss", var.EnvironmentCode, "websrv")
  force_destroy = true

  tags = {
    name         = format("%s%s%s%s", var.CustomerCode, "sss", var.EnvironmentCode, "websrv"),
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
      identifiers = ["arn:aws:iam::127311923021:root", #US East (N. Virginia) 
                     "arn:aws:iam::033677994240:root", #US East (Ohio)
                     "arn:aws:iam::027434742980:root", #US West (N. California)
                     "arn:aws:iam::797873946194:root", #US West (Oregon)
                     "arn:aws:iam::098369216593:root", #Africa (Cape Town)
                     "arn:aws:iam::754344448648:root", #Asia Pacific (Hong Kong)
                     "arn:aws:iam::589379963580:root", #Asia Pacific (Jakarta)
                     "arn:aws:iam::718504428378:root", #Asia Pacific (Mumbai)
                     "arn:aws:iam::383597477331:root", #Asia Pacific (Osaka)
                     "arn:aws:iam::600734575887:root", #Asia Pacific (Seoul)
                     "arn:aws:iam::114774131450:root", #Asia Pacific (Singapore)
                     "arn:aws:iam::783225319266:root", #Asia Pacific (Sydney)
                     "arn:aws:iam::582318560864:root", #Asia Pacific (Tokyo) 
                     "arn:aws:iam::985666609251:root", #Canada (Central) 
                     "arn:aws:iam::054676820928:root", #Europe (Frankfurt)
                     "arn:aws:iam::156460612806:root", #Europe (Ireland)
                     "arn:aws:iam::652711504416:root", #Europe (London)
                     "arn:aws:iam::635631232127:root", #Europe (Milan)
                     "arn:aws:iam::009996457667:root", #Europe (Paris) 
                     "arn:aws:iam::897822967062:root", #Europe (Stockholm)
                     "arn:aws:iam::076674570225:root", #Middle East (Bahrain)
                     "arn:aws:iam::507241528517:root"] #South America (São Paulo) 
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
