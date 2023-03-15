variable "spoke_locations" {
  type = list(string)
  default = [ 
    "Australia East",
    "Australia Southeast"
   ]
}

variable "hub_location" {
  type = string
  default = "Australia Central"
}
