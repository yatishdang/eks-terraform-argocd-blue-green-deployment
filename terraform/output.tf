# output "alb_dns" {
#   description = "DNS name of the ALB for Argo CD ingress"
#   value       = data.kubernetes_ingress_v1.argo_ingress.status[0].load_balancer[0].ingress[0].hostname
# }
