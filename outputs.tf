output "master" {
  value = {
    id         = aws_instance.master.id
    private_ip = aws_instance.master.private_ip
    public_ip  = aws_instance.master.public_ip
  }
}

output "workers" {
  value = [
    for i in aws_instance.workers : {
      id         = i.id
      private_ip = i.private_ip
      public_ip  = i.public_ip
    }
  ]
}
