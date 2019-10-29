let
  pkgs = import <nixpkgs> {};
  inherit (pkgs.stdenv) isDarwin isLinux;

in
pkgs.mkShell rec {
  SSL_CERT_FILE = if isLinux
    then "/etc/ssl/certs/ca-bundle.crt"
    else "/etc/ssl/cert.pem";
  NIX_SSL_CERT_FILE = SSL_CERT_FILE;

  buildInputs = with pkgs; [
    bundler ruby

    libxml2 libxslt zlib

    pkgconfig

    postgresql

    graphviz
    global
    python3Packages.yamllint
  ] ++ lib.optionals isDarwin [
    libiconv
  ];
}
