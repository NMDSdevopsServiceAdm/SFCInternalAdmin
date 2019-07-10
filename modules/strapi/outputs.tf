output "strapi_ec2_id" {
  value = aws_instance.strapi[0].id
}