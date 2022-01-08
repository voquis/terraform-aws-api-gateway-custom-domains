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

variable "cors_allow_headers" {
  type        = list(string)
  description = "(Optional) CORS Allowed headers"
  default     = []
}

variable "cors_expose_headers" {
  type        = list(string)
  description = "(Optional) CORS Exposed headers"
  default     = []
}

variable "cors_allow_cedentials" {
  type        = bool
  description = "(Optional) CORS Allow credentials"
  default     = false
}

variable "cors_max_age" {
  type        = number
  description = "(Optional) Seconds browser should cache preflight results"
  default     = 0
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
