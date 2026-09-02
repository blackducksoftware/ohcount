# Security Policy

Black Duck Software, Inc. treats the security of its software as a product
requirement, not an afterthought. This policy applies to this repository and to
all publicly accessible repositories maintained by Black Duck.

We welcome reports from external security researchers, customers, industry
organizations, and vendors.

## Reporting a vulnerability

**Do not report security vulnerabilities through public GitHub issues, pull
requests, or discussions.** Public reports put users at risk before a fix is
available.

Report suspected vulnerabilities to the Black Duck Product Security Incident
Response Team (PSIRT):

- **Email:** psirt@blackduck.com
- **PGP key:** https://www.blackduck.com/content/dam/black-duck/en-us/legal/disclosure/public_key.asc
- **Key fingerprint:** `5832 3BE7 1E37 4AD5 5696 635D 0CBF 906A 8580 A54C`

Encryption is preferred but not required. Do not delay a report because you are
unable to encrypt it.

This address is for undisclosed vulnerabilities in Black Duck products,
platforms, and repositories only. General support requests should go to
https://community.blackduck.com.

### What to include

The more of this you can provide, the faster we can validate and fix the issue:

- Repository, product or platform name, and affected version, tag, or commit SHA
- Technical description of the issue, including the vulnerability class
- Steps to reproduce, a proof of concept, or sample exploit code
- Impact assessment and any preconditions, such as required privilege level,
  network position, or non-default configuration
- Your proposed disclosure timeline
- The name or handle you would like used if you want public acknowledgment

If you have reason to believe the vulnerability is being **actively exploited**,
state that in the subject line. Active exploitation changes our handling
priority and may trigger regulatory notification obligations on our side, so we
need to know immediately.

## What to expect from us

Our disclosure process is executed by PSIRT and is based on ISO/IEC 29147,
ISO/IEC 30111, and NIST SP 800-61.

We will:

- Acknowledge receipt of your report
- Keep you informed of progress while the report is open
- Handle your report confidentially and limit internal distribution to those who
  need to know to resolve it
- Assign a severity using CVSS, adjusted for environmental factors, and share it
  with you
- Tell you whether the report was accepted or rejected, and why
- Work with you in good faith if you disagree with our assessment
- Tell you in advance if we expect remediation to take longer than 90 days, and
  explain why

We ask that you keep the report confidential until a comprehensive fix has been
released and we have coordinated disclosure with you.

We will not negotiate under threat of premature disclosure or of releasing
exposed data.

## Scope

**In scope:** code in Black Duck maintained public repositories, and Black Duck
products and platforms that are currently supported. Only the default branch and
currently supported product releases are evaluated for fixes. Refer to the
product lifecycle and end of support policy for release support status.

**Out of scope:**

- **Vulnerabilities in third-party or open source dependencies** where no
  exploitable path through Black Duck code is demonstrated. Report those to the
  upstream project. If you believe our specific use of a dependency creates
  exploitability, tell us that and we will treat it as in scope.
- Denial of service and distributed denial of service
- Output from automated tools without analysis of what is vulnerable and how it
  could be exploited
- Missing hardening measures or best-practice recommendations with no
  demonstrated security impact
- Social engineering, physical attacks, and attacks that require prior
  compromise of the reporter's own host or account
- Questions about the accuracy or completeness of vulnerability data that our
  products report about *your* code or dependencies. That is a product data
  question, not a vulnerability in our software. Use
  https://community.blackduck.com.

## CVE identifiers and advisories

Black Duck is a CVE Numbering Authority (CNA). We assign CVE IDs for confirmed
vulnerabilities in Black Duck products and repositories that meet CVE
requirements, and we publish the resulting records to the CVE Program.

Vulnerabilities in third-party components are assigned by the upstream CNA or by
a root CNA, not by Black Duck.

Black Duck Security Advisories (BDSA), produced by the Cybersecurity Research
Center, cover vulnerabilities in open source components. That is a separate
research function and is not the intake path for vulnerabilities in Black Duck's
own software.

## Recognition

Black Duck does not operate a bug bounty and does not pay monetary compensation
for vulnerability reports.

We do acknowledge reporters in release notes and public advisories, provided
that:

- You agree to your name, handle, or contact details being published
- You do not publish before we confirm a comprehensive fix has been released
- You do not publish exact exploit or proof-of-concept details

Black Duck does not publicly acknowledge Black Duck employees or contractors for
vulnerabilities found in Black Duck products.

## Safe harbor

Black Duck considers security research and vulnerability disclosure activities
conducted consistently with this policy to be authorized conduct under the
Computer Fraud and Abuse Act. If a third party initiates legal action against
you and you have complied with this policy, Black Duck will make it known that
your actions were conducted in compliance with this policy.

To stay within this policy you must:

- Act in good faith and avoid violating applicable law, destroying data, or
  degrading our services
- Only interact with accounts you own or test accounts created for research
- Not access, modify, view, store, or transfer end user data. If you encounter
  end user data, stop, contact us within 24 hours, and purge any local copy
- Not make information public without our coordination and consent

## Related policies

- Black Duck Vulnerability Disclosure Policy:
  https://www.blackduck.com/company/legal/vulnerability-disclosure-policy.html
- Black Duck Responsible Disclosure Policy, covering vulnerabilities Black Duck
  discovers in third-party products:
  https://www.blackduck.com/company/legal/responsible-disclosure-policy.html

---

Policy version 1.0. Last reviewed 2026-09-01. Maintained by Black Duck
Cybersecurity Operations. Questions about this policy, as distinct from
vulnerability reports, can be sent to psirt@blackduck.com.
