output "EndPoint - It needs a few min to deploy the Ghost Blog" {
    value = module.app.lb_dns_name  
}