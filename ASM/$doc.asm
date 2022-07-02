This dataset contains the following members:

ENCODEXM: This external REXX function implements the base64 encoding
          scheme described in RFC2045.  Please refer to
          http://www.faqs.org/rfcs/rfc2045.html for the full
          description of the scheme.
          ** This module can be placed into LPA if desired.
          *** This module used to be called ENCODE64 but
          *** a few shops had to rename due to already having
          *** a module of that name.

EXITJCL:  This is the JCL to assemble and link SMTPEXIT

SMTPEXIT: This is an SMTP Server Exit to Filter Unwanted E-Mail.
          This code must be modified for use.
          The design of this exit is to prevent inbound e-mail
          from outside the specified domain from being delivered
          to the TSO user.

USERMOD:  SMP/E Usermod for SMTPEXIT
