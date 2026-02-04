#ifndef CERTIFICATES_H
#define CERTIFICATES_H

// Self-signed server certificate for mqtt.icodz.com.br
static const char *mqtt_self_signed_pem =
    "-----BEGIN CERTIFICATE-----\n"
    "MIIDnTCCAoWgAwIBAgIUS3s3+Tb0TbRqZz4crO8V4ctI9YcwDQYJKoZIhvcNAQEL\n"
    "BQAwXjELMAkGA1UEBhMCVVMxDzANBgNVBAgMBkRlbmlhbDEUMBIGA1UEBwwLU3By\n"
    "aW5nZmllbGQxDDAKBgNVBAoMA0RpczEaMBgGA1UEAwwRbXF0dC5pY29kei5jb20u\n"
    "YnIwHhcNMjYwMTEyMTQzMzA4WhcNMzYwMTEwMTQzMzA4WjBeMQswCQYDVQQGEwJV\n"
    "UzEPMA0GA1UECAwGRGVuaWFsMRQwEgYDVQQHDAtTcHJpbmdmaWVsZDEMMAoGA1UE\n"
    "CgwDRGlzMRowGAYDVQQDDBFtcXR0Lmljb2R6LmNvbS5icjCCASIwDQYJKoZIhvcN\n"
    "AQEBBQADggEPADCCAQoCggEBALgS6vBaP2gLZNq9eZzNMnZeZI58asKsFOg/yIHX\n"
    "V7un/dp5h7ps1OTVbN2W8M8fevQVXcJRQfoL1Vb7rz4DCPXfR5Gww1nfcoj1K2fA\n"
    "AHM5YDodfIr5P6ELCJ5XO3PVGq/EAP/S6iJ6FZnGI50lE990YDMzXNQzqCDG5ZH/\n"
    "Mh+j3+k9FQwJjpM1082bqwy0xV6bisl+/jaSax0tgVapKiJ1so/gEdw37tAmcWUo\n"
    "Ud60Bp1C8/+CbEoSnS41E0wnZ73x4sLD0GmYzHS314TmhxTrJISi5BLUDahB5f84\n"
    "sy0h2WJJfUzctKOTh0IQdj1bQHZilK123etFIUMmpfl78GUCAwEAAaNTMFEwHQYD\n"
    "VR0OBBYEFPU+nZGiRRfWGzO/cNmNX7o7t6u7MB8GA1UdIwQYMBaAFPU+nZGiRRfW\n"
    "GzO/cNmNX7o7t6u7MA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEB\n"
    "AJcqWEUMTwJN+ddsrHPEbhYpzSPjUtUT+IlMdZxibG0lSglIDrP52N3ZXMI7frKT\n"
    "qomYcq82NFgo61wV1xHokcmNLNyKlWzzXT/nWB5rpaguHSzjWGzqbDpa6fBYg/85\n"
    "5IRKy6Vu8qeCciVLxOMCeo1YtAOMnWu2Z3EHuDoObNf3FvKRI7RKVEiqpMNlAO/3\n"
    "PgujXaRh9nOJ5749cXTO2TowvUl/mr18mJMLlgCJMVfLcnHBR4n7R0zep1wNKHBf\n"
    "8UKYfHgRej9nRLVSIPZfmUAIwwyBr7ZahWbGMtir5BfwXKDjLpxK9rxdE5kNvtbb\n"
    "YN9yNraIMMJ8qRnpOOsGQQA=\n"
    "-----END CERTIFICATE-----\n";

#if 0
// ISRG Root X1 (Let's Encrypt) & R3 Intermediate – currently unused
// static const char *isrg_root_x1_pem = "...";
#endif

#endif // CERTIFICATES_H
