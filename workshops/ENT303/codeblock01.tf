# Create a Resource Group for Terraform created instances

resource "aws_resourcegroups_group" "pdo" {
  name        = format("%s%s%s%s", var.CustomerCode, "rgg", var.EnvironmentCode, "pdo")
  description = "Planetry Defence Organization environment resources"

  resource_query {
    query = <<JSON
{
  ##CORRUPT##: [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "Customer",
      "Values": ["${var.CustomerTag}"]
    }
  ]
}
JSON
  }

  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "rgg", var.EnvironmentCode, "pdo")
    resourcetype = "scaffold"
    codeblock    = "codeblock01"
  }
}
