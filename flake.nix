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

		sources = {
			"x86_64-linux"= {
				name = "roc_nightly-linux_x86_64-latest.tar.gz";
				hash = "19iv9wwjpj41h1l9qy8cdz4c260arklmrva2bmnyqcycs2gm88rp";
			};
			"aarch64-linux" = {
				
				name = "roc_nightly-linux_arm64-latest.tar.gz";
				# hash = "1xwfahqp8aja6a6sivvqj6m33zrjp41zh21hhqfkq6hhn8bq5irj";
			};

			"x86_64-darwin" = {
				name = "roc_nightly-macos_x86_64-latest.tar.gz";		
				# hash = "0d0w6bflw2ar9z9ygk8dfqacxw2xlg9fdjgk3hr7ssrbabbgqn5x";
			};

			"aarch64-darwin" = {
				name = "roc_nightly-macos_apple_silicon-latest.tar.gz";			
				# hash = "0nnkkcgq2l98gafmjhh0kig8xkprrqpg8nwn743xjgid0q17gv7c";
			};
		};

		systems = builtins.attrNames sources;

		forEachSystem = f: lib.genAttrs systems (system: f system);
	in {
		devShell = forEachSystem (system: 
			with import nixpkgs { inherit system; };
			let
				inherit (pkgs) stdenv;
				
				deps = with pkgs; [
					stdenv.cc.cc
					openssl
					zlib
					ncurses6
					glibc
				];

				src = sources.${system};

				# debugir = pkgs.stdenv.mkDerivation {
    #       name = "debugir";
    #       src = pkgs.fetchFromGitHub {
    #         owner = "vaivaswatha";
    #         repo = "debugir";
    #         rev = "b981e0b74872d9896ba447dd6391dfeb63332b80";
    #         sha256 = "Gzey0SF0NZkpiObk5e29nbc41dn4Olv1dx+6YixaZH0=";
    #       };
    #       buildInputs = with pkgs; [ cmake libxml2 llvmPackages_13.llvm.dev ];
    #       buildPhase = ''
    #         mkdir build
    #         cd build
    #         cmake -DLLVM_DIR=${llvmPackages_13.llvm.dev} -DCMAKE_BUILD_TYPE=Release ../
    #         cmake --build ../
    #         cp ../debugir .
    #       '';
    #       installPhase = ''
    #         mkdir -p $out/bin
    #         cp debugir $out/bin
    #       '';
    #     };
				
				roc = stdenv.mkDerivation {
					name = "roc";
					
					src = builtins.fetchTarball {
						url = "https://github.com/roc-lang/roc/releases/download/nightly/${src.name}";
						sha256 = src.hash;
					};

					nativeBuildInputs = [ makeShellWrapper ];

					# --prefix PATH : "${debugir}/bin" \
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
					# debugir
					# pkgs.llvmPackages_13.libllvm
				];
			});
	};
}
