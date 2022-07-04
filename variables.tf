####

variable "git_personal_access_token" {
  type        = string
  description = "For GitHub or GitHub Enterprise, this is the personal access token."
  sensitive   = true
}

variable "source_type" {
  type        = string
  description = "The type of repository that contains the source code to be built."
}

variable "source_location" {
  type        = string
  description = "Information about the location of the source code to be built."
}

variable "kill_resources_schedule" {
  type        = string
  description = "Schedule expression in the form of cron or rate expressions. Refer to https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for more details."
}

variable "revive_resources_schedule" {
  type        = string
  description = "Schedule expression in the form of cron or rate expressions. Refer to https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for more details."
}

variable "terraform_version" {
  type        = string
  description = "Version of Terraform."
}