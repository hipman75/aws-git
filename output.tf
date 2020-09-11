output "my-ip" {
#    value = apache_server.my-ec2.ipv4_address
#    value = aws_instance.my-ec2.ipv4_address
     value = aws_eip.my-ip.public_ip
}

output "my-dns-name" {
    value = aws_eip.my-dns-name.public_dns
}

#output "my-hostname" {
#    value = apache_server.my-ec2.ipv4_address_private
#    value = aws_instance.my-ec2.ipv4_address_private
#    value = aws_instance.my-ec2.name
#    value = aws_instance.my-ec2.public_ip
#}
