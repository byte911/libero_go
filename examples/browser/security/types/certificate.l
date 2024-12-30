-schema=security_certificate_types
    version = 1.0

-types
    Certificate:
        subject: DistinguishedName
        issuer: DistinguishedName
        serial_number: string
        version: int
        not_before: timestamp
        not_after: timestamp
        public_key: PublicKey
        signature: Signature
        extensions: [Extension]
        computed:
            is_valid = now() between not_before and not_after
            is_self_signed = subject == issuer

    DistinguishedName:
        common_name: string
        organization: string
        organizational_unit?: string
        locality?: string
        state?: string
        country: string
        email?: string

    PublicKey:
        algorithm: string
        key_size: int
        modulus?: string  # For RSA
        exponent?: string  # For RSA
        curve?: string    # For ECC
        point?: string    # For ECC

    Signature:
        algorithm: string
        value: string
        parameters?: object

    Extension:
        oid: string
        critical: bool
        value: string

    CertificateChain:
        leaf: Certificate
        intermediates: [Certificate]
        root: Certificate
        computed:
            length = 2 + len(intermediates)
            is_complete = verify_chain_integrity()

    CertificateStore:
        trusted_roots: [Certificate]
        intermediates: [Certificate]
        revoked: [RevokedCert]

    RevokedCert:
        serial_number: string
        issuer: DistinguishedName
        revocation_date: timestamp
        reason?: string
