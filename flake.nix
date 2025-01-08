{
  description = "ST fork of openocd in as a flake";
  inputs.nixpkgs.url = "nixpkgs/nixos-24.11";
  outputs = { self, nixpkgs, ... }:
    let
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
      version = "0.12.0.openocd-cubeide-r6";
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
    in
    {
      overlay = final: prev: rec {
        stopenocd = with final; stdenv.mkDerivation rec {
          pname = "stopenocd";
          inherit version;
          src = (fetchgit {
              url = "https://github.com/STMicroelectronics/OpenOCD";
              sha256 = "sha256-DBi2JwMs++etFrQHWFUnRfSzLofP0HGgHfhyiIJpQ0Q=";
              deepClone = true;
            });
          nativeBuildInputs = [ gnumake automake autoconf which libtool git rsync];
          buildInputs = [ pkg-config ];
          preConfigure = "sh ./bootstrap";
        };
      };

      packages = forAllSystems (system: {
          inherit (nixpkgsFor.${system}) stopenocd;
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.stopenocd);

    };
}
