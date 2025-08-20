resource "aws_iam_role" "mabel" {
  name = "mabel"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "MabelS3ReadOnly"
  description = "Read-only access to select buckets"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:Describe*",
          "s3:Get*",
          "s3:List*",
          "s3:RestoreObject",
          "s3-object-lambda:Get*",
          "s3-object-lambda:List*",
        ],
        Resource = flatten([
          for name in var.iam_read_bucket_names : [
            "arn:aws:s3:::${name}",
            "arn:aws:s3:::${name}/*",
          ]
        ])
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_s3_read" {
  user       = aws_iam_role.mabel.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

# # create this manually
# resource "aws_iam_access_key" "mabel_key" {
#   user = aws_iam_role.mabel.name
# }
