# Distinguish name resolution from service reachability

Status: Draft learning procedure — Requires Windows Lab Validation.

When an IP works but a name fails, compare DNS responses before changing firewall
rules. Record `ipconfig /all`, `Resolve-DnsName` and the intended internal resolver's
`nslookup` result. An FQDN test separates suffix problems from record problems.

A correct DNS answer does not prove a service is listening. Test the approved port
with `Test-NetConnection`, then the actual application. An ICMP timeout may reflect
filtering rather than a failed host. A TCP success cannot establish valid TLS,
authentication or authorization. See the [runbook](../../runbooks/ip-works-name-fails.md).
