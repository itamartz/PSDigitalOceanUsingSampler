class Team
{
    [string]$uuid
    [string]$name

    Team([string]$uuid, [string]$name)
    {
        $this.uuid = $uuid
        $this.name = $name
    }
}

class Account
{
    [int]$droplet_limit
    [int]$floating_ip_limit
    [string]$email
    [string]$name
    [string]$uuid
    [bool]$email_verified
    [string]$status
    [string]$status_message
    [Team]$team

    Account(
        [int]$droplet_limit,
        [int]$floating_ip_limit,
        [string]$email,
        [string]$name,
        [string]$uuid,
        [bool]$email_verified,
        [string]$status,
        [string]$status_message,
        [Team]$team
    )
    {
        $this.droplet_limit = $droplet_limit
        $this.floating_ip_limit = $floating_ip_limit
        $this.email = $email
        $this.name = $name
        $this.uuid = $uuid
        $this.email_verified = $email_verified
        $this.status = $status
        $this.status_message = $status_message
        $this.team = $team
    }
}

class Root
{
    [Account]$account

    Root([Account]$account)
    {
        $this.account = $account
    }
}
