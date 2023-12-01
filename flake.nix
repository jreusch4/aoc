{
	# inputs = {
	# 	roc = {
	# 		url = "github:roc-lang/roc";
	# 		inputs.nixpkgs.follows = "nixpkgs";
	# 	};
	# };

	outputs = { self, nixpkgs }:
	let
		inherit (nixpkgs) lib;
		
		hashes = {
			"x86_64-linux"= "1lj58a1k6di5bsf2zkjd1rsqkhxh6dzbj3ibgmncz9qy2vlikczh";
			"aarch64-linux" = "1xwfahqp8aja6a6sivvqj6m33zrjp41zh21hhqfkq6hhn8bq5irj";
			"x86_64-darwin" = "0d0w6bflw2ar9z9ygk8dfqacxw2xlg9fdjgk3hr7ssrbabbgqn5x";
			"aarch64-darwin" = "0nnkkcgq2l98gafmjhh0kig8xkprrqpg8nwn743xjgid0q17gv7c";
		};

		filename = {
			"x86_64-linux"= "roc_nightly-linux_x86_64-latest.tar.gz";
			"aarch64-linux" = "roc_nightly-linux_arm64-latest.tar.gz";
			"x86_64-darwin" = "roc_nightly-macos_x86_64-latest.tar.gz";
			"aarch64-darwin" = "roc_nightly-macos_apple_silicon-latest.tar.gz";
		};

		systems = builtins.attrNames hashes;

		forEachSystem = f: lib.genAttrs systems (system: f system);
	in {
		devShell = forEachSystem (system: 
			with import nixpkgs { inherit system; };
			let
				inherit (pkgs) stdenv;

				os = if stdenv.isDarwin then "macos" else "linux";
				arch = if stdenv.isAarch64 then "arm64" else "x86_64";
				
				deps = with pkgs; [
					stdenv.cc.cc
					openssl
					zlib
					ncurses6
					glibc
				];
				
				roc = stdenv.mkDerivation {
					name = "roc";
					
					src = builtins.fetchTarball {
						url = "https://github.com/roc-lang/roc/releases/download/nightly/${filename.${system}}";
						sha256 = hashes.${system};
					};

					nativeBuildInputs = [ makeShellWrapper ];

					installPhase = ''
						runHook preInstall

						install -m755 -D $src/roc $out/bin/roc
						patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/roc
						librarypath="${lib.makeLibraryPath deps}"
						wrapProgramShell $out/bin/roc \
							--prefix LD_LIBRARY_PATH : "$librarypath" \
							--set NIX_GLIBC_PATH "${lib.makeLibraryPath [pkgs.glibc]}" \
							--set NIX_LIBGCC_S_PATH "${lib.makeLibraryPath [stdenv.cc.cc]}"

						runHook postInstall
					'';
				};
			in
			pkgs.mkShell {
				buildInputs = [
					# roc.packages.${system}.cli
					# roc.packages.${system}.lang-serve
					roc
				];
			});
	};
}
