{pkgs, config, ...}:
{

  environment.systemPackages = with pkgs;
    let
    # see https://nixos.org/wiki/TexLive_HOWTO
    tex = texlive.combine {
      inherit (texlive)
      scheme-medium
      collection-basic
      collection-fontsrecommended
      collection-latexextra
      collection-latexrecommended
      beamer
      moderncv
      fontawesome
      moderntimeline
      cm-super
      inconsolata
      libertine;
    };
  in
    [ texlive.combined.scheme-full
    ];

}
