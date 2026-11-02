{ ... }:

{
  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "appcenter";
        location = "https://flatpak.elementary.io/repo.flatpakrepo";
      }
    ];

    packages = [
      # elementary AppCenter
      { appId = "com.github.avojak.iridium"; origin = "appcenter"; }
      { appId = "com.github.brain_child.moobo"; origin = "appcenter"; }
      { appId = "com.github.childishgiant.mixer"; origin = "appcenter"; }
      { appId = "com.github.dahenson.agenda"; origin = "appcenter"; }
      { appId = "com.github.donadigo.appeditor"; origin = "appcenter"; }
      { appId = "com.github.hezral.clips"; origin = "appcenter"; }
      { appId = "com.github.hezral.keystrokes"; origin = "appcenter"; }
      { appId = "com.github.hezral.stashed"; origin = "appcenter"; }
      { appId = "com.github.jmoerman.goforit"; origin = "appcenter"; }
      { appId = "com.github.philip_scott.notes-up"; origin = "appcenter"; }
      { appId = "com.github.philip_scott.spice-up"; origin = "appcenter"; }
      { appId = "com.github.ryonakano.louper"; origin = "appcenter"; }
      { appId = "com.github.sgpthomas.hourglass"; origin = "appcenter"; }
      { appId = "com.github.syfds.soundy"; origin = "appcenter"; }
      { appId = "com.manexim.codecard"; origin = "appcenter"; }
      { appId = "dev.mysh.valapad"; origin = "appcenter"; }
      { appId = "hr.from.josipantolis.sage"; origin = "appcenter"; }
      { appId = "hr.from.josipantolis.starfish"; origin = "appcenter"; }
      { appId = "io.elementary.capnet-assist//stable"; origin = "appcenter"; }
      { appId = "io.elementary.iconbrowser//stable"; origin = "appcenter"; }
      { appId = "io.github.danirabbit.nimbus"; origin = "appcenter"; }
      { appId = "io.github.flodavid.EspaceLibre"; origin = "appcenter"; }
      { appId = "io.github.jhaygood86.mauborgne"; origin = "appcenter"; }
      { appId = "io.github.leolost2605.detective"; origin = "appcenter"; }
      { appId = "org.gnome.Evince//stable"; origin = "appcenter"; }
      { appId = "org.gnome.FileRoller//stable"; origin = "appcenter"; }
      { appId = "org.gnome.font-viewer"; origin = "appcenter"; }

      # Flathub
      { appId = "com.github.muriloventuroso.easyssh"; origin = "flathub"; }
      { appId = "com.github.robertsanseries.ciano"; origin = "flathub"; }
      { appId = "com.github.subhadeepjasu.pebbles"; origin = "flathub"; }
      { appId = "com.unity.UnityHub"; origin = "flathub"; }
      { appId = "io.github.tuner_labs.tuner"; origin = "flathub"; }
      { appId = "org.gnome.Epiphany"; origin = "flathub"; }
      { appId = "page.codeberg.elly_code.cherrypick"; origin = "flathub"; }
      { appId = "page.codeberg.elly_code.inscriptions"; origin = "flathub"; }
      { appId = "page.codeberg.elly_code.jorts"; origin = "flathub"; }
      { appId = "page.codeberg.elly_code.reminduck"; origin = "flathub"; }
      { appId = "sh.ppy.osu"; origin = "flathub"; }
    ];
  };
}
