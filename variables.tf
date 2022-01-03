# -------------------------------------------------------------------------------------------------
# Required variables
# -------------------------------------------------------------------------------------------------

variable "name" {
  type        = string
  description = "API Gateway name"
}

variable "stage" {
  type        = string
  description = "API Gateway stage name"
}

# -------------------------------------------------------------------------------------------------
# Optional variables
# -------------------------------------------------------------------------------------------------

# API Gateway configuration
variable "protocol_type" {
  type        = string
  description = "(Optional) Protocol type"
  default     = "HTTP"
}

variable "cors_allow_origins" {
  type        = list(string)
  description = "(Optional) CORS Allowed origins"
  default     = []
}

variable "cors_allow_methods" {
  type        = list(string)
  description = "(Optional) CORS Allowed methods"
  default     = []
}

# Domain name configuration
variable "custom_domain_names" {
  type = list(object({
    domain_name     = string
    certificate_arn = string
    endpoint_type   = string
    security_policy = string
    zone_id         = string
  }))
  description = "(Optional) Custom domain names and configuration"
  default     = []
}

# API Stage configutaion
variable "stage_auto_deploy" {
  type        = string
  description = "(Optional) Whether updates to an API automatically trigger a new deployment."
  default     = true
}
