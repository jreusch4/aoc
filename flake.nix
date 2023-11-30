{
	inputs = {
		roc = {
			url = "github:roc-lang/roc";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, roc }:
	let system = "x86_64-linux";
	in {
		devShell.${system} =
			with import nixpkgs { inherit system; }; pkgs.mkShell {
				buildInputs = [
					roc.packages.${system}.cli
					roc.packages.${system}.lang-server
				];
			};
	};
}
