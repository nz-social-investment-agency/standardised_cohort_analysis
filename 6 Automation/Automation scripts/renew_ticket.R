# Renew the Kerberos ticket

renew_kerberos_ticket <- function () {
  # Use system or system2 to call the kinit command
  system('kinit -R')
}

#Call the function to renew the ticket
renew_kerberos_ticket()

